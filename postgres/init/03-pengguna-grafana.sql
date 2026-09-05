-- Pengguna baca-saja untuk Grafana.
-- Grafana TIDAK BOLEH menyentuh tabel mentah maupun tabel Home Assistant.
-- Batas ini dipasang sekarang supaya tidak perlu diburu-buru ketika dasbor
-- suatu hari dibuka ke pemilik rumah.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'grafana_ro') THEN
        CREATE ROLE grafana_ro LOGIN PASSWORD 'ganti-sandi-ini-juga';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE rumah TO grafana_ro;
GRANT USAGE   ON SCHEMA public  TO grafana_ro;

-- Hanya tampilan agregat dan tabel rujukan
GRANT SELECT ON telemetri_jam   TO grafana_ro;
GRANT SELECT ON energi_harian   TO grafana_ro;
GRANT SELECT ON perangkat       TO grafana_ro;
GRANT SELECT ON kejadian        TO grafana_ro;

-- Ditolak secara eksplisit, supaya niatnya terbaca oleh siapa pun yang membuka berkas ini
REVOKE ALL ON telemetri     FROM grafana_ro;
REVOKE ALL ON antrean_kirim FROM grafana_ro;

-- Tabel Home Assistant dibuat belakangan oleh HA sendiri.
-- Aturan bawaan ini memastikan grafana_ro tidak ikut mendapat hak atasnya.
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM grafana_ro;
