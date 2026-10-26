# Smart Panel BMT untuk iPhone / for iPhone

Target iPhone portrait, iOS 13+, Flutter **3.41.9** / Dart **3.11.5**. Bundle ID: `com.balimikroteknologi.smartpanel.demo`, versi `0.1.0+1`.

Seluruh rumah, kamera, energi, gas, akses tamu dan kendali memakai data simulasi lokal. Semua tampilan mendukung Indonesia–Inggris, tema terang/gelap/sistem dan font Inter yang dibundel. Kamera adalah ilustrasi, sehingga aplikasi tidak meminta izin kamera atau mikrofon. Tidak ada koneksi Home Assistant, server BMT, akun atau telemetry.

All homes, cameras, energy, gas, guest access and controls use local simulated data. The UI supports Indonesian and English, light/dark/system themes and bundled Inter. Cameras are illustrations. No Home Assistant, BMT server, account or telemetry integration is enabled.

## Build simulator di Mac

Pasang Xcode, command-line tools, iOS Simulator dan CocoaPods. Gunakan Flutter 3.41.9, kemudian dari folder aplikasi:

```sh
bash tool/build-ios.sh
open -a Simulator
xcrun simctl bootstatus booted -b
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
xcrun simctl launch booted com.balimikroteknologi.smartpanel.demo
```

Jika belum ada simulator aktif, pilih dan boot iPhone lewat Xcode terlebih dahulu. Paket simulator `.app` hanya untuk simulator Mac. Workflow GitHub `Smart Panel iOS` menjalankan pemeriksaan kode, tes dan build simulator, lalu menyimpan ZIP `.app` sebagai artifact selama 14 hari.

Install Xcode, its command-line tools, an iOS Simulator and CocoaPods on a Mac. Run the commands above from this app directory. Boot an iPhone simulator first if none is running. The `.app` artifact is for a Mac simulator.

## iPhone fisik dan TestFlight

```sh
flutter pub get --enforce-lockfile
open ios/Runner.xcworkspace
```

Di target Runner → Signing & Capabilities, pilih Apple Development Team milik BMT dan bundle ID yang terdaftar. Sambungkan iPhone, aktifkan Developer Mode bila diminta, pilih perangkat, lalu Run. Untuk distribusi TestFlight, gunakan keanggotaan Apple Developer BMT dan jalankan `flutter build ipa --release`. Sertifikat, provisioning profile, Team ID dan kredensial Apple belum dikonfigurasi dalam repo.

Select BMT's Apple Development Team and a registered bundle ID in Xcode, connect the iPhone, enable Developer Mode when requested, and run. TestFlight distribution requires BMT's Apple Developer membership and signing configuration. No Apple credentials or signed IPA are included.

## Perilaku khusus iOS / iOS behavior

- Face ID/Touch ID mengonfirmasi tindakan simulasi. Izin Face ID mengikuti bahasa sistem iPhone; alasan dan tombol batal mengikuti bahasa aplikasi. Pembatalan atau biometrik tidak tersedia mengembalikan pengguna ke konfirmasi tahan.
- Notifikasi lokal meminta izin saat tombol uji dipilih, tanpa prompt ketika aplikasi pertama dibuka. Penolakan izin tetap mengizinkan overlay peringatan dalam aplikasi. Notifikasi kamera membawa gambar simulasi dan membuka kamera sesuai rumah/peran saat ini.
- Notifikasi memakai prioritas biasa. Suara/getar mengikuti pengaturan iPhone, silent dan Focus; tidak ada entitlement Apple Critical Alerts atau mode audio latar. Isyarat darurat native hanya satu bunyi pendek ketika aplikasi aktif.
- Simulasi gas Medium/High tetap bertanda **menunggu validasi BMT**. Demo ini bukan sistem keselamatan operasional.

Face ID/Touch ID confirms simulated actions; cancellation/unavailability keeps hold-to-confirm available. Local notification permission is requested on demand. Camera alerts carry a simulated image and respect current home/role access. Notifications and foreground sounds follow iPhone silent/Focus settings. Gas guidance is pending BMT validation.

## Pemeriksaan perangkat yang masih diperlukan

Uji startup, safe area iPhone, bahasa/tema, text scaling 200%, Face ID/Touch ID berhasil/batal/terkunci, izin notifikasi diterima/ditolak, membuka kamera dari notifikasi saat aplikasi ditutup, pergantian peran, seluruh S1–S10, mode offline, suara dan kembali dari background pada iPhone fisik. Build simulator/tes Dart belum membuktikan perilaku perangkat tersebut.

Physical iPhone acceptance remains required for these flows. Simulator compilation and Dart tests do not establish physical-device acceptance.

Rujukan: [Flutter: iOS setup](https://docs.flutter.dev/platform-integration/ios/setup), [Flutter: release iOS](https://docs.flutter.dev/deployment/ios), [local notifications 20.1.0](https://pub.dev/packages/flutter_local_notifications/versions/20.1.0), [local_auth 3.0.2](https://pub.dev/packages/local_auth/versions/3.0.2).
