#!/usr/bin/env bash
# Cadangan harian. Dipanggil dari cron:
#   15 2 * * * /opt/rumah/scripts/backup.sh >> /var/log/rumah-backup.log 2>&1
set -euo pipefail

CD="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$CD"
set -a; . ./.env; set +a

TUJUAN="${TUJUAN_CADANGAN:-/var/backups/rumah}"
CAP="$(date +%Y-%m-%d)"
mkdir -p "$TUJUAN"

echo "[$(date -Is)] mulai cadangan $RUMAH_ID"

# Basis data
docker compose exec -T postgres \
    pg_dump -U "$PG_USER" -d "$PG_DB" --no-owner --clean --if-exists \
    | gzip -9 > "$TUJUAN/db-$CAP.sql.gz"

# Konfigurasi. Rahasia ikut, jadi berkasnya hanya boleh dibaca root.
tar -czf "$TUJUAN/konfigurasi-$CAP.tar.gz" \
    homeassistant esphome mosquitto/config .env cloudflared/config.yml
chmod 600 "$TUJUAN"/*-"$CAP".*

# Retensi: 30 harian, ditambah cadangan tanggal 1 tiap bulan selama 12 bulan
find "$TUJUAN" -name 'db-*.sql.gz'          -mtime +30 ! -name 'db-*-01.sql.gz'          -delete
find "$TUJUAN" -name 'konfigurasi-*.tar.gz' -mtime +30 ! -name 'konfigurasi-*-01.tar.gz' -delete
find "$TUJUAN" -name '*-01.*'               -mtime +365 -delete

echo "[$(date -Is)] selesai: $(du -sh "$TUJUAN" | cut -f1)"
