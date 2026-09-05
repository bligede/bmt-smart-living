"""
Penyerap MQTT -> PostgreSQL.

Berdiri sendiri, tidak melalui Home Assistant. Konsekuensinya jalur data
pemantauan tetap hidup ketika Home Assistant sedang dimulai ulang, dan
skema tabel kita tidak ikut berubah ketika Home Assistant naik versi.

Menulis berkelompok, bukan per pesan: satu INSERT per beberapa ratus baris
jauh lebih ringan bagi SSD Raspberry Pi daripada satu INSERT per pesan.
"""

from __future__ import annotations

import json
import logging
import os
import queue
import signal
import sys
import threading
import time
from datetime import datetime, timezone

import paho.mqtt.client as mqtt
import psycopg
import yaml
from psycopg_pool import ConnectionPool

log = logging.getLogger("ingester")

MQTT_HOST = os.environ.get("MQTT_HOST", "mosquitto")
MQTT_PORT = int(os.environ.get("MQTT_PORT", "1883"))
MQTT_USER = os.environ.get("MQTT_USER") or None
MQTT_PASSWORD = os.environ.get("MQTT_PASSWORD") or None
PG_DSN = os.environ["PG_DSN"]
PEMETAAN = os.environ.get("PEMETAAN", "/app/pemetaan.yaml")

UKURAN_KELOMPOK = int(os.environ.get("UKURAN_KELOMPOK", "200"))
JEDA_SIRAM_DETIK = float(os.environ.get("JEDA_SIRAM_DETIK", "5"))
BATAS_ANTREAN = int(os.environ.get("BATAS_ANTREAN", "20000"))

berhenti = threading.Event()


# --------------------------------------------------------------------- pemetaan
def muat_pemetaan(path: str) -> tuple[list[dict], list[dict]]:
    with open(path, "r", encoding="utf-8") as f:
        isi = yaml.safe_load(f) or {}
    return isi.get("pemetaan", []) or [], isi.get("kejadian", []) or []


def cocok(pola: str, topik: str) -> list[str] | None:
    """Cocokkan topik dengan pola MQTT. Kembalikan ruas yang tertangkap wildcard."""
    ruas_pola = pola.split("/")
    ruas_topik = topik.split("/")
    tangkapan: list[str] = []

    for i, p in enumerate(ruas_pola):
        if p == "#":
            tangkapan.append("/".join(ruas_topik[i:]))
            return tangkapan
        if i >= len(ruas_topik):
            return None
        if p == "+":
            tangkapan.append(ruas_topik[i])
        elif p != ruas_topik[i]:
            return None

    return tangkapan if len(ruas_topik) == len(ruas_pola) else None


def isi_templat(templat: str, tangkapan: list[str]) -> str:
    hasil = templat
    for i, nilai in enumerate(tangkapan, start=1):
        hasil = hasil.replace("{" + str(i) + "}", nilai)
    return hasil


def ambil_bersarang(data: dict, jalur: str):
    """Ambil nilai dari kunci bersarang, mis. 'aenergy.total'."""
    kini = data
    for bagian in jalur.split("."):
        if not isinstance(kini, dict) or bagian not in kini:
            return None
        kini = kini[bagian]
    return kini


# --------------------------------------------------------------------- penulis
class Penulis(threading.Thread):
    """Menyerap dari antrean, menulis berkelompok ke PostgreSQL."""

    def __init__(self, pool: ConnectionPool, antrean: queue.Queue):
        super().__init__(daemon=True, name="penulis")
        self.pool = pool
        self.antrean = antrean

    def run(self) -> None:
        while not berhenti.is_set():
            kelompok = self._kumpulkan()
            if not kelompok:
                continue
            try:
                self._tulis(kelompok)
            except Exception:
                log.exception("gagal menulis %d baris, dicoba lagi", len(kelompok))
                # Kembalikan ke antrean bila masih muat, jangan sampai memori habis
                for baris in kelompok:
                    if self.antrean.qsize() < BATAS_ANTREAN:
                        self.antrean.put(baris)
                time.sleep(5)

    def _kumpulkan(self) -> list[tuple]:
        kelompok: list[tuple] = []
        batas = time.monotonic() + JEDA_SIRAM_DETIK
        while len(kelompok) < UKURAN_KELOMPOK and time.monotonic() < batas:
            sisa = batas - time.monotonic()
            if sisa <= 0:
                break
            try:
                kelompok.append(self.antrean.get(timeout=sisa))
            except queue.Empty:
                break
        return kelompok

    def _tulis(self, kelompok: list[tuple]) -> None:
        telemetri = [b[1:] for b in kelompok if b[0] == "telemetri"]
        kejadian = [b[1:] for b in kelompok if b[0] == "kejadian"]

        with self.pool.connection() as conn:
            if telemetri:
                with conn.cursor() as cur:
                    cur.executemany(
                        "INSERT INTO telemetri (waktu, perangkat, metrik, nilai) "
                        "VALUES (%s, %s, %s, %s)",
                        telemetri,
                    )
            if kejadian:
                with conn.cursor() as cur:
                    cur.executemany(
                        "INSERT INTO kejadian (waktu, jenis, perangkat, tingkat, muatan) "
                        "VALUES (%s, %s, %s, %s, %s)",
                        kejadian,
                    )
        log.debug("tertulis: %d telemetri, %d kejadian", len(telemetri), len(kejadian))


