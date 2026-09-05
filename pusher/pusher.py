"""
Pengirim agregat ke server pusat BMT.

Sifatnya: menumpuk lalu menyusul. Ketika internet rumah putus, baris menumpuk
di tabel antrean dan dikirim setelah pulih. Tidak ada data yang hilang hanya
karena jaringan sempat mati.

Selalu dimulai dari dalam. Server pusat tidak pernah menghubungi rumah lebih
dulu, dan tidak ada port yang dibuka di jaringan pelanggan.

Gagal kirim bukan gagal sistem: rumah tetap berjalan penuh ketika server pusat
mati. Itu syarat rancangan, bukan kebetulan.
"""

from __future__ import annotations

import json
import logging
import os
import signal
import sys
import threading
import time
from datetime import datetime, timedelta, timezone

import httpx
import psycopg
from psycopg.rows import dict_row

log = logging.getLogger("pusher")

RUMAH_ID = os.environ["RUMAH_ID"]
PG_DSN = os.environ["PG_DSN"]
API_URL = os.environ["BMT_API_URL"].rstrip("/")
API_TOKEN = os.environ["BMT_API_TOKEN"]
INTERVAL = int(os.environ.get("INTERVAL_DETIK", "300"))
UKURAN_KIRIM = int(os.environ.get("UKURAN_KIRIM", "500"))
BATAS_PERCOBAAN = int(os.environ.get("BATAS_PERCOBAAN", "50"))

berhenti = threading.Event()


def http() -> httpx.Client:
    return httpx.Client(
        base_url=API_URL,
        headers={
            "Authorization": f"Bearer {API_TOKEN}",
            "X-Rumah-Id": RUMAH_ID,
            "Content-Type": "application/json",
        },
        timeout=httpx.Timeout(20.0, connect=10.0),
    )


# ------------------------------------------------------------------ pengumpul
def kumpulkan_agregat(conn) -> int:
    """Masukkan agregat per jam yang belum diantrekan ke antrean kirim."""
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO antrean_kirim (jenis, muatan)
            SELECT 'agregat', jsonb_build_object(
                       'jam',       j.jam,
                       'perangkat', j.perangkat,
                       'metrik',    j.metrik,
                       'rerata',    round(j.rerata::numeric, 3),
                       'terendah',  round(j.terendah::numeric, 3),
                       'puncak',    round(j.puncak::numeric, 3))
            FROM telemetri_jam j
            WHERE j.jam >= now() - INTERVAL '48 hours'
              AND j.jam <  date_trunc('hour', now())
              AND NOT EXISTS (
                    SELECT 1 FROM antrean_kirim a
                    WHERE a.jenis = 'agregat'
                      AND a.muatan->>'jam'       = j.jam::text
                      AND a.muatan->>'perangkat' = j.perangkat
                      AND a.muatan->>'metrik'    = j.metrik)
        """)
        return cur.rowcount


def kumpulkan_kejadian(conn) -> int:
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO antrean_kirim (jenis, muatan)
            SELECT 'kejadian', jsonb_build_object(
                       'id',        k.id,
                       'waktu',     k.waktu,
                       'jenis',     k.jenis,
                       'perangkat', k.perangkat,
                       'tingkat',   k.tingkat,
                       'muatan',    k.muatan)
            FROM kejadian k
            WHERE k.waktu >= now() - INTERVAL '7 days'
              AND NOT EXISTS (
                    SELECT 1 FROM antrean_kirim a
                    WHERE a.jenis = 'kejadian'
                      AND (a.muatan->>'id')::bigint = k.id)
        """)
        return cur.rowcount


