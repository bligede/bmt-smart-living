#!/usr/bin/env bash
# Penyiapan awal di Raspberry Pi yang masih bersih.
set -euo pipefail

CD="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$CD"

merah() { printf '\033[31m%s\033[0m\n' "$*"; }
hijau() { printf '\033[32m%s\033[0m\n' "$*"; }

# --- Penolakan keras: microSD ---
AKAR="$(findmnt -no SOURCE / || true)"
if [[ "$AKAR" == /dev/mmcblk* ]]; then
  merah "BERHENTI: sistem berjalan dari kartu microSD ($AKAR)."
  merah "Basis data akan mematikannya dalam 6-18 bulan, dan matinya tidak bersih."
  merah "Pindahkan ke NVMe lewat HAT M.2 sebelum melanjutkan."
  exit 1
fi
hijau "Penyimpanan akar: $AKAR"

command -v docker >/dev/null || { merah "Docker belum terpasang."; exit 1; }
docker compose version >/dev/null || { merah "Plugin Compose belum terpasang."; exit 1; }

# --- Berkas dari contoh ---
for p in ".env:.env.example" \
         "homeassistant/secrets.yaml:homeassistant/secrets.yaml.example" \
         "esphome/secrets.yaml:esphome/secrets.yaml.example" \
         "cloudflared/config.yml:cloudflared/config.example.yml"; do
  tujuan="${p%%:*}"; sumber="${p##*:}"
  [[ -f "$tujuan" ]] || { cp "$sumber" "$tujuan"; echo "dibuat: $tujuan"; }
done
chmod 600 .env homeassistant/secrets.yaml esphome/secrets.yaml

# --- Tolak sandi contoh ---
if grep -qE 'ganti-sandi|isi-token' .env homeassistant/secrets.yaml esphome/secrets.yaml; then
  merah "BERHENTI: masih ada sandi contoh yang belum diganti."
  grep -nE 'ganti-sandi|isi-token' .env homeassistant/secrets.yaml esphome/secrets.yaml || true
  exit 1
fi

# --- Sandi broker ---
if [[ ! -f mosquitto/config/passwd ]]; then
  set -a; . ./.env; set +a
  docker run --rm -v "$PWD/mosquitto/config:/mosquitto/config" eclipse-mosquitto:2.0 \
    mosquitto_passwd -c -b /mosquitto/config/passwd "$MQTT_USER" "$MQTT_PASSWORD"
  hijau "Berkas sandi broker dibuat."
fi

docker compose up -d
hijau "Tumpukan berjalan. Periksa: docker compose ps"
