import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @superseded.
  ///
  /// In id, this message translates to:
  /// **'Perintah digantikan oleh tindakan yang lebih baru.'**
  String get superseded;

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Smart Panel BMT'**
  String get appName;

  /// No description provided for @demo.
  ///
  /// In id, this message translates to:
  /// **'DEMO'**
  String get demo;

  /// No description provided for @simulation.
  ///
  /// In id, this message translates to:
  /// **'Simulasi'**
  String get simulation;

  /// No description provided for @home.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get home;

  /// No description provided for @rooms.
  ///
  /// In id, this message translates to:
  /// **'Ruang'**
  String get rooms;

  /// No description provided for @security.
  ///
  /// In id, this message translates to:
  /// **'Keamanan'**
  String get security;

  /// No description provided for @alerts.
  ///
  /// In id, this message translates to:
  /// **'Peringatan'**
  String get alerts;

  /// No description provided for @more.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get more;

  /// No description provided for @houseA.
  ///
  /// In id, this message translates to:
  /// **'Rumah Contoh A'**
  String get houseA;

  /// No description provided for @houseB.
  ///
  /// In id, this message translates to:
  /// **'Rumah Contoh B'**
  String get houseB;

  /// No description provided for @villa.
  ///
  /// In id, this message translates to:
  /// **'Villa Contoh'**
  String get villa;

  /// No description provided for @privateHome.
  ///
  /// In id, this message translates to:
  /// **'Rumah tinggal'**
  String get privateHome;

  /// No description provided for @rental.
  ///
  /// In id, this message translates to:
  /// **'Hunian sewa'**
  String get rental;

  /// No description provided for @basic.
  ///
  /// In id, this message translates to:
  /// **'Basic'**
  String get basic;

  /// No description provided for @medium.
  ///
  /// In id, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In id, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @custom.
  ///
  /// In id, this message translates to:
  /// **'Kustom'**
  String get custom;

  /// No description provided for @owner.
  ///
  /// In id, this message translates to:
  /// **'Pemilik'**
  String get owner;

  /// No description provided for @family.
  ///
  /// In id, this message translates to:
  /// **'Keluarga'**
  String get family;

  /// No description provided for @guest.
  ///
  /// In id, this message translates to:
  /// **'Tamu'**
  String get guest;

  /// No description provided for @technician.
  ///
  /// In id, this message translates to:
  /// **'Teknisi'**
  String get technician;

  /// No description provided for @atHome.
  ///
  /// In id, this message translates to:
  /// **'Di rumah'**
  String get atHome;

  /// No description provided for @localOffline.
  ///
  /// In id, this message translates to:
  /// **'Di rumah, tanpa internet'**
  String get localOffline;

  /// No description provided for @remote.
  ///
  /// In id, this message translates to:
  /// **'Jarak jauh'**
  String get remote;

  /// No description provided for @unreachable.
  ///
  /// In id, this message translates to:
  /// **'Tidak terjangkau'**
  String get unreachable;

  /// No description provided for @offlineBanner.
  ///
  /// In id, this message translates to:
  /// **'Tanpa internet. Kendali di rumah tetap berfungsi.'**
  String get offlineBanner;

  /// No description provided for @unreachableBanner.
  ///
  /// In id, this message translates to:
  /// **'Rumah tidak terjangkau. Yang berjalan di rumah tetap berjalan.'**
  String get unreachableBanner;

  /// No description provided for @lastKnown.
  ///
  /// In id, this message translates to:
  /// **'Keadaan terakhir'**
  String get lastKnown;

  /// No description provided for @updated.
  ///
  /// In id, this message translates to:
  /// **'Diperbarui'**
  String get updated;

  /// No description provided for @safeHome.
  ///
  /// In id, this message translates to:
  /// **'Rumah aman'**
  String get safeHome;

  /// No description provided for @normalFoundations.
  ///
  /// In id, this message translates to:
  /// **'Semua fondasi normal.'**
  String get normalFoundations;

  /// No description provided for @needsAttention.
  ///
  /// In id, this message translates to:
  /// **'Perlu perhatian'**
  String get needsAttention;

  /// No description provided for @criticalTitle.
  ///
  /// In id, this message translates to:
  /// **'Darurat'**
  String get criticalTitle;

  /// No description provided for @criticalReason.
  ///
  /// In id, this message translates to:
  /// **'Ada peringatan yang perlu Anda lihat.'**
  String get criticalReason;

  /// No description provided for @seeStatus.
  ///
  /// In id, this message translates to:
  /// **'Lihat status'**
  String get seeStatus;

  /// No description provided for @seeAlert.
  ///
  /// In id, this message translates to:
  /// **'Lihat peringatan'**
  String get seeAlert;

  /// No description provided for @quickScenes.
  ///
  /// In id, this message translates to:
  /// **'Adegan cepat'**
  String get quickScenes;

  /// No description provided for @morning.
  ///
  /// In id, this message translates to:
  /// **'Pagi'**
  String get morning;

  /// No description provided for @night.
  ///
  /// In id, this message translates to:
  /// **'Malam'**
  String get night;

  /// No description provided for @guestScene.
  ///
  /// In id, this message translates to:
  /// **'Tamu'**
  String get guestScene;

  /// No description provided for @away.
  ///
  /// In id, this message translates to:
  /// **'Pergi'**
  String get away;

  /// No description provided for @foundations.
  ///
  /// In id, this message translates to:
  /// **'Lima fondasi'**
  String get foundations;

  /// No description provided for @electricity.
  ///
  /// In id, this message translates to:
  /// **'Listrik'**
  String get electricity;

  /// No description provided for @water.
  ///
  /// In id, this message translates to:
  /// **'Air'**
  String get water;

  /// No description provided for @wifi.
  ///
  /// In id, this message translates to:
  /// **'Wi-Fi'**
  String get wifi;

  /// No description provided for @gas.
  ///
  /// In id, this message translates to:
  /// **'Gas'**
  String get gas;

  /// No description provided for @cctv.
  ///
  /// In id, this message translates to:
  /// **'CCTV'**
  String get cctv;

  /// No description provided for @favourites.
  ///
  /// In id, this message translates to:
  /// **'Favorit'**
  String get favourites;

  /// No description provided for @allDevices.
  ///
  /// In id, this message translates to:
  /// **'Semua perangkat'**
  String get allDevices;

  /// No description provided for @normal.
  ///
  /// In id, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @safe.
  ///
  /// In id, this message translates to:
  /// **'Aman'**
  String get safe;

  /// No description provided for @tank.
  ///
  /// In id, this message translates to:
  /// **'Tandon'**
  String get tank;

  /// No description provided for @devices.
  ///
  /// In id, this message translates to:
  /// **'perangkat'**
  String get devices;

  /// No description provided for @camerasOnline.
  ///
  /// In id, this message translates to:
  /// **'kamera online'**
  String get camerasOnline;

  /// No description provided for @on.
  ///
  /// In id, this message translates to:
  /// **'Hidup'**
  String get on;

  /// No description provided for @off.
  ///
  /// In id, this message translates to:
  /// **'Mati'**
  String get off;

  /// No description provided for @noPower.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada listrik'**
  String get noPower;

  /// No description provided for @gasNoPower.
  ///
  /// In id, this message translates to:
  /// **'Detektor gas tidak punya daya'**
  String get gasNoPower;

  /// No description provided for @lowBattery.
  ///
  /// In id, this message translates to:
  /// **'Baterai lemah'**
  String get lowBattery;

  /// No description provided for @mainLight.
  ///
  /// In id, this message translates to:
  /// **'Lampu utama'**
  String get mainLight;

  /// No description provided for @readingLight.
  ///
  /// In id, this message translates to:
  /// **'Lampu baca'**
  String get readingLight;

  /// No description provided for @airConditioner.
  ///
  /// In id, this message translates to:
  /// **'AC kamar'**
  String get airConditioner;

  /// No description provided for @curtain.
  ///
  /// In id, this message translates to:
  /// **'Tirai'**
  String get curtain;

  /// No description provided for @doorLock.
  ///
  /// In id, this message translates to:
  /// **'Kunci pintu utama'**
  String get doorLock;

  /// No description provided for @cloudRobot.
  ///
  /// In id, this message translates to:
  /// **'Robot pembersih'**
  String get cloudRobot;

  /// No description provided for @living.
  ///
  /// In id, this message translates to:
  /// **'Ruang keluarga'**
  String get living;

  /// No description provided for @bedroom.
  ///
  /// In id, this message translates to:
  /// **'Kamar tidur'**
  String get bedroom;

  /// No description provided for @kitchen.
  ///
  /// In id, this message translates to:
  /// **'Dapur'**
  String get kitchen;

  /// No description provided for @bathroom.
  ///
  /// In id, this message translates to:
  /// **'Kamar mandi'**
  String get bathroom;

  /// No description provided for @terrace.
  ///
  /// In id, this message translates to:
  /// **'Teras'**
  String get terrace;

  /// No description provided for @bedroomTwo.
  ///
  /// In id, this message translates to:
  /// **'Kamar tidur kedua'**
  String get bedroomTwo;

  /// No description provided for @carport.
  ///
  /// In id, this message translates to:
  /// **'Carport'**
  String get carport;

  /// No description provided for @gate.
  ///
  /// In id, this message translates to:
  /// **'Gerbang'**
  String get gate;

  /// No description provided for @frontGate.
  ///
  /// In id, this message translates to:
  /// **'Pagar depan'**
  String get frontGate;

  /// No description provided for @wallSwitch.
  ///
  /// In id, this message translates to:
  /// **'Saklar dinding'**
  String get wallSwitch;

  /// No description provided for @automation.
  ///
  /// In id, this message translates to:
  /// **'Otomasi'**
  String get automation;

  /// No description provided for @local.
  ///
  /// In id, this message translates to:
  /// **'Lokal'**
  String get local;

  /// No description provided for @cloudDependent.
  ///
  /// In id, this message translates to:
  /// **'Bergantung internet'**
  String get cloudDependent;

  /// No description provided for @source.
  ///
  /// In id, this message translates to:
  /// **'Sumber'**
  String get source;

  /// No description provided for @sent.
  ///
  /// In id, this message translates to:
  /// **'Perintah dikirim'**
  String get sent;

  /// No description provided for @confirmed.
  ///
  /// In id, this message translates to:
  /// **'Terkonfirmasi'**
  String get confirmed;

  /// No description provided for @failed.
  ///
  /// In id, this message translates to:
  /// **'Perintah gagal'**
  String get failed;

  /// No description provided for @unconfirmed.
  ///
  /// In id, this message translates to:
  /// **'Perintah tidak sampai'**
  String get unconfirmed;

  /// No description provided for @waitingEvidence.
  ///
  /// In id, this message translates to:
  /// **'Menunggu bukti daya'**
  String get waitingEvidence;

  /// No description provided for @measuredPower.
  ///
  /// In id, this message translates to:
  /// **'Daya terukur'**
  String get measuredPower;

  /// No description provided for @tryAgain.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get tryAgain;

  /// No description provided for @noConnectionReason.
  ///
  /// In id, this message translates to:
  /// **'Jalur ke rumah tidak tersedia.'**
  String get noConnectionReason;

  /// No description provided for @cloudOfflineReason.
  ///
  /// In id, this message translates to:
  /// **'Perangkat ini memerlukan internet.'**
  String get cloudOfflineReason;

  /// No description provided for @noEvidenceReason.
  ///
  /// In id, this message translates to:
  /// **'Bukti daya belum diterima dalam 8 detik.'**
  String get noEvidenceReason;

  /// No description provided for @noPermission.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak memiliki akses.'**
  String get noPermission;

  /// No description provided for @notInPackage.
  ///
  /// In id, this message translates to:
  /// **'Fitur belum termasuk paket ini.'**
  String get notInPackage;

  /// No description provided for @circuits.
  ///
  /// In id, this message translates to:
  /// **'Rincian sirkuit'**
  String get circuits;

  /// No description provided for @applianceRanking.
  ///
  /// In id, this message translates to:
  /// **'Peringkat per alat'**
  String get applianceRanking;

  /// No description provided for @waterZones.
  ///
  /// In id, this message translates to:
  /// **'Pemakaian per zona'**
  String get waterZones;

  /// No description provided for @waterValve.
  ///
  /// In id, this message translates to:
  /// **'Katup air utama'**
  String get waterValve;

  /// No description provided for @guestWifi.
  ///
  /// In id, this message translates to:
  /// **'Wi-Fi tamu'**
  String get guestWifi;

  /// No description provided for @guestRotation.
  ///
  /// In id, this message translates to:
  /// **'Sandi tamu otomatis'**
  String get guestRotation;

  /// No description provided for @gasActions.
  ///
  /// In id, this message translates to:
  /// **'Tindakan otomatis'**
  String get gasActions;

  /// No description provided for @gasValve.
  ///
  /// In id, this message translates to:
  /// **'Katup gas'**
  String get gasValve;

  /// No description provided for @recording.
  ///
  /// In id, this message translates to:
  /// **'Rekaman kamera'**
  String get recording;

  /// No description provided for @personDetection.
  ///
  /// In id, this message translates to:
  /// **'Deteksi orang'**
  String get personDetection;

  /// No description provided for @climate.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan AC'**
  String get climate;

  /// No description provided for @curtains.
  ///
  /// In id, this message translates to:
  /// **'Kontrol tirai'**
  String get curtains;

  /// No description provided for @alarm.
  ///
  /// In id, this message translates to:
  /// **'Alarm'**
  String get alarm;

  /// No description provided for @members.
  ///
  /// In id, this message translates to:
  /// **'Anggota dan peran'**
  String get members;

  /// No description provided for @energy.
  ///
  /// In id, this message translates to:
  /// **'Energi'**
  String get energy;

  /// No description provided for @accessCodes.
  ///
  /// In id, this message translates to:
  /// **'Kode akses'**
  String get accessCodes;

  /// No description provided for @remoteGuestCodes.
  ///
  /// In id, this message translates to:
  /// **'Kode tamu jarak jauh'**
  String get remoteGuestCodes;

  /// No description provided for @cloudDevice.
  ///
  /// In id, this message translates to:
  /// **'Perangkat bergantung internet'**
  String get cloudDevice;

  /// No description provided for @currentPower.
  ///
  /// In id, this message translates to:
  /// **'Daya sekarang'**
  String get currentPower;

  /// No description provided for @voltage.
  ///
  /// In id, this message translates to:
  /// **'Tegangan'**
  String get voltage;

  /// No description provided for @installedPower.
  ///
  /// In id, this message translates to:
  /// **'Daya PLN'**
  String get installedPower;

  /// No description provided for @today.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get today;

  /// No description provided for @thisMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan ini'**
  String get thisMonth;

  /// No description provided for @day.
  ///
  /// In id, this message translates to:
  /// **'Hari'**
  String get day;

  /// No description provided for @week.
  ///
  /// In id, this message translates to:
  /// **'Minggu'**
  String get week;

  /// No description provided for @month.
  ///
  /// In id, this message translates to:
  /// **'Bulan'**
  String get month;

  /// No description provided for @consumption.
  ///
  /// In id, this message translates to:
  /// **'Pemakaian'**
  String get consumption;

  /// No description provided for @powerTrend.
  ///
  /// In id, this message translates to:
  /// **'Grafik daya'**
  String get powerTrend;

  /// No description provided for @tankCapacity.
  ///
  /// In id, this message translates to:
  /// **'Kapasitas tangki 1.000 L'**
  String get tankCapacity;

  /// No description provided for @noLeak.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kebocoran terdeteksi'**
  String get noLeak;

  /// No description provided for @quality.
  ///
  /// In id, this message translates to:
  /// **'Kualitas air'**
  String get quality;

  /// No description provided for @good.
  ///
  /// In id, this message translates to:
  /// **'Baik'**
  String get good;

  /// No description provided for @connected.
  ///
  /// In id, this message translates to:
  /// **'Tersambung'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In id, this message translates to:
  /// **'Putus'**
  String get disconnected;

  /// No description provided for @latency.
  ///
  /// In id, this message translates to:
  /// **'Latensi'**
  String get latency;

  /// No description provided for @deviceNetwork.
  ///
  /// In id, this message translates to:
  /// **'Jaringan perangkat'**
  String get deviceNetwork;

  /// No description provided for @lastTest.
  ///
  /// In id, this message translates to:
  /// **'Terakhir diuji 12 hari lalu'**
  String get lastTest;

  /// No description provided for @testAlarm.
  ///
  /// In id, this message translates to:
  /// **'Uji alarm'**
  String get testAlarm;

  /// No description provided for @detectorExplanation.
  ///
  /// In id, this message translates to:
  /// **'Detektor berbunyi sendiri tanpa aplikasi.'**
  String get detectorExplanation;

  /// No description provided for @powerOffBanner.
  ///
  /// In id, this message translates to:
  /// **'PLN padam. Smart Panel memakai daya cadangan.'**
  String get powerOffBanner;

  /// No description provided for @gallery.
  ///
  /// In id, this message translates to:
  /// **'Galeri komponen'**
  String get gallery;

  /// No description provided for @gallerySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjau tampilan dan interaksi dalam setiap kondisi.'**
  String get gallerySubtitle;

  /// No description provided for @galleryStates.
  ///
  /// In id, this message translates to:
  /// **'Kondisi komponen'**
  String get galleryStates;

  /// No description provided for @pressed.
  ///
  /// In id, this message translates to:
  /// **'Ditekan'**
  String get pressed;

  /// No description provided for @disabled.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get disabled;

  /// No description provided for @loading.
  ///
  /// In id, this message translates to:
  /// **'Memuat'**
  String get loading;

  /// No description provided for @empty.
  ///
  /// In id, this message translates to:
  /// **'Kosong'**
  String get empty;

  /// No description provided for @error.
  ///
  /// In id, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @locked.
  ///
  /// In id, this message translates to:
  /// **'Terkunci paket'**
  String get locked;

  /// No description provided for @statusCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu status utama'**
  String get statusCard;

  /// No description provided for @connectionChip.
  ///
  /// In id, this message translates to:
  /// **'Chip koneksi'**
  String get connectionChip;

  /// No description provided for @foundationCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu fondasi'**
  String get foundationCard;

  /// No description provided for @deviceTile.
  ///
  /// In id, this message translates to:
  /// **'Ubin perangkat'**
  String get deviceTile;

  /// No description provided for @dimmer.
  ///
  /// In id, this message translates to:
  /// **'Redup lampu'**
  String get dimmer;

  /// No description provided for @climateCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu AC'**
  String get climateCard;

  /// No description provided for @curtainControl.
  ///
  /// In id, this message translates to:
  /// **'Kontrol tirai'**
  String get curtainControl;

  /// No description provided for @lockControl.
  ///
  /// In id, this message translates to:
  /// **'Kontrol kunci'**
  String get lockControl;

  /// No description provided for @scenePills.
  ///
  /// In id, this message translates to:
  /// **'Pil adegan'**
  String get scenePills;

  /// No description provided for @alertCards.
  ///
  /// In id, this message translates to:
  /// **'Kartu peringatan'**
  String get alertCards;

  /// No description provided for @charts.
  ///
  /// In id, this message translates to:
  /// **'Grafik'**
  String get charts;

  /// No description provided for @powerGauge.
  ///
  /// In id, this message translates to:
  /// **'Pengukur daya'**
  String get powerGauge;

  /// No description provided for @tankLevel.
  ///
  /// In id, this message translates to:
  /// **'Level tandon'**
  String get tankLevel;

  /// No description provided for @cameraTile.
  ///
  /// In id, this message translates to:
  /// **'Ubin kamera'**
  String get cameraTile;

  /// No description provided for @timeline.
  ///
  /// In id, this message translates to:
  /// **'Timeline dan playback'**
  String get timeline;

  /// No description provided for @guestCode.
  ///
  /// In id, this message translates to:
  /// **'Kode tamu'**
  String get guestCode;

  /// No description provided for @roleBadges.
  ///
  /// In id, this message translates to:
  /// **'Lencana peran'**
  String get roleBadges;

  /// No description provided for @lockedCard.
  ///
  /// In id, this message translates to:
  /// **'Fitur terkunci'**
  String get lockedCard;

  /// No description provided for @screenStates.
  ///
  /// In id, this message translates to:
  /// **'Keadaan layar'**
  String get screenStates;

  /// No description provided for @confirmation.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi tindakan'**
  String get confirmation;

  /// No description provided for @commandFeedback.
  ///
  /// In id, this message translates to:
  /// **'Status perintah'**
  String get commandFeedback;

  /// No description provided for @demoPanel.
  ///
  /// In id, this message translates to:
  /// **'Mode Demo'**
  String get demoPanel;

  /// No description provided for @theme.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In id, this message translates to:
  /// **'Ikut sistem'**
  String get system;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @indonesian.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get indonesian;

  /// No description provided for @english.
  ///
  /// In id, this message translates to:
  /// **'Inggris'**
  String get english;

  /// No description provided for @reduceMotion.
  ///
  /// In id, this message translates to:
  /// **'Kurangi gerak'**
  String get reduceMotion;

  /// No description provided for @settings.
  ///
  /// In id, this message translates to:
  /// **'Tampilan dan bahasa'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get about;

  /// No description provided for @history.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get history;

  /// No description provided for @version.
  ///
  /// In id, this message translates to:
  /// **'Versi aplikasi'**
  String get version;

  /// No description provided for @buildTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu build'**
  String get buildTime;

  /// No description provided for @buildTimeUnknown.
  ///
  /// In id, this message translates to:
  /// **'Belum dicatat'**
  String get buildTimeUnknown;

  /// No description provided for @offlineDemo.
  ///
  /// In id, this message translates to:
  /// **'Semua data tiruan, tanpa server.'**
  String get offlineDemo;

  /// No description provided for @notProof.
  ///
  /// In id, this message translates to:
  /// **'Demo ini tidak membuktikan perilaku perangkat nyata.'**
  String get notProof;

  /// No description provided for @licences.
  ///
  /// In id, this message translates to:
  /// **'Lisensi'**
  String get licences;

  /// No description provided for @chooseHome.
  ///
  /// In id, this message translates to:
  /// **'Pilih rumah'**
  String get chooseHome;

  /// No description provided for @profile.
  ///
  /// In id, this message translates to:
  /// **'Profil rumah'**
  String get profile;

  /// No description provided for @package.
  ///
  /// In id, this message translates to:
  /// **'Paket'**
  String get package;

  /// No description provided for @role.
  ///
  /// In id, this message translates to:
  /// **'Peran'**
  String get role;

  /// No description provided for @phoneLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi ponsel'**
  String get phoneLocation;

  /// No description provided for @outside.
  ///
  /// In id, this message translates to:
  /// **'Di luar rumah'**
  String get outside;

  /// No description provided for @homeInternet.
  ///
  /// In id, this message translates to:
  /// **'Internet rumah'**
  String get homeInternet;

  /// No description provided for @outsidePackage.
  ///
  /// In id, this message translates to:
  /// **'Fitur di luar paket'**
  String get outsidePackage;

  /// No description provided for @hide.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan'**
  String get hide;

  /// No description provided for @showLocked.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan terkunci'**
  String get showLocked;

  /// No description provided for @time.
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get time;

  /// No description provided for @daytime.
  ///
  /// In id, this message translates to:
  /// **'Siang'**
  String get daytime;

  /// No description provided for @speed.
  ///
  /// In id, this message translates to:
  /// **'Kecepatan waktu'**
  String get speed;

  /// No description provided for @reset.
  ///
  /// In id, this message translates to:
  /// **'Reset profil'**
  String get reset;

  /// No description provided for @resetDone.
  ///
  /// In id, this message translates to:
  /// **'Profil dikembalikan ke keadaan awal.'**
  String get resetDone;

  /// No description provided for @screenCondition.
  ///
  /// In id, this message translates to:
  /// **'Kondisi layar'**
  String get screenCondition;

  /// No description provided for @close.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @acknowledge.
  ///
  /// In id, this message translates to:
  /// **'Saya mengerti, tutup'**
  String get acknowledge;

  /// No description provided for @criticalPreview.
  ///
  /// In id, this message translates to:
  /// **'Contoh peringatan kritis'**
  String get criticalPreview;

  /// No description provided for @criticalPreviewBody.
  ///
  /// In id, this message translates to:
  /// **'Ini pratinjau tampilan darurat dengan data tiruan.'**
  String get criticalPreviewBody;

  /// No description provided for @acknowledgeNote.
  ///
  /// In id, this message translates to:
  /// **'Mengakui hanya menutup peringatan. Sumber bahaya belum tentu kembali normal.'**
  String get acknowledgeNote;

  /// No description provided for @safetyPending.
  ///
  /// In id, this message translates to:
  /// **'Panduan keselamatan menunggu validasi BMT.'**
  String get safetyPending;

  /// No description provided for @openEmergency.
  ///
  /// In id, this message translates to:
  /// **'Pratinjau overlay darurat'**
  String get openEmergency;

  /// No description provided for @critical.
  ///
  /// In id, this message translates to:
  /// **'Kritis'**
  String get critical;

  /// No description provided for @important.
  ///
  /// In id, this message translates to:
  /// **'Penting'**
  String get important;

  /// No description provided for @info.
  ///
  /// In id, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @voltageAlert.
  ///
  /// In id, this message translates to:
  /// **'Tegangan perlu diperiksa'**
  String get voltageAlert;

  /// No description provided for @batteryAlert.
  ///
  /// In id, this message translates to:
  /// **'Baterai sensor lemah'**
  String get batteryAlert;

  /// No description provided for @noAlerts.
  ///
  /// In id, this message translates to:
  /// **'Belum ada peringatan'**
  String get noAlerts;

  /// No description provided for @noAlertsBody.
  ///
  /// In id, this message translates to:
  /// **'Peringatan baru akan muncul di sini.'**
  String get noAlertsBody;

  /// No description provided for @noData.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data'**
  String get noData;

  /// No description provided for @noDataBody.
  ///
  /// In id, this message translates to:
  /// **'Data akan ditampilkan saat tersedia.'**
  String get noDataBody;

  /// No description provided for @loadError.
  ///
  /// In id, this message translates to:
  /// **'Data belum dapat dimuat'**
  String get loadError;

  /// No description provided for @loadErrorBody.
  ///
  /// In id, this message translates to:
  /// **'Coba muat kembali data rumah.'**
  String get loadErrorBody;

  /// No description provided for @holdToConfirm.
  ///
  /// In id, this message translates to:
  /// **'Tahan untuk konfirmasi'**
  String get holdToConfirm;

  /// No description provided for @holdHint.
  ///
  /// In id, this message translates to:
  /// **'Tahan 1,5 detik. Lepaskan untuk membatalkan.'**
  String get holdHint;

  /// No description provided for @unlock.
  ///
  /// In id, this message translates to:
  /// **'Buka kunci'**
  String get unlock;

  /// No description provided for @lock.
  ///
  /// In id, this message translates to:
  /// **'Kunci pintu'**
  String get lock;

  /// No description provided for @lockedDoor.
  ///
  /// In id, this message translates to:
  /// **'Terkunci'**
  String get lockedDoor;

  /// No description provided for @unlockedDoor.
  ///
  /// In id, this message translates to:
  /// **'Terbuka'**
  String get unlockedDoor;

  /// No description provided for @unlockQuestion.
  ///
  /// In id, this message translates to:
  /// **'Buka kunci pintu utama?'**
  String get unlockQuestion;

  /// No description provided for @unlockConsequence.
  ///
  /// In id, this message translates to:
  /// **'Orang dapat masuk setelah terbuka.'**
  String get unlockConsequence;

  /// No description provided for @battery.
  ///
  /// In id, this message translates to:
  /// **'Baterai'**
  String get battery;

  /// No description provided for @open.
  ///
  /// In id, this message translates to:
  /// **'Buka'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In id, this message translates to:
  /// **'Tertutup'**
  String get closed;

  /// No description provided for @curtainPosition.
  ///
  /// In id, this message translates to:
  /// **'Posisi tirai'**
  String get curtainPosition;

  /// No description provided for @temperature.
  ///
  /// In id, this message translates to:
  /// **'Suhu'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In id, this message translates to:
  /// **'Kelembapan'**
  String get humidity;

  /// No description provided for @audioOff.
  ///
  /// In id, this message translates to:
  /// **'Audio mati'**
  String get audioOff;

  /// No description provided for @live.
  ///
  /// In id, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @privacyArea.
  ///
  /// In id, this message translates to:
  /// **'Area privasi'**
  String get privacyArea;

  /// No description provided for @motion.
  ///
  /// In id, this message translates to:
  /// **'Gerakan'**
  String get motion;

  /// No description provided for @cameraAccess.
  ///
  /// In id, this message translates to:
  /// **'Akses kamera dicatat'**
  String get cameraAccess;

  /// No description provided for @playback.
  ///
  /// In id, this message translates to:
  /// **'Putar ulang simulasi'**
  String get playback;

  /// No description provided for @sampleGuest.
  ///
  /// In id, this message translates to:
  /// **'Maya Contoh'**
  String get sampleGuest;

  /// No description provided for @validUntil.
  ///
  /// In id, this message translates to:
  /// **'Berlaku sampai'**
  String get validUntil;

  /// No description provided for @showCode.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan kode'**
  String get showCode;

  /// No description provided for @hideCode.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan kode'**
  String get hideCode;

  /// No description provided for @sampleOnly.
  ///
  /// In id, this message translates to:
  /// **'Contoh'**
  String get sampleOnly;

  /// No description provided for @wifiQr.
  ///
  /// In id, this message translates to:
  /// **'QR Wi-Fi tamu — contoh'**
  String get wifiQr;

  /// No description provided for @guestWelcome.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang'**
  String get guestWelcome;

  /// No description provided for @lights.
  ///
  /// In id, this message translates to:
  /// **'Lampu'**
  String get lights;

  /// No description provided for @ambience.
  ///
  /// In id, this message translates to:
  /// **'Suasana'**
  String get ambience;

  /// No description provided for @help.
  ///
  /// In id, this message translates to:
  /// **'Bantuan'**
  String get help;

  /// No description provided for @guestHelp.
  ///
  /// In id, this message translates to:
  /// **'Hubungi pengelola melalui informasi di villa.'**
  String get guestHelp;

  /// No description provided for @diagnostics.
  ///
  /// In id, this message translates to:
  /// **'Diagnosa perangkat'**
  String get diagnostics;

  /// No description provided for @diagnosticNote.
  ///
  /// In id, this message translates to:
  /// **'Akses teknisi terbatas waktu dan dapat dicabut.'**
  String get diagnosticNote;

  /// No description provided for @notifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notifications;

  /// No description provided for @notificationTest.
  ///
  /// In id, this message translates to:
  /// **'Uji notifikasi lokal'**
  String get notificationTest;

  /// No description provided for @notificationBlocked.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi ponsel tidak tersedia pada jalur ini.'**
  String get notificationBlocked;

  /// No description provided for @notificationDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin notifikasi belum diberikan.'**
  String get notificationDenied;

  /// No description provided for @notificationSent.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi contoh ditampilkan.'**
  String get notificationSent;

  /// No description provided for @notificationTitle.
  ///
  /// In id, this message translates to:
  /// **'Peringatan contoh Smart Panel'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In id, this message translates to:
  /// **'Data tiruan untuk meninjau tampilan notifikasi.'**
  String get notificationBody;

  /// No description provided for @demoLogoHint.
  ///
  /// In id, this message translates to:
  /// **'Tahan logo 2 detik untuk Mode Demo'**
  String get demoLogoHint;

  /// No description provided for @all.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get all;

  /// No description provided for @brightness.
  ///
  /// In id, this message translates to:
  /// **'Kecerahan'**
  String get brightness;

  /// No description provided for @sampleAction.
  ///
  /// In id, this message translates to:
  /// **'Peragakan perintah'**
  String get sampleAction;

  /// No description provided for @wallSwitchAction.
  ///
  /// In id, this message translates to:
  /// **'Simulasikan saklar dinding'**
  String get wallSwitchAction;

  /// No description provided for @evidence.
  ///
  /// In id, this message translates to:
  /// **'Bukti daya AC'**
  String get evidence;

  /// No description provided for @evidencePresent.
  ///
  /// In id, this message translates to:
  /// **'Diterima'**
  String get evidencePresent;

  /// No description provided for @evidenceAbsent.
  ///
  /// In id, this message translates to:
  /// **'Tidak datang'**
  String get evidenceAbsent;

  /// No description provided for @allRead.
  ///
  /// In id, this message translates to:
  /// **'Sudah diakui'**
  String get allRead;

  /// No description provided for @noHistory.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kejadian'**
  String get noHistory;

  /// No description provided for @filter.
  ///
  /// In id, this message translates to:
  /// **'Saring'**
  String get filter;

  /// No description provided for @wita.
  ///
  /// In id, this message translates to:
  /// **'WITA'**
  String get wita;

  /// No description provided for @wifiSsid.
  ///
  /// In id, this message translates to:
  /// **'BMT-Tamu-Contoh'**
  String get wifiSsid;

  /// No description provided for @wifiPassword.
  ///
  /// In id, this message translates to:
  /// **'ContohSaja2026'**
  String get wifiPassword;

  /// No description provided for @requestSent.
  ///
  /// In id, this message translates to:
  /// **'Permintaan dikirim'**
  String get requestSent;

  /// No description provided for @reviewBuild.
  ///
  /// In id, this message translates to:
  /// **'Build tinjauan visual'**
  String get reviewBuild;

  /// No description provided for @foundationNotice.
  ///
  /// In id, this message translates to:
  /// **'Fondasi dan galeri komponen untuk tinjauan BMT.'**
  String get foundationNotice;

  /// No description provided for @phaseThreeNotice.
  ///
  /// In id, this message translates to:
  /// **'Skenario S1–S6 disiapkan setelah tinjauan visual.'**
  String get phaseThreeNotice;

  /// No description provided for @start.
  ///
  /// In id, this message translates to:
  /// **'Jalankan'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In id, this message translates to:
  /// **'Hentikan'**
  String get stop;

  /// No description provided for @externalContact.
  ///
  /// In id, this message translates to:
  /// **'Kontak darurat — simulasi'**
  String get externalContact;

  /// No description provided for @contactPreview.
  ///
  /// In id, this message translates to:
  /// **'Pratinjau kontak. Tidak ada panggilan yang dilakukan.'**
  String get contactPreview;

  /// No description provided for @idle.
  ///
  /// In id, this message translates to:
  /// **'Siap'**
  String get idle;

  /// No description provided for @qrHint.
  ///
  /// In id, this message translates to:
  /// **'QR ini berisi jaringan dan sandi fiktif.'**
  String get qrHint;

  /// No description provided for @pln.
  ///
  /// In id, this message translates to:
  /// **'Listrik rumah'**
  String get pln;

  /// No description provided for @onlyLocal.
  ///
  /// In id, this message translates to:
  /// **'Kendali lokal'**
  String get onlyLocal;

  /// No description provided for @status.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @sceneApplied.
  ///
  /// In id, this message translates to:
  /// **'Adegan dikirim ke perangkat yang tersedia.'**
  String get sceneApplied;

  /// No description provided for @fan.
  ///
  /// In id, this message translates to:
  /// **'Kipas buang'**
  String get fan;

  /// No description provided for @airQuality.
  ///
  /// In id, this message translates to:
  /// **'Kualitas udara'**
  String get airQuality;

  /// No description provided for @sampleCameraEvent.
  ///
  /// In id, this message translates to:
  /// **'Gerakan di pagar depan'**
  String get sampleCameraEvent;

  /// No description provided for @acknowledgeAlert.
  ///
  /// In id, this message translates to:
  /// **'Akui peringatan'**
  String get acknowledgeAlert;

  /// No description provided for @viewGallery.
  ///
  /// In id, this message translates to:
  /// **'Buka galeri komponen'**
  String get viewGallery;

  /// No description provided for @reviewSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan tinjauan'**
  String get reviewSettings;

  /// No description provided for @porchLight.
  ///
  /// In id, this message translates to:
  /// **'Lampu teras'**
  String get porchLight;

  /// No description provided for @gateMotor.
  ///
  /// In id, this message translates to:
  /// **'Gerbang'**
  String get gateMotor;

  /// No description provided for @alarmSiren.
  ///
  /// In id, this message translates to:
  /// **'Sirene alarm'**
  String get alarmSiren;

  /// No description provided for @pump.
  ///
  /// In id, this message translates to:
  /// **'Pompa air'**
  String get pump;

  /// No description provided for @kitchenPlug.
  ///
  /// In id, this message translates to:
  /// **'Colokan dapur'**
  String get kitchenPlug;

  /// No description provided for @exhaustFan.
  ///
  /// In id, this message translates to:
  /// **'Kipas dapur'**
  String get exhaustFan;

  /// No description provided for @waterHeater.
  ///
  /// In id, this message translates to:
  /// **'Pemanas air'**
  String get waterHeater;

  /// No description provided for @doorSensor.
  ///
  /// In id, this message translates to:
  /// **'Sensor pintu'**
  String get doorSensor;

  /// No description provided for @leakSensor.
  ///
  /// In id, this message translates to:
  /// **'Sensor bawah wastafel'**
  String get leakSensor;

  /// No description provided for @gasLeak.
  ///
  /// In id, this message translates to:
  /// **'Gas terdeteksi di dapur'**
  String get gasLeak;

  /// No description provided for @waterLeak.
  ///
  /// In id, this message translates to:
  /// **'Air terdeteksi di bawah wastafel'**
  String get waterLeak;

  /// No description provided for @powerOutage.
  ///
  /// In id, this message translates to:
  /// **'PLN padam'**
  String get powerOutage;

  /// No description provided for @powerRestored.
  ///
  /// In id, this message translates to:
  /// **'PLN kembali menyala'**
  String get powerRestored;

  /// No description provided for @loadShed.
  ///
  /// In id, this message translates to:
  /// **'Beban pemanas air diputus'**
  String get loadShed;

  /// No description provided for @gasDetected.
  ///
  /// In id, this message translates to:
  /// **'Sumber gas masih terdeteksi'**
  String get gasDetected;

  /// No description provided for @gasNormal.
  ///
  /// In id, this message translates to:
  /// **'Sumber gas kembali normal'**
  String get gasNormal;

  /// No description provided for @gasValveClosed.
  ///
  /// In id, this message translates to:
  /// **'Katup gas tertutup • reset fisik diperlukan'**
  String get gasValveClosed;

  /// No description provided for @gasActionsApplied.
  ///
  /// In id, this message translates to:
  /// **'Simulasi: colokan dapur mati, kipas menyala'**
  String get gasActionsApplied;

  /// No description provided for @physicalReset.
  ///
  /// In id, this message translates to:
  /// **'Simulasikan reset fisik katup gas'**
  String get physicalReset;

  /// No description provided for @normalizeGas.
  ///
  /// In id, this message translates to:
  /// **'Simulasikan sumber gas kembali normal'**
  String get normalizeGas;

  /// No description provided for @twoSources.
  ///
  /// In id, this message translates to:
  /// **'Dua sumber cocok: sensor basah dan aliran tidak wajar'**
  String get twoSources;

  /// No description provided for @wetLocation.
  ///
  /// In id, this message translates to:
  /// **'Sensor basah: bawah wastafel dapur'**
  String get wetLocation;

  /// No description provided for @abnormalFlow.
  ///
  /// In id, this message translates to:
  /// **'Aliran tidak wajar: 18 L/menit'**
  String get abnormalFlow;

  /// No description provided for @valveReopen.
  ///
  /// In id, this message translates to:
  /// **'Buka kembali katup air'**
  String get valveReopen;

  /// No description provided for @valveConsequence.
  ///
  /// In id, this message translates to:
  /// **'Air akan mengalir kembali. Sumber bocor masih tercatat; periksa kondisi lokasi.'**
  String get valveConsequence;

  /// No description provided for @backup90.
  ///
  /// In id, this message translates to:
  /// **'Smart Panel berjalan dari daya cadangan, perkiraan 90 menit. Perangkat baterai tetap tersedia.'**
  String get backup90;

  /// No description provided for @restorationSummary.
  ///
  /// In id, this message translates to:
  /// **'PLN pulih. Perangkat kembali terhubung; perintah gagal tidak diulang otomatis.'**
  String get restorationSummary;

  /// No description provided for @circuitKitchen.
  ///
  /// In id, this message translates to:
  /// **'Sirkuit dapur • MCB terindikasi trip'**
  String get circuitKitchen;

  /// No description provided for @circuitLights.
  ///
  /// In id, this message translates to:
  /// **'Sirkuit lampu • normal • 210 W'**
  String get circuitLights;

  /// No description provided for @circuitSockets.
  ///
  /// In id, this message translates to:
  /// **'Sirkuit colokan • normal • 830 W'**
  String get circuitSockets;

  /// No description provided for @loadWarning.
  ///
  /// In id, this message translates to:
  /// **'Melewati 85% kapasitas terpasang'**
  String get loadWarning;

  /// No description provided for @graphMarker.
  ///
  /// In id, this message translates to:
  /// **'Penanda anomali • 264 V • sirkuit dapur'**
  String get graphMarker;

  /// No description provided for @rankingSample.
  ///
  /// In id, this message translates to:
  /// **'Hari ini: pemanas air 5,6 kWh · AC 4,2 kWh · lampu 1,1 kWh'**
  String get rankingSample;

  /// No description provided for @waterSummary.
  ///
  /// In id, this message translates to:
  /// **'312 L hari ini • rata-rata 340 L/hari • aliran 0 L/menit'**
  String get waterSummary;

  /// No description provided for @waterZoneValues.
  ///
  /// In id, this message translates to:
  /// **'Dapur 98 L · kamar mandi 180 L · luar 34 L'**
  String get waterZoneValues;

  /// No description provided for @wifiNetworkSample.
  ///
  /// In id, this message translates to:
  /// **'Jaringan perangkat lokal • 17 terhubung • sinyal baik'**
  String get wifiNetworkSample;

  /// No description provided for @rotationSample.
  ///
  /// In id, this message translates to:
  /// **'Rotasi per tamu dan mati saat kosong: tersedia untuk hunian sewa High pada tahap P1.'**
  String get rotationSample;

  /// No description provided for @gasZero.
  ///
  /// In id, this message translates to:
  /// **'Pembacaan 0 • tidak ada gas terdeteksi'**
  String get gasZero;

  /// No description provided for @gasValveOpen.
  ///
  /// In id, this message translates to:
  /// **'Katup gas terbuka'**
  String get gasValveOpen;

  /// No description provided for @gasSimulationOnly.
  ///
  /// In id, this message translates to:
  /// **'Urutan ini hanya ilustrasi demo, menunggu validasi teknis BMT untuk penerapan nyata.'**
  String get gasSimulationOnly;

  /// No description provided for @detectorTestDone.
  ///
  /// In id, this message translates to:
  /// **'Uji bunyi tiruan dicatat. Detektor nyata bekerja mandiri; aplikasi bukan penggantinya.'**
  String get detectorTestDone;

  /// No description provided for @scenes.
  ///
  /// In id, this message translates to:
  /// **'Adegan'**
  String get scenes;

  /// No description provided for @editScene.
  ///
  /// In id, this message translates to:
  /// **'Sunting adegan'**
  String get editScene;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In id, this message translates to:
  /// **'Perubahan disimpan'**
  String get saved;

  /// No description provided for @schedule.
  ///
  /// In id, this message translates to:
  /// **'Jadwal harian'**
  String get schedule;

  /// No description provided for @scheduleLocal.
  ///
  /// In id, this message translates to:
  /// **'Jadwal memakai waktu rumah WITA dan tetap berjalan saat ponsel tidak terjangkau.'**
  String get scheduleLocal;

  /// No description provided for @scheduleTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu pelaksanaan'**
  String get scheduleTime;

  /// No description provided for @lightsOn.
  ///
  /// In id, this message translates to:
  /// **'Nyalakan lampu'**
  String get lightsOn;

  /// No description provided for @acOn.
  ///
  /// In id, this message translates to:
  /// **'Nyalakan AC'**
  String get acOn;

  /// No description provided for @curtainOpen.
  ///
  /// In id, this message translates to:
  /// **'Buka tirai'**
  String get curtainOpen;

  /// No description provided for @runScene.
  ///
  /// In id, this message translates to:
  /// **'Jalankan adegan'**
  String get runScene;

  /// No description provided for @deviceDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail perangkat'**
  String get deviceDetail;

  /// No description provided for @roomDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail ruang'**
  String get roomDetail;

  /// No description provided for @deviceModel.
  ///
  /// In id, this message translates to:
  /// **'Model demo • perangkat lokal generik'**
  String get deviceModel;

  /// No description provided for @deviceBrand.
  ///
  /// In id, this message translates to:
  /// **'Merek • contoh tiruan BMT'**
  String get deviceBrand;

  /// No description provided for @sensorClosed.
  ///
  /// In id, this message translates to:
  /// **'Pintu dan jendela tertutup'**
  String get sensorClosed;

  /// No description provided for @sensorDry.
  ///
  /// In id, this message translates to:
  /// **'Sensor kering'**
  String get sensorDry;

  /// No description provided for @deviceLastSeen.
  ///
  /// In id, this message translates to:
  /// **'Terakhir diterima'**
  String get deviceLastSeen;

  /// No description provided for @commandEvidence.
  ///
  /// In id, this message translates to:
  /// **'Bukti pengukuran'**
  String get commandEvidence;

  /// No description provided for @deviceHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat perangkat'**
  String get deviceHistory;

  /// No description provided for @riskAction.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi tindakan'**
  String get riskAction;

  /// No description provided for @riskConsequence.
  ///
  /// In id, this message translates to:
  /// **'Tindakan akan mengubah akses atau keadaan rumah.'**
  String get riskConsequence;

  /// No description provided for @alarmArmed.
  ///
  /// In id, this message translates to:
  /// **'Alarm aktif'**
  String get alarmArmed;

  /// No description provided for @alarmDisarmed.
  ///
  /// In id, this message translates to:
  /// **'Alarm nonaktif'**
  String get alarmDisarmed;

  /// No description provided for @armAlarm.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan alarm'**
  String get armAlarm;

  /// No description provided for @disarmAlarm.
  ///
  /// In id, this message translates to:
  /// **'Nonaktifkan alarm'**
  String get disarmAlarm;

  /// No description provided for @awayMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Pergi'**
  String get awayMode;

  /// No description provided for @sleepMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Tidur'**
  String get sleepMode;

  /// No description provided for @memberOwner.
  ///
  /// In id, this message translates to:
  /// **'Pemilik Contoh'**
  String get memberOwner;

  /// No description provided for @memberFamily.
  ///
  /// In id, this message translates to:
  /// **'Keluarga Contoh'**
  String get memberFamily;

  /// No description provided for @memberTechnician.
  ///
  /// In id, this message translates to:
  /// **'Teknisi Contoh'**
  String get memberTechnician;

  /// No description provided for @memberActive.
  ///
  /// In id, this message translates to:
  /// **'Akses aktif'**
  String get memberActive;

  /// No description provided for @memberInactive.
  ///
  /// In id, this message translates to:
  /// **'Akses dicabut'**
  String get memberInactive;

  /// No description provided for @technicianAccess.
  ///
  /// In id, this message translates to:
  /// **'Akses teknisi 30 menit'**
  String get technicianAccess;

  /// No description provided for @technicianScope.
  ///
  /// In id, this message translates to:
  /// **'Diagnosa saja; tanpa kamera, kunci, kode akses, atau kendali perangkat. Dapat dicabut setiap saat.'**
  String get technicianScope;

  /// No description provided for @accessExpired.
  ///
  /// In id, this message translates to:
  /// **'Akses teknisi belum diberikan atau sudah berakhir'**
  String get accessExpired;

  /// No description provided for @grant.
  ///
  /// In id, this message translates to:
  /// **'Berikan akses'**
  String get grant;

  /// No description provided for @revoke.
  ///
  /// In id, this message translates to:
  /// **'Cabut akses'**
  String get revoke;

  /// No description provided for @notificationSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan notifikasi'**
  String get notificationSettings;

  /// No description provided for @notifyImportant.
  ///
  /// In id, this message translates to:
  /// **'Peringatan Penting'**
  String get notifyImportant;

  /// No description provided for @notifyInfo.
  ///
  /// In id, this message translates to:
  /// **'Informasi rumah'**
  String get notifyInfo;

  /// No description provided for @quietHours.
  ///
  /// In id, this message translates to:
  /// **'Jam tenang 22.00–07.00 WITA'**
  String get quietHours;

  /// No description provided for @criticalAlways.
  ///
  /// In id, this message translates to:
  /// **'Peringatan Kritis dalam aplikasi tetap muncul. Izin sistem dan jalur koneksi menentukan notifikasi ponsel.'**
  String get criticalAlways;

  /// No description provided for @alertDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail peringatan'**
  String get alertDetail;

  /// No description provided for @activeSource.
  ///
  /// In id, this message translates to:
  /// **'Sumber masih aktif'**
  String get activeSource;

  /// No description provided for @resolvedSource.
  ///
  /// In id, this message translates to:
  /// **'Sumber kembali normal; catatan tetap disimpan'**
  String get resolvedSource;

  /// No description provided for @alreadyAcknowledged.
  ///
  /// In id, this message translates to:
  /// **'Sudah diakui'**
  String get alreadyAcknowledged;

  /// No description provided for @scenarioTitle.
  ///
  /// In id, this message translates to:
  /// **'Skenario S1–S6'**
  String get scenarioTitle;

  /// No description provided for @scenarioResetNote.
  ///
  /// In id, this message translates to:
  /// **'Mulai skenario memuat seed rumah dan memakai peran Pemilik. Paket, bahasa, dan tema dipertahankan.'**
  String get scenarioResetNote;

  /// No description provided for @s1.
  ///
  /// In id, this message translates to:
  /// **'S1 • Pulang malam'**
  String get s1;

  /// No description provided for @s2.
  ///
  /// In id, this message translates to:
  /// **'S2 • Gas di dapur'**
  String get s2;

  /// No description provided for @s3.
  ///
  /// In id, this message translates to:
  /// **'S3 • Kebocoran air'**
  String get s3;

  /// No description provided for @s4.
  ///
  /// In id, this message translates to:
  /// **'S4 • Empat jalur koneksi'**
  String get s4;

  /// No description provided for @s5.
  ///
  /// In id, this message translates to:
  /// **'S5 • PLN padam dan pulih'**
  String get s5;

  /// No description provided for @s6.
  ///
  /// In id, this message translates to:
  /// **'S6 • Anomali listrik'**
  String get s6;

  /// No description provided for @stopScenario.
  ///
  /// In id, this message translates to:
  /// **'Hentikan urutan'**
  String get stopScenario;

  /// No description provided for @scenarioRunning.
  ///
  /// In id, this message translates to:
  /// **'Urutan berjalan'**
  String get scenarioRunning;

  /// No description provided for @scenarioComplete.
  ///
  /// In id, this message translates to:
  /// **'Urutan selesai • keadaan rumah tetap tersimpan'**
  String get scenarioComplete;

  /// No description provided for @scenarioStep.
  ///
  /// In id, this message translates to:
  /// **'Langkah'**
  String get scenarioStep;

  /// No description provided for @s1BasicNote.
  ///
  /// In id, this message translates to:
  /// **'Basic: hanya lampu teras. AC dan kunci mengikuti hak paket.'**
  String get s1BasicNote;

  /// No description provided for @s2ResetNote.
  ///
  /// In id, this message translates to:
  /// **'Akui peringatan, normalkan sumber lewat Mode Demo, lalu simulasikan reset fisik untuk katup High.'**
  String get s2ResetNote;

  /// No description provided for @s3Note.
  ///
  /// In id, this message translates to:
  /// **'Basic/Medium memberi peringatan Penting; High menutup katup setelah dua sumber cocok.'**
  String get s3Note;

  /// No description provided for @s4Note.
  ///
  /// In id, this message translates to:
  /// **'Urutan 0/5/10/15 detik: di rumah, lokal tanpa internet, jarak jauh, tidak terjangkau. Pulih pada detik 25.'**
  String get s4Note;

  /// No description provided for @s5Note.
  ///
  /// In id, this message translates to:
  /// **'Padam detik 1, pulih detik 15. Detektor gas tanpa daya; kunci baterai tetap bekerja.'**
  String get s5Note;

  /// No description provided for @s6Note.
  ///
  /// In id, this message translates to:
  /// **'Anomali detik 1; High memutus pemanas pada detik 4. Tegangan normal pada detik 20.'**
  String get s6Note;

  /// No description provided for @p0Notice.
  ///
  /// In id, this message translates to:
  /// **'Demo P0 + P1 · seluruh tindakan tiruan'**
  String get p0Notice;

  /// No description provided for @acknowledgedEvent.
  ///
  /// In id, this message translates to:
  /// **'Peringatan diakui'**
  String get acknowledgedEvent;

  /// No description provided for @gasDetectedEvent.
  ///
  /// In id, this message translates to:
  /// **'Detektor gas memicu peringatan'**
  String get gasDetectedEvent;

  /// No description provided for @waterDetectedEvent.
  ///
  /// In id, this message translates to:
  /// **'Sensor basah memicu peringatan'**
  String get waterDetectedEvent;

  /// No description provided for @waterValveClosedEvent.
  ///
  /// In id, this message translates to:
  /// **'Katup air ditutup otomatis'**
  String get waterValveClosedEvent;

  /// No description provided for @voltageAnomalyEvent.
  ///
  /// In id, this message translates to:
  /// **'Anomali tegangan tercatat'**
  String get voltageAnomalyEvent;

  /// No description provided for @memberChangedEvent.
  ///
  /// In id, this message translates to:
  /// **'Hak anggota diubah'**
  String get memberChangedEvent;

  /// No description provided for @technicianGrantedEvent.
  ///
  /// In id, this message translates to:
  /// **'Akses teknisi diberikan 30 menit'**
  String get technicianGrantedEvent;

  /// No description provided for @technicianRevokedEvent.
  ///
  /// In id, this message translates to:
  /// **'Akses teknisi berakhir atau dicabut'**
  String get technicianRevokedEvent;

  /// No description provided for @sceneEditedEvent.
  ///
  /// In id, this message translates to:
  /// **'Adegan dan jadwal diperbarui'**
  String get sceneEditedEvent;

  /// No description provided for @gasPhysicalResetEvent.
  ///
  /// In id, this message translates to:
  /// **'Reset fisik katup gas disimulasikan'**
  String get gasPhysicalResetEvent;

  /// No description provided for @recordingSummary.
  ///
  /// In id, this message translates to:
  /// **'Perekaman kontinu • contoh lokal'**
  String get recordingSummary;

  /// No description provided for @privacyMode.
  ///
  /// In id, this message translates to:
  /// **'Mode privasi kamera dalam ruang'**
  String get privacyMode;

  /// No description provided for @doorbellEvent.
  ///
  /// In id, this message translates to:
  /// **'Bel pintu • gerbang depan • contoh kejadian'**
  String get doorbellEvent;

  /// No description provided for @personZone.
  ///
  /// In id, this message translates to:
  /// **'Deteksi orang/kendaraan • zona gerbang'**
  String get personZone;

  /// No description provided for @motionEvent.
  ///
  /// In id, this message translates to:
  /// **'Gerakan • gerbang depan • contoh kejadian'**
  String get motionEvent;

  /// No description provided for @camerasNoPower.
  ///
  /// In id, this message translates to:
  /// **'Kamera tanpa suplai utama'**
  String get camerasNoPower;

  /// No description provided for @oneWayNote.
  ///
  /// In id, this message translates to:
  /// **'Kontrol inframerah satu arah: status menyala memerlukan bukti pengukuran. Tanpa bukti selama 8 detik, perintah tidak terkonfirmasi.'**
  String get oneWayNote;

  /// No description provided for @turnOn.
  ///
  /// In id, this message translates to:
  /// **'Nyalakan'**
  String get turnOn;

  /// No description provided for @turnOff.
  ///
  /// In id, this message translates to:
  /// **'Matikan'**
  String get turnOff;

  /// No description provided for @kitchenCircuit.
  ///
  /// In id, this message translates to:
  /// **'Sirkuit dapur'**
  String get kitchenCircuit;

  /// No description provided for @circuitCut.
  ///
  /// In id, this message translates to:
  /// **'Sirkuit dapur diputus • perangkat dapur tanpa daya'**
  String get circuitCut;

  /// No description provided for @disconnectCircuit.
  ///
  /// In id, this message translates to:
  /// **'Putus sirkuit'**
  String get disconnectCircuit;

  /// No description provided for @circuitRisk.
  ///
  /// In id, this message translates to:
  /// **'Perangkat pada sirkuit dapur akan kehilangan daya, termasuk detektor gas.'**
  String get circuitRisk;

  /// No description provided for @inviteMember.
  ///
  /// In id, this message translates to:
  /// **'Undang anggota contoh'**
  String get inviteMember;

  /// No description provided for @demoMember.
  ///
  /// In id, this message translates to:
  /// **'Anggota Contoh'**
  String get demoMember;

  /// No description provided for @changeRole.
  ///
  /// In id, this message translates to:
  /// **'Ubah peran'**
  String get changeRole;

  /// No description provided for @rotateWifi.
  ///
  /// In id, this message translates to:
  /// **'Ganti sandi Wi-Fi tamu'**
  String get rotateWifi;

  /// No description provided for @wifiRotateRisk.
  ///
  /// In id, this message translates to:
  /// **'Sandi lama tidak berlaku; perangkat tamu harus menyambung kembali.'**
  String get wifiRotateRisk;

  /// No description provided for @signal.
  ///
  /// In id, this message translates to:
  /// **'Sinyal'**
  String get signal;

  /// No description provided for @thisWeek.
  ///
  /// In id, this message translates to:
  /// **'Minggu ini'**
  String get thisWeek;

  /// No description provided for @localService.
  ///
  /// In id, this message translates to:
  /// **'Layanan lokal: simulasi aktif'**
  String get localService;

  /// No description provided for @valveCloseConsequence.
  ///
  /// In id, this message translates to:
  /// **'Pasokan air rumah akan berhenti sampai katup dibuka kembali.'**
  String get valveCloseConsequence;

  /// No description provided for @detectorTest.
  ///
  /// In id, this message translates to:
  /// **'Uji alarm detektor dicatat'**
  String get detectorTest;

  /// No description provided for @activeDevices.
  ///
  /// In id, this message translates to:
  /// **'perangkat aktif'**
  String get activeDevices;

  /// No description provided for @wifiCredentials.
  ///
  /// In id, this message translates to:
  /// **'Kredensial contoh • bukan jaringan sungguhan'**
  String get wifiCredentials;

  /// No description provided for @connectionMatrix.
  ///
  /// In id, this message translates to:
  /// **'Matriks koneksi'**
  String get connectionMatrix;

  /// No description provided for @matrixHome.
  ///
  /// In id, this message translates to:
  /// **'Kontrol lokal dan cloud tersedia'**
  String get matrixHome;

  /// No description provided for @matrixLocal.
  ///
  /// In id, this message translates to:
  /// **'Kontrol lokal tersedia; cloud dan notifikasi ponsel tidak tersedia'**
  String get matrixLocal;

  /// No description provided for @matrixRemote.
  ///
  /// In id, this message translates to:
  /// **'Kontrol jarak jauh tersedia'**
  String get matrixRemote;

  /// No description provided for @matrixUnreachable.
  ///
  /// In id, this message translates to:
  /// **'Snapshot terakhir; seluruh kontrol rumah nonaktif'**
  String get matrixUnreachable;

  /// No description provided for @openState.
  ///
  /// In id, this message translates to:
  /// **'Terbuka'**
  String get openState;

  /// No description provided for @closedState.
  ///
  /// In id, this message translates to:
  /// **'Tertutup'**
  String get closedState;

  /// No description provided for @rentalReset.
  ///
  /// In id, this message translates to:
  /// **'Reset antar tamu'**
  String get rentalReset;

  /// No description provided for @automations.
  ///
  /// In id, this message translates to:
  /// **'Otomasi'**
  String get automations;

  /// No description provided for @addDevice.
  ///
  /// In id, this message translates to:
  /// **'Tambah perangkat'**
  String get addDevice;

  /// No description provided for @service.
  ///
  /// In id, this message translates to:
  /// **'Bantuan dan servis'**
  String get service;

  /// No description provided for @secondContacts.
  ///
  /// In id, this message translates to:
  /// **'Kontak kedua'**
  String get secondContacts;

  /// No description provided for @waterHeating.
  ///
  /// In id, this message translates to:
  /// **'Pemanas air terjadwal'**
  String get waterHeating;

  /// No description provided for @s7.
  ///
  /// In id, this message translates to:
  /// **'S7 · Gerakan di pagar'**
  String get s7;

  /// No description provided for @s8.
  ///
  /// In id, this message translates to:
  /// **'S8 · Tamu check-in / check-out'**
  String get s8;

  /// No description provided for @s9.
  ///
  /// In id, this message translates to:
  /// **'S9 · Perintah AC tidak sampai'**
  String get s9;

  /// No description provided for @s10.
  ///
  /// In id, this message translates to:
  /// **'S10 · Baterai sensor lemah'**
  String get s10;

  /// No description provided for @s7Note.
  ///
  /// In id, this message translates to:
  /// **'Mode Pergi, notifikasi bergambar, lalu buka kamera. Deteksi orang mengikuti paket.'**
  String get s7Note;

  /// No description provided for @s8Note.
  ///
  /// In id, this message translates to:
  /// **'Gunakan Villa Contoh High untuk alur lengkap. Kode lokal Basic/Medium tetap dapat ditinjau secara manual.'**
  String get s8Note;

  /// No description provided for @s9Note.
  ///
  /// In id, this message translates to:
  /// **'Medium ke atas. Bukti daya tidak datang selama 8 detik nyata; AC tetap mati.'**
  String get s9Note;

  /// No description provided for @s10Note.
  ///
  /// In id, this message translates to:
  /// **'Sensor pintu: baterai 12%, perkiraan 7 hari. Semua angka tiruan.'**
  String get s10Note;

  /// No description provided for @personDetected.
  ///
  /// In id, this message translates to:
  /// **'Orang terdeteksi'**
  String get personDetected;

  /// No description provided for @vehicleDetected.
  ///
  /// In id, this message translates to:
  /// **'Kendaraan terdeteksi'**
  String get vehicleDetected;

  /// No description provided for @play.
  ///
  /// In id, this message translates to:
  /// **'Putar'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In id, this message translates to:
  /// **'Jeda'**
  String get pause;

  /// No description provided for @position.
  ///
  /// In id, this message translates to:
  /// **'Posisi rekaman'**
  String get position;

  /// No description provided for @recordingNote.
  ///
  /// In id, this message translates to:
  /// **'Ilustrasi bergerak dan kejadian tiruan. Tidak ada rekaman kamera sungguhan.'**
  String get recordingNote;

  /// No description provided for @openLive.
  ///
  /// In id, this message translates to:
  /// **'Buka live view'**
  String get openLive;

  /// No description provided for @openTimeline.
  ///
  /// In id, this message translates to:
  /// **'Lihat rekaman'**
  String get openTimeline;

  /// No description provided for @cameraEvent.
  ///
  /// In id, this message translates to:
  /// **'Kejadian kamera'**
  String get cameraEvent;

  /// No description provided for @batteryEstimate.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan sisa baterai'**
  String get batteryEstimate;

  /// No description provided for @days.
  ///
  /// In id, this message translates to:
  /// **'hari'**
  String get days;

  /// No description provided for @issueCode.
  ///
  /// In id, this message translates to:
  /// **'Terbitkan kode'**
  String get issueCode;

  /// No description provided for @guestExample.
  ///
  /// In id, this message translates to:
  /// **'Tamu Contoh'**
  String get guestExample;

  /// No description provided for @validFrom.
  ///
  /// In id, this message translates to:
  /// **'Berlaku mulai'**
  String get validFrom;

  /// No description provided for @revokeCode.
  ///
  /// In id, this message translates to:
  /// **'Cabut kode'**
  String get revokeCode;

  /// No description provided for @revokedCode.
  ///
  /// In id, this message translates to:
  /// **'Dicabut'**
  String get revokedCode;

  /// No description provided for @expiredCode.
  ///
  /// In id, this message translates to:
  /// **'Kedaluwarsa'**
  String get expiredCode;

  /// No description provided for @upcomingCode.
  ///
  /// In id, this message translates to:
  /// **'Belum berlaku'**
  String get upcomingCode;

  /// No description provided for @activeCode.
  ///
  /// In id, this message translates to:
  /// **'Berlaku'**
  String get activeCode;

  /// No description provided for @codePreview.
  ///
  /// In id, this message translates to:
  /// **'Pratinjau berbagi kode'**
  String get codePreview;

  /// No description provided for @codePreviewNote.
  ///
  /// In id, this message translates to:
  /// **'Hanya pratinjau lokal. Kode ini fiktif dan tidak dikirim ke siapa pun.'**
  String get codePreviewNote;

  /// No description provided for @copyCode.
  ///
  /// In id, this message translates to:
  /// **'Salin kode contoh'**
  String get copyCode;

  /// No description provided for @copiedCode.
  ///
  /// In id, this message translates to:
  /// **'Kode contoh disalin'**
  String get copiedCode;

  /// No description provided for @simulateKeypad.
  ///
  /// In id, this message translates to:
  /// **'Simulasikan kode di kunci'**
  String get simulateKeypad;

  /// No description provided for @keypadConsequence.
  ///
  /// In id, this message translates to:
  /// **'Simulasi membuka kunci dengan kode tamu yang masih berlaku. Dicatat sebagai Tamu melalui jalur lokal.'**
  String get keypadConsequence;

  /// No description provided for @codeLocalNote.
  ///
  /// In id, this message translates to:
  /// **'Kode lokal hanya dapat dikelola saat ponsel di rumah. Penerbitan jarak jauh memerlukan High dan internet.'**
  String get codeLocalNote;

  /// No description provided for @codeFailed.
  ///
  /// In id, this message translates to:
  /// **'Kode belum diterbitkan. Periksa waktu, paket, peran, dan koneksi.'**
  String get codeFailed;

  /// No description provided for @codeRangeNote.
  ///
  /// In id, this message translates to:
  /// **'Rentang maksimum 30 hari. Waktu mengikuti rumah (WITA).'**
  String get codeRangeNote;

  /// No description provided for @checkIn.
  ///
  /// In id, this message translates to:
  /// **'Check-in'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In id, this message translates to:
  /// **'Check-out dan reset'**
  String get checkOut;

  /// No description provided for @occupied.
  ///
  /// In id, this message translates to:
  /// **'Sedang ditempati'**
  String get occupied;

  /// No description provided for @vacant.
  ///
  /// In id, this message translates to:
  /// **'Belum ada tamu check-in'**
  String get vacant;

  /// No description provided for @nextStay.
  ///
  /// In id, this message translates to:
  /// **'Kunjungan berikutnya'**
  String get nextStay;

  /// No description provided for @checkoutConsequence.
  ///
  /// In id, this message translates to:
  /// **'Cabut seluruh kode, kirim perintah AC dan lampu mati, lalu ganti sandi Wi-Fi tamu. Hasil perintah tetap menunggu konfirmasi.'**
  String get checkoutConsequence;

  /// No description provided for @checkoutInternet.
  ///
  /// In id, this message translates to:
  /// **'Reset lengkap memerlukan High dan internet. Kode lokal tetap dapat dicabut di rumah.'**
  String get checkoutInternet;

  /// No description provided for @checkoutReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan reset contoh'**
  String get checkoutReport;

  /// No description provided for @codesRevoked.
  ///
  /// In id, this message translates to:
  /// **'Kode dicabut'**
  String get codesRevoked;

  /// No description provided for @commandsPending.
  ///
  /// In id, this message translates to:
  /// **'Perintah masih menunggu hasil'**
  String get commandsPending;

  /// No description provided for @commandsComplete.
  ///
  /// In id, this message translates to:
  /// **'Seluruh perintah terkonfirmasi'**
  String get commandsComplete;

  /// No description provided for @commandsIncomplete.
  ///
  /// In id, this message translates to:
  /// **'Ada perintah belum terkonfirmasi'**
  String get commandsIncomplete;

  /// No description provided for @wifiVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi sandi Wi-Fi tamu'**
  String get wifiVersion;

  /// No description provided for @vacantAc.
  ///
  /// In id, this message translates to:
  /// **'AC mati saat kosong'**
  String get vacantAc;

  /// No description provided for @humidFan.
  ///
  /// In id, this message translates to:
  /// **'Kipas saat lembap'**
  String get humidFan;

  /// No description provided for @scheduledHeater.
  ///
  /// In id, this message translates to:
  /// **'Pemanas air terjadwal'**
  String get scheduledHeater;

  /// No description provided for @vacantAcNote.
  ///
  /// In id, this message translates to:
  /// **'Tanpa kehadiran selama 15 menit → kirim AC mati. Tetap menunggu bukti daya.'**
  String get vacantAcNote;

  /// No description provided for @humidFanNote.
  ///
  /// In id, this message translates to:
  /// **'Kelembapan di atas 75% → kipas buang menyala.'**
  String get humidFanNote;

  /// No description provided for @heaterNote.
  ///
  /// In id, this message translates to:
  /// **'Kirim pemanas air menyala pada jadwal WITA yang dipilih.'**
  String get heaterNote;

  /// No description provided for @simulateTrigger.
  ///
  /// In id, this message translates to:
  /// **'Simulasikan pemicu'**
  String get simulateTrigger;

  /// No description provided for @automationNote.
  ///
  /// In id, this message translates to:
  /// **'Aturan tiruan berjalan di rumah, termasuk saat ponsel tidak terjangkau.'**
  String get automationNote;

  /// No description provided for @pairing.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan rumah'**
  String get pairing;

  /// No description provided for @onboarding.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang'**
  String get onboarding;

  /// No description provided for @onboardingNote.
  ///
  /// In id, this message translates to:
  /// **'Lihat lima fondasi dan kendalikan perangkat melalui rumah contoh. Semua data dan tindakan dalam aplikasi ini adalah simulasi.'**
  String get onboardingNote;

  /// No description provided for @scanDemoQr.
  ///
  /// In id, this message translates to:
  /// **'Pindai QR contoh'**
  String get scanDemoQr;

  /// No description provided for @pairingNote.
  ///
  /// In id, this message translates to:
  /// **'Tidak memakai kamera ponsel. Pilih QR contoh untuk menghubungkan profil lokal.'**
  String get pairingNote;

  /// No description provided for @pairSuccess.
  ///
  /// In id, this message translates to:
  /// **'Rumah contoh terhubung'**
  String get pairSuccess;

  /// No description provided for @pairAtHome.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan rumah dan tambah perangkat saat ponsel berada di rumah serta listrik tersedia.'**
  String get pairAtHome;

  /// No description provided for @notificationExplain.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi OS memerlukan izin sistem. Overlay darurat dalam aplikasi tetap terlihat saat rumah terjangkau. Izin dapat diuji di Pengaturan.'**
  String get notificationExplain;

  /// No description provided for @candidateLocal.
  ///
  /// In id, this message translates to:
  /// **'Relay lokal contoh'**
  String get candidateLocal;

  /// No description provided for @candidateCloud.
  ///
  /// In id, this message translates to:
  /// **'Robot bergantung cloud contoh'**
  String get candidateCloud;

  /// No description provided for @candidateUnsupported.
  ///
  /// In id, this message translates to:
  /// **'Perangkat belum didukung'**
  String get candidateUnsupported;

  /// No description provided for @compatibility.
  ///
  /// In id, this message translates to:
  /// **'Uji kompatibilitas tiruan'**
  String get compatibility;

  /// No description provided for @compatLocal.
  ///
  /// In id, this message translates to:
  /// **'Kendali melalui rumah'**
  String get compatLocal;

  /// No description provided for @compatFeedback.
  ///
  /// In id, this message translates to:
  /// **'Umpan balik status'**
  String get compatFeedback;

  /// No description provided for @compatOffline.
  ///
  /// In id, this message translates to:
  /// **'Bekerja tanpa internet'**
  String get compatOffline;

  /// No description provided for @compatIntegration.
  ///
  /// In id, this message translates to:
  /// **'Integrasi yang didukung'**
  String get compatIntegration;

  /// No description provided for @passed.
  ///
  /// In id, this message translates to:
  /// **'Lolos'**
  String get passed;

  /// No description provided for @notPassed.
  ///
  /// In id, this message translates to:
  /// **'Tidak lolos'**
  String get notPassed;

  /// No description provided for @unsupportedNote.
  ///
  /// In id, this message translates to:
  /// **'Belum dapat ditambahkan. Hasil ini contoh, bukan sertifikasi kompatibilitas merek.'**
  String get unsupportedNote;

  /// No description provided for @cloudPairNote.
  ///
  /// In id, this message translates to:
  /// **'Kustom saja. Bergantung internet; tidak dijanjikan bekerja lokal.'**
  String get cloudPairNote;

  /// No description provided for @addSuccess.
  ///
  /// In id, this message translates to:
  /// **'Perangkat contoh ditambahkan'**
  String get addSuccess;

  /// No description provided for @addFailed.
  ///
  /// In id, this message translates to:
  /// **'Belum ditambahkan. Periksa koneksi, paket, atau perangkat yang sudah ada.'**
  String get addFailed;

  /// No description provided for @monthlyReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan energi bulanan'**
  String get monthlyReport;

  /// No description provided for @monthToDate.
  ///
  /// In id, this message translates to:
  /// **'Bulan berjalan sampai hari ini'**
  String get monthToDate;

  /// No description provided for @previousMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan lalu, periode penuh'**
  String get previousMonth;

  /// No description provided for @energyComparison.
  ///
  /// In id, this message translates to:
  /// **'Perbandingan contoh; bulan berjalan belum lengkap. Tidak dipakai sebagai proyeksi tagihan.'**
  String get energyComparison;

  /// No description provided for @topConsumers.
  ///
  /// In id, this message translates to:
  /// **'Alat terboros bulan ini'**
  String get topConsumers;

  /// No description provided for @energyReportNote.
  ///
  /// In id, this message translates to:
  /// **'Data tetap dari profil contoh, bukan pembacaan meter sungguhan.'**
  String get energyReportNote;

  /// No description provided for @createTicket.
  ///
  /// In id, this message translates to:
  /// **'Buat tiket contoh'**
  String get createTicket;

  /// No description provided for @ticketNote.
  ///
  /// In id, this message translates to:
  /// **'Tiket hanya tersimpan selama sesi demo. Tidak dikirim ke BMT. Target waktu tanggap belum ditetapkan BMT.'**
  String get ticketNote;

  /// No description provided for @urgentService.
  ///
  /// In id, this message translates to:
  /// **'Mendesak · perlu ditinjau segera'**
  String get urgentService;

  /// No description provided for @disruptionService.
  ///
  /// In id, this message translates to:
  /// **'Gangguan fungsi · perlu penjadwalan'**
  String get disruptionService;

  /// No description provided for @generalService.
  ///
  /// In id, this message translates to:
  /// **'Pertanyaan umum · antrean rutin'**
  String get generalService;

  /// No description provided for @ticketSaved.
  ///
  /// In id, this message translates to:
  /// **'Tiket contoh tersimpan lokal'**
  String get ticketSaved;

  /// No description provided for @ticketOpen.
  ///
  /// In id, this message translates to:
  /// **'Terbuka · simulasi'**
  String get ticketOpen;

  /// No description provided for @serviceContact.
  ///
  /// In id, this message translates to:
  /// **'Kontak BMT · hanya ditampilkan'**
  String get serviceContact;

  /// No description provided for @secondContactNote.
  ///
  /// In id, this message translates to:
  /// **'Keluarga Contoh menerima salinan peringatan di daftar tiruan. Tidak ada pesan atau panggilan sungguhan.'**
  String get secondContactNote;

  /// No description provided for @contactEnabled.
  ///
  /// In id, this message translates to:
  /// **'Salinan peringatan aktif untuk Keluarga Contoh'**
  String get contactEnabled;

  /// No description provided for @contactDisabled.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kontak kedua'**
  String get contactDisabled;

  /// No description provided for @contactAlertCopies.
  ///
  /// In id, this message translates to:
  /// **'Salinan peringatan'**
  String get contactAlertCopies;

  /// No description provided for @biometric.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi biometrik'**
  String get biometric;

  /// No description provided for @biometricReason.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi tindakan pada rumah contoh BMT'**
  String get biometricReason;

  /// No description provided for @biometricFallback.
  ///
  /// In id, this message translates to:
  /// **'Biometrik dibatalkan atau tidak tersedia. Gunakan tahan untuk konfirmasi.'**
  String get biometricFallback;

  /// No description provided for @biometricNote.
  ///
  /// In id, this message translates to:
  /// **'Biometrik perangkat hanya mengonfirmasi tindakan simulasi ini.'**
  String get biometricNote;

  /// No description provided for @authInProgress.
  ///
  /// In id, this message translates to:
  /// **'Menunggu biometrik…'**
  String get authInProgress;

  /// No description provided for @codeIssuedEvent.
  ///
  /// In id, this message translates to:
  /// **'Kode akses diterbitkan'**
  String get codeIssuedEvent;

  /// No description provided for @codeRevokedEvent.
  ///
  /// In id, this message translates to:
  /// **'Kode akses dicabut'**
  String get codeRevokedEvent;

  /// No description provided for @codeUsedEvent.
  ///
  /// In id, this message translates to:
  /// **'Kode tamu digunakan pada kunci'**
  String get codeUsedEvent;

  /// No description provided for @checkedOutEvent.
  ///
  /// In id, this message translates to:
  /// **'Check-out dan reset dimulai'**
  String get checkedOutEvent;

  /// No description provided for @wifiRotatedEvent.
  ///
  /// In id, this message translates to:
  /// **'Sandi Wi-Fi tamu diganti'**
  String get wifiRotatedEvent;

  /// No description provided for @deviceAddedEvent.
  ///
  /// In id, this message translates to:
  /// **'Perangkat contoh ditambahkan'**
  String get deviceAddedEvent;

  /// No description provided for @automationChangedEvent.
  ///
  /// In id, this message translates to:
  /// **'Aturan otomasi diubah'**
  String get automationChangedEvent;

  /// No description provided for @automationRanEvent.
  ///
  /// In id, this message translates to:
  /// **'Otomasi mengirim perintah'**
  String get automationRanEvent;

  /// No description provided for @ticketCreatedEvent.
  ///
  /// In id, this message translates to:
  /// **'Tiket servis contoh dibuat'**
  String get ticketCreatedEvent;

  /// No description provided for @contactChangedEvent.
  ///
  /// In id, this message translates to:
  /// **'Kontak kedua diubah'**
  String get contactChangedEvent;

  /// No description provided for @housePairedEvent.
  ///
  /// In id, this message translates to:
  /// **'Rumah contoh dihubungkan'**
  String get housePairedEvent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
