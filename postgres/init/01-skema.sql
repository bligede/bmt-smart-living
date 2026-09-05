-- Skema basis data rumah. Dijalankan sekali saat kontainer pertama dibuat.
-- Skema ini MILIK KITA. Tabel Home Assistant terpisah dan boleh berubah antar versi.

CREATE EXTENSION IF NOT EXISTS timescaledb;

-- ---------------------------------------------------------------- perangkat
CREATE TABLE IF NOT EXISTS perangkat (
    id          text PRIMARY KEY,          -- sama dengan entity_id di Home Assistant
    ruang       text        NOT NULL,
    jenis       text        NOT NULL,      -- lampu, sensor, colokan, ac, kamera, kunci
    merek       text,                      -- shelly | sonoff | lain
    model       text,
    mac         macaddr,
    ip          inet,
    firmware    text,
    dipasang    date        DEFAULT current_date,
    aktif       boolean     NOT NULL DEFAULT true,
    catatan     text
);

COMMENT ON TABLE perangkat IS 'Daftar perangkat terpasang. Diisi saat komisioning, bukan otomatis.';

-- ---------------------------------------------------------------- telemetri
CREATE TABLE IF NOT EXISTS telemetri (
    waktu       timestamptz      NOT NULL,
    perangkat   text             NOT NULL,
    metrik      text             NOT NULL,  -- suhu, kelembapan, daya, energi, baterai, lux
    nilai       double precision NOT NULL
);

SELECT create_hypertable('telemetri', 'waktu', if_not_exists => TRUE);

CREATE INDEX IF NOT EXISTS telemetri_perangkat_metrik_idx
    ON telemetri (perangkat, metrik, waktu DESC);

-- Sengaja TANPA foreign key ke perangkat: telemetri tidak boleh gagal ditulis
-- hanya karena sebuah perangkat belum sempat didaftarkan saat komisioning.

-- ---------------------------------------------------------------- kejadian
CREATE TABLE IF NOT EXISTS kejadian (
    id          bigserial     PRIMARY KEY,
    waktu       timestamptz   NOT NULL DEFAULT now(),
    jenis       text          NOT NULL,    -- alarm, padam_listrik, pintu, baterai_lemah, luring
    perangkat   text,
    tingkat     text          NOT NULL DEFAULT 'info',  -- info | penting | kritis
    muatan      jsonb         NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS kejadian_waktu_idx   ON kejadian (waktu DESC);
CREATE INDEX IF NOT EXISTS kejadian_jenis_idx   ON kejadian (jenis, waktu DESC);

-- ---------------------------------------------------------------- antrean kirim
-- Baris yang belum berhasil dikirim ke server pusat. Menumpuk saat internet putus.
CREATE TABLE IF NOT EXISTS antrean_kirim (
    id          bigserial     PRIMARY KEY,
    dibuat      timestamptz   NOT NULL DEFAULT now(),
    jenis       text          NOT NULL,    -- denyut | agregat | kejadian | perangkat
    muatan      jsonb         NOT NULL,
    percobaan   integer       NOT NULL DEFAULT 0,
    terkirim    timestamptz
);

CREATE INDEX IF NOT EXISTS antrean_belum_terkirim_idx
    ON antrean_kirim (dibuat) WHERE terkirim IS NULL;