# --------------------------------------------------------------------- MQTT
class Penyerap:
    def __init__(self, aturan: list[dict], aturan_kejadian: list[dict], antrean: queue.Queue):
        self.aturan = aturan
        self.aturan_kejadian = aturan_kejadian
        self.antrean = antrean
        self.dibuang = 0

    def langganan(self) -> list[str]:
        """Kumpulan topik unik yang perlu dilanggan."""
        return sorted({a["pola"] for a in (self.aturan + self.aturan_kejadian)})

    def on_connect(self, client, _userdata, _flags, reason_code, _properties=None):
        if reason_code != 0:
            log.error("gagal tersambung ke broker: %s", reason_code)
            return
        for pola in self.langganan():
            client.subscribe(pola, qos=0)
        log.info("tersambung, melanggan %d pola topik", len(self.langganan()))

    def on_message(self, _client, _userdata, msg):
        waktu = datetime.now(timezone.utc)
        try:
            muatan = msg.payload.decode("utf-8", errors="replace").strip()
        except Exception:
            return

        for aturan in self.aturan:
            tangkapan = cocok(aturan["pola"], msg.topic)
            if tangkapan is None:
                continue
            nilai = self._ambil_nilai(aturan, muatan)
            if nilai is None:
                continue
            self._masuk_antrean((
                "telemetri",
                waktu,
                isi_templat(aturan["perangkat"], tangkapan),
                isi_templat(aturan["metrik"], tangkapan),
                nilai,
            ))

        for aturan in self.aturan_kejadian:
            tangkapan = cocok(aturan["pola"], msg.topic)
            if tangkapan is None:
                continue
            try:
                data = json.loads(muatan)
            except json.JSONDecodeError:
                data = {"pesan": muatan}
            self._masuk_antrean((
                "kejadian",
                waktu,
                isi_templat(aturan["jenis"], tangkapan),
                data.get("perangkat"),
                data.get("tingkat", "info"),
                json.dumps(data),
            ))

    def _ambil_nilai(self, aturan: dict, muatan: str) -> float | None:
        try:
            if aturan.get("format") == "json":
                mentah = ambil_bersarang(json.loads(muatan), aturan["medan"])
            else:
                mentah = muatan
            if mentah is None or mentah == "":
                return None
            nilai = float(mentah)
        except (ValueError, TypeError, json.JSONDecodeError):
            return None
        if nilai != nilai:          # NaN
            return None
        return nilai * float(aturan.get("skala", 1))

    def _masuk_antrean(self, baris: tuple) -> None:
        if self.antrean.qsize() >= BATAS_ANTREAN:
            self.dibuang += 1
            if self.dibuang % 500 == 1:
                log.warning("antrean penuh, %d pesan dibuang", self.dibuang)
            return
        self.antrean.put(baris)


# --------------------------------------------------------------------- utama
def main() -> int:
    logging.basicConfig(
        level=os.environ.get("LOG_LEVEL", "INFO"),
        format="%(asctime)s %(levelname)-7s %(name)s %(message)s",
    )

    aturan, aturan_kejadian = muat_pemetaan(PEMETAAN)
    if not aturan:
        log.error("pemetaan kosong, tidak ada yang bisa diserap")
        return 1
    log.info("memuat %d aturan telemetri, %d aturan kejadian", len(aturan), len(aturan_kejadian))

    pool = ConnectionPool(PG_DSN, min_size=1, max_size=4, open=True, timeout=30)
    antrean: queue.Queue = queue.Queue(maxsize=BATAS_ANTREAN + 1000)

    Penulis(pool, antrean).start()

    penyerap = Penyerap(aturan, aturan_kejadian, antrean)
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id="ingester-bmt")
    if MQTT_USER:
        client.username_pw_set(MQTT_USER, MQTT_PASSWORD)
    client.on_connect = penyerap.on_connect
    client.on_message = penyerap.on_message
    client.reconnect_delay_set(min_delay=1, max_delay=60)

    def bereskan(_signum, _frame):
        log.info("menerima sinyal berhenti")
        berhenti.set()
        client.disconnect()

    signal.signal(signal.SIGTERM, bereskan)
    signal.signal(signal.SIGINT, bereskan)

    while not berhenti.is_set():
        try:
            client.connect(MQTT_HOST, MQTT_PORT, keepalive=60)
            client.loop_forever(retry_first_connection=True)
        except Exception:
            if berhenti.is_set():
                break
            log.exception("sambungan broker terputus, mencoba lagi dalam 10 detik")
            time.sleep(10)

    # Beri kesempatan penulis menyiram sisa antrean
    time.sleep(JEDA_SIRAM_DETIK + 2)
    pool.close()
    log.info("berhenti dengan bersih")
    return 0


if __name__ == "__main__":
    sys.exit(main())
