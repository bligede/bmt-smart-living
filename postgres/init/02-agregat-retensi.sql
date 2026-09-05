-- Agregat berkelanjutan dan kebijakan retensi.
-- Dipasang bersamaan dengan tabelnya, bukan setelah SSD penuh.

-- ---------------------------------------------------- agregat per jam
CREATE MATERIALIZED VIEW IF NOT EXISTS telemetri_jam
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', waktu) AS jam,
       perangkat,
       metrik,
       avg(nilai)   AS rerata,
       min(nilai)   AS terendah,
       max(nilai)   AS puncak,
       count(*)     AS cacah
FROM telemetri
GROUP BY jam, perangkat, metrik
WITH NO DATA;

SELECT add_continuous_aggregate_policy('telemetri_jam',
    start_offset      => INTERVAL '3 days',
    end_offset        => INTERVAL '1 hour',
    schedule_interval => INTERVAL '30 minutes',
    if_not_exists     => TRUE);

-- ---------------------------------------------------- agregat energi harian
-- Energi adalah pencacah naik. Selisih puncak dikurangi terendah = pemakaian hari itu.
CREATE MATERIALIZED VIEW IF NOT EXISTS energi_harian
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 day', waktu) AS hari,
       perangkat,
       max(nilai) - min(nilai) AS kwh
FROM telemetri
WHERE metrik = 'energi'
GROUP BY hari, perangkat
WITH NO DATA;

SELECT add_continuous_aggregate_policy('energi_harian',
    start_offset      => INTERVAL '7 days',
    end_offset        => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour',
    if_not_exists     => TRUE);

-- ---------------------------------------------------- retensi
-- Telemetri mentah 90 hari. Agregat bertahan jauh lebih lama karena jauh lebih kecil.
SELECT add_retention_policy('telemetri', INTERVAL '90 days', if_not_exists => TRUE);
SELECT add_retention_policy('telemetri_jam', INTERVAL '5 years', if_not_exists => TRUE);
SELECT add_retention_policy('energi_harian', INTERVAL '5 years', if_not_exists => TRUE);

-- Kompresi telemetri mentah yang sudah lewat seminggu
ALTER TABLE telemetri SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'perangkat, metrik',
    timescaledb.compress_orderby   = 'waktu DESC'
);
SELECT add_compression_policy('telemetri', INTERVAL '7 days', if_not_exists => TRUE);

-- Kejadian dibersihkan lewat tugas terjadwal, bukan retensi hypertable
-- (jumlahnya sedikit dan tabelnya biasa)
CREATE OR REPLACE FUNCTION bersihkan_kejadian() RETURNS void AS $$
    DELETE FROM kejadian WHERE waktu < now() - INTERVAL '5 years';
$$ LANGUAGE sql;

-- Antrean yang sudah terkirim tidak perlu disimpan
CREATE OR REPLACE FUNCTION bersihkan_antrean() RETURNS void AS $$
    DELETE FROM antrean_kirim
    WHERE terkirim IS NOT NULL AND terkirim < now() - INTERVAL '7 days';
$$ LANGUAGE sql;
