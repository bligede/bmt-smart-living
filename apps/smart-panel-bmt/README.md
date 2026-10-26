# Smart Panel BMT · Android & iOS

Demo Flutter offline untuk meninjau antarmuka rumah pintar BMT. Semua rumah, perangkat, grafik, kamera, kode tamu dan perintah memakai data simulasi lokal. Aplikasi ini belum terhubung ke layanan pada root repo.

Offline Flutter demo for reviewing BMT's smart home interface. Homes, devices, charts, cameras, guest codes and commands use simulated local data. The app is not connected to the services at this repository's root.

- Indonesia–English, tema terang/gelap/sistem, font Inter yang dibundel.
- Paket Basic/Medium/High; peran Pemilik, Keluarga, Tamu dan Teknisi.
- Dasbor, perangkat, energi, adegan, kamera ilustrasi, akses tamu dan skenario S1–S10.
- Android 7+ (API 24), iPhone iOS 13+, portrait.
- Notifikasi lokal dan konfirmasi biometrik opsional; seluruh kendali tetap simulasi.
- Panduan gas **menunggu validasi BMT**. Demo bukan sistem keselamatan operasional.

## Menjalankan / Run

Gunakan Flutter **3.41.9** stable / Dart **3.11.5** (lihat `.fvmrc`). Dari folder ini:

```sh
flutter pub get --enforce-lockfile
flutter gen-l10n
flutter run
```

Untuk Android, pasang Android SDK dan hubungkan perangkat atau emulator. Untuk iPhone, gunakan Mac, Xcode, CocoaPods dan iPhone/simulator. Lihat [panduan iOS](docs/ios.md) untuk build, signing dan TestFlight.

Android requires Android SDK and a connected device/emulator. iPhone requires a Mac, Xcode, CocoaPods and an iPhone/simulator. See the [iOS guide](docs/ios.md) for build, signing and TestFlight.

```sh
flutter analyze
flutter test
flutter build apk --debug
# On macOS:
bash tool/build-ios.sh
```

Workflow [Smart Panel iOS](../../.github/workflows/smart-panel-ios.yml) menjalankan analisis, tes, build dan launch simulator iPhone. Artifact `.app` hanya untuk simulator Mac. IPA untuk iPhone fisik memerlukan signing Apple BMT; kredensial dan kunci signing tidak disertakan. APK Android rilis menggunakan signing eksternal melalui `BMT_DEMO_SIGNING_PROPERTIES`, sesuai konfigurasi Gradle.

The iOS workflow analyzes, tests, builds and launches an iPhone simulator. Its `.app` artifact targets the Mac simulator. A physical iPhone IPA needs BMT Apple signing. Android release signing is configured externally via `BMT_DEMO_SIGNING_PROPERTIES`.

## Struktur / Structure

`lib/domain` mendefinisikan model dan kontrak repositori; `lib/data` menyediakan repositori simulasi; `lib/features` berisi UI; `lib/app` menangani navigasi, lokalisasi, preferensi dan adapter perangkat. `assets/mock` memuat data fiktif lokal. Pengujian domain dan widget berada di `test`.

Mock state stays in memory. Only demo preferences are stored locally. No real device control, cloud account, camera capture or telemetry is implemented. Notifikasi/suara mengikuti izin dan pengaturan sistem. Uji penerimaan Android/iPhone fisik tetap diperlukan.

Font Inter mengikuti [SIL Open Font License](assets/fonts/OFL.txt). Logo BMT adalah aset merek BMT.
