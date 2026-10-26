# Validasi demo iOS Smart Panel BMT

Tanggal: 26 Oktober 2026. Sumber aplikasi yang diuji: [`4790156`](https://github.com/bligede/bmt-smart-living/commit/479015640f461b5c1d1a59d05e48cd450d4dc1b7).

[GitHub Actions final](https://github.com/bligede/bmt-smart-living/actions/runs/40340934555) **lulus** pada runner macOS. Aplikasi tersedia di [apps/smart-panel-bmt](../apps/smart-panel-bmt/README.md); petunjuk build/signing tersedia di [panduan iOS](../apps/smart-panel-bmt/docs/ios.md).

| Pemeriksaan | Hasil |
|---|---|
| Flutter analyze | Tidak ada masalah |
| Unit/widget test | 119 lulus di Windows dan runner macOS |
| Adapter notifikasi iOS | Izin tidak diminta saat startup; uji penolakan, jalur offline, lampiran kamera, pembatalan saat peran berubah dan error platform lulus dengan mock channel |
| Area aman iPhone | Uji viewport dengan inset bawah 34 dp lulus untuk onboarding, fondasi dan galeri |
| Build native | `flutter build ios --simulator --debug --no-codesign` lulus |
| Plist dan privasi | Info.plist, PrivacyInfo.xcprivacy serta teks izin Face ID Indonesia/Inggris valid |
| Peluncuran | Aplikasi dipasang dan dibuka pada simulator iPhone 16 Pro; proses masih aktif setelah pemeriksaan 10 detik |
| Artifact | `smart-panel-bmt-ios-simulator` memuat ZIP Runner.app dan PNG startup/onboarding; tersedia di halaman Actions selama 14 hari |

Target: iPhone portrait, iOS 13+, bundle ID `com.balimikroteknologi.smartpanel.demo`, Flutter 3.41.9 / Dart 3.11.5, versi aplikasi 0.1.0+1. Simulator adalah build debug untuk Mac.

Uji Face ID/Touch ID pada perangkat nyata, izin/notifikasi OS dan cold launch melalui notifikasi, silent/Focus, kinerja, VoiceOver, seluruh skenario dan penerimaan iPhone fisik masih perlu dilakukan. Pengujian channel memakai mock dan tidak menggantikan pemeriksaan OS nyata. Paket ini belum menyertakan IPA yang ditandatangani atau distribusi TestFlight; signing Apple BMT belum dikonfigurasi.

Seluruh data dan kendali merupakan simulasi offline. Panduan gas tetap menunggu validasi teknis BMT. Sumber aplikasi ditambahkan bersama infrastruktur rumah pintar yang sudah ada; brief asli serta dokumen tinjauan internal tidak diterbitkan dalam snapshot aplikasi.