# ------------------------------------------------------------------ pengirim
def kirim_denyut(conn, klien: httpx.Client) -> None:
    """Denyut dikirim langsung, tidak diantrekan — kalau gagal, biarkan hilang."""
    with conn.cursor(row_factory=dict_row) as cur:
        cur.execute("""
            SELECT (SELECT count(*) FROM perangkat WHERE aktif)               AS perangkat_aktif,
                   (SELECT count(*) FROM antrean_kirim WHERE terkirim IS NULL) AS antrean,
                   (SELECT max(waktu) FROM telemetri)                          AS telemetri_terakhir
        """)
        ringkas = cur.fetchone() or {}

    muatan = {
        "rumah": RUMAH_ID,
        "waktu": datetime.now(timezone.utc).isoformat(),
        "perangkat_aktif": ringkas.get("perangkat_aktif"),
        "antrean_tertunda": ringkas.get("antrean"),
        "telemetri_terakhir": (
            ringkas["telemetri_terakhir"].isoformat()
            if ringkas.get("telemetri_terakhir") else None
        ),
    }
    try:
        r = klien.post("/denyut", json=muatan)
        r.raise_for_status()
        log.debug("denyut terkirim")
    except Exception as e:
        log.info("denyut gagal (%s) — tidak apa-apa, rumah tetap jalan", type(e).__name__)


def kirim_antrean(conn, klien: httpx.Client) -> tuple[int, int]:
    """Kirim antrean tertunda. Kembalikan (berhasil, gagal)."""
    with conn.cursor(row_factory=dict_row) as cur:
        cur.execute("""
            SELECT id, jenis, muatan FROM antrean_kirim
            WHERE terkirim IS NULL AND percobaan < %s
            ORDER BY dibuat
            LIMIT %s
        """, (BATAS_PERCOBAAN, UKURAN_KIRIM))
        baris = cur.fetchall()

    if not baris:
        return 0, 0

    muatan = {
        "rumah": RUMAH_ID,
        "kiriman": [{"jenis": b["jenis"], "data": b["muatan"]} for b in baris],
    }
    ids = [b["id"] for b in baris]

    try:
        r = klien.post("/kiriman", json=muatan)
        r.raise_for_status()
    except Exception as e:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE antrean_kirim SET percobaan = percobaan + 1 WHERE id = ANY(%s)",
                (ids,),
            )
        log.info("kirim gagal (%s), %d baris tetap di antrean", type(e).__name__, len(ids))
        return 0, len(ids)

    with conn.cursor() as cur:
        cur.execute(
            "UPDATE antrean_kirim SET terkirim = now() WHERE id = ANY(%s)", (ids,)
        )
    log.info("terkirim %d baris", len(ids))
    return len(ids), 0


def bersihkan(conn) -> None:
    with conn.cursor() as cur:
        cur.execute("SELECT bersihkan_antrean()")
        cur.execute("SELECT bersihkan_kejadian()")


# ------------------------------------------------------------------ utama
def satu_putaran(klien: httpx.Client) -> None:
    with psycopg.connect(PG_DSN, autocommit=True) as conn:
        kirim_denyut(conn, klien)
        baru = kumpulkan_agregat(conn) + kumpulkan_kejadian(conn)
        if baru:
            log.info("%d baris baru masuk antrean", baru)

        # Kuras antrean sampai habis atau sampai gagal
        while not berhenti.is_set():
            berhasil, gagal = kirim_antrean(conn, klien)
            if gagal or berhasil == 0:
                break

        bersihkan(conn)


def main() -> int:
    logging.basicConfig(
        level=os.environ.get("LOG_LEVEL", "INFO"),
        format="%(asctime)s %(levelname)-7s %(name)s %(message)s",
    )

    def bereskan(_signum, _frame):
        log.info("menerima sinyal berhenti")
        berhenti.set()

    signal.signal(signal.SIGTERM, bereskan)
    signal.signal(signal.SIGINT, bereskan)

    log.info("pengirim mulai untuk %s, tiap %d detik", RUMAH_ID, INTERVAL)

    with http() as klien:
        while not berhenti.is_set():
            try:
                satu_putaran(klien)
            except Exception:
                log.exception("putaran gagal, dicoba lagi pada siklus berikutnya")
            berhenti.wait(INTERVAL)

    log.info("berhenti dengan bersih")
    return 0


if __name__ == "__main__":
    sys.exit(main())
