# Tumpukan Rumah Pintar BMT

Seluruh perangkat lunak yang berjalan di satu Raspberry Pi, di dalam rumah pelanggan.

Dokumen pendamping: **Panduan Integrasi Perangkat, Basis Data, dan Dasbor v1.0**.
Kalau ada yang tidak jelas di sini, jawabannya ada di sana.

---

## Prinsip

**Home Assistant mengendalikan. Grafana memantau.** Tidak ada tombol di Grafana
yang menyalakan apa pun. Menaruh kendali di lapisan pemantauan menciptakan dua
sumber kebenaran, dan yang kedua selalu tertinggal.

**Basis data di rumah adalah sumber kebenaran untuk rumah itu.** Server pusat BMT
menyimpan salinan ringkas, bukan aslinya.

**Setiap lapisan tetap bekerja ketika lapisan di atasnya mati.** Saklar bekerja
tanpa hub, hub bekerja tanpa internet, rumah bekerja tanpa server kita.

---

## Prasyarat

| Hal | Syarat |
|---|---|
| Perangkat keras | Raspberry Pi 5, RAM 8 GB, **boot dari NVMe lewat HAT M.2** |
| Sistem operasi | Raspberry Pi OS Lite 64-bit atau Debian 12 |
| Docker | Docker Engine + plugin Compose |
| Jaringan | Ethernet ke switch. Jangan pakai Wi-Fi bawaan Pi |

> **Kartu microSD dilarang.** Basis data menulis terus-menerus; microSD mati dalam
> 6–18 bulan di bawah beban ini, dan matinya tidak bersih — sistem rusak perlahan
> sebelum berhenti.

---

## Pemasangan

```bash
git clone <repo> /opt/rumah && cd /opt/rumah

cp .env.example .env
cp homeassistant/secrets.yaml.example homeassistant/secrets.yaml
cp esphome/secrets.yaml.example       esphome/secrets.yaml
cp cloudflared/config.example.yml     cloudflared/config.yml

# Ganti SELURUH sandi contoh. Jangan ada yang tersisa.
${EDITOR:-nano} .env

# Berkas sandi Mosquitto
docker run --rm -v "$PWD/mosquitto/config:/mosquitto/config" \
  eclipse-mosquitto:2.0 \
  mosquitto_passwd -c -b /mosquitto/config/passwd rumah 'SANDI-MQTT'

docker compose up -d
```

Periksa:

```bash
docker compose ps
docker compose logs -f ingester        # harus melaporkan jumlah aturan yang dimuat
```

| Layanan | Alamat |
|---|---|
| Home Assistant | http://IP-PI:8123 |
| Grafana | http://127.0.0.1:3000 (lewat terowongan) |
| ESPHome | `docker compose --profile flashing up -d esphome` lalu port 6052 |

---

## Urutan yang benar saat komisioning

1. SSID perangkat menyala, **sementara masih ada jalur internet**
2. Perangkat dipasangkan, layanan awan pabrikan **dimatikan** di tiap perangkat
3. Firmware diperbarui — setelah langkah 6 tidak ada kesempatan lagi
4. Reservasi IP berdasarkan MAC di access point
5. Perangkat didaftarkan ke tabel `perangkat` (lihat di bawah)
6. **SSID perangkat diblokir dari internet**, lalu semuanya diuji ulang

Mendaftarkan perangkat:

```sql
INSERT INTO perangkat (id, ruang, jenis, merek, model, mac, ip, firmware)
VALUES ('light.dapur_utama', 'dapur', 'lampu', 'sonoff', 'MINI R4',
        'aa:bb:cc:dd:ee:ff', '192.168.20.31', '2025.7.0');
```

---

## Struktur

```
docker-compose.yml        Seluruh layanan
postgres/init/            Skema, agregat, retensi, pengguna Grafana — jalan sekali
mosquitto/config/         Broker. Tidak pernah diekspos ke internet
ingester/                 MQTT -> tabel telemetri milik kita
  pemetaan.yaml           Pemetaan topik. Model baru ditambah DI SINI, bukan di Python
pusher/                   Agregat -> server pusat. Menumpuk lalu menyusul
homeassistant/            Kendali, otomasi, scene, dasbor tamu
  packages/               Otomasi dipecah per topik
esphome/                  Templat firmware untuk perangkat Sonoff yang di-flash
grafana/                  Datasource dan dasbor, disediakan otomatis
cloudflared/              Satu-satunya jalur keluar
```

---

## Menambah perangkat baru

**Shelly** — aktifkan MQTT di perangkat dengan `topic_prefix` = nama entitas.
Pola `shelly/+/status/...` di `pemetaan.yaml` sudah menangkapnya.

**Sonoff** — flash dengan templat di `esphome/`, ganti `substitutions`.
Pola `+/sensor/+/state` sudah menangkapnya.

**Model dengan bentuk data lain** — tambahkan aturan di `pemetaan.yaml`.
Jangan menyunting `ingester.py`; itu tanda pemetaannya yang kurang, bukan kodenya.

---

## Cadangan

```bash
./scripts/backup.sh
```

Mencadangkan basis data, konfigurasi Home Assistant, dan daftar perangkat.
**Uji pulih tiap kuartal pada perangkat cadangan di kantor** — cadangan yang
belum pernah dipulihkan bukan cadangan, hanya berkas.

---

## Yang tidak pernah dilakukan

- Membuka port di router pelanggan. Seluruh akses lewat terowongan keluar
- Membuka kembali jalur internet SSID perangkat setelah komisioning
- Membangun dasbor di atas tabel Home Assistant — skemanya berubah antar versi
- Memberi Grafana hak tulis, atau hak baca ke tabel mentah
