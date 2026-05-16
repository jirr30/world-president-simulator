// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Simulator Presiden Dunia';

  @override
  String get appTitleLine1 => 'PRESIDEN DUNIA';

  @override
  String get appTitleLine2 => 'SIMULATOR';

  @override
  String get appTagline1 => 'Simulator\nPresiden Dunia';

  @override
  String get appTagline2 =>
      'Pimpin lebih dari 100 negara nyata.\nBentuk sejarah. Tinggalkan warisan.';

  @override
  String get featureCountries => '195 Negara';

  @override
  String get featureRealData => 'Data Nyata';

  @override
  String get featureLiveEvents => 'Event Langsung';

  @override
  String get featureAutoSave => 'Simpan Otomatis';

  @override
  String get continueGame => 'Lanjutkan Game';

  @override
  String get newGame => 'Game Baru';

  @override
  String get howToPlay => 'Cara Bermain';

  @override
  String get savedGameFound => 'Game tersimpan ditemukan';

  @override
  String get startNewGameTitle => 'Mulai Game Baru?';

  @override
  String get startNewGameContent =>
      'Progres tersimpan Anda akan ditimpa saat memulai game baru.';

  @override
  String get howToPlay1Title => 'Pilih Negara Anda';

  @override
  String get howToPlay1Desc =>
      'Pilih dari 195 negara nyata dengan data ekonomi dan militer aktual.';

  @override
  String get howToPlay2Title => 'Terapkan Kebijakan';

  @override
  String get howToPlay2Desc =>
      'Pilih kebijakan ekonomi, militer, sosial, atau diplomatik setiap masa jabatan.';

  @override
  String get howToPlay3Title => 'Tangani Event';

  @override
  String get howToPlay3Desc =>
      'Event dunia acak akan menantang kepemimpinan Anda. Pilih dengan bijak.';

  @override
  String get howToPlay4Title => 'Maju Setahun';

  @override
  String get howToPlay4Desc =>
      'Setiap tahun keputusan Anda mempengaruhi rating persetujuan dan statistik negara.';

  @override
  String get howToPlay5Title => 'Simpan Otomatis';

  @override
  String get howToPlay5Desc =>
      'Progres tersimpan otomatis. Keluar dan lanjutkan kapan saja.';

  @override
  String get howToPlay6Title => 'Tinggalkan Warisan';

  @override
  String get howToPlay6Desc =>
      'Selesaikan masa jabatan penuh dan dinilai oleh sejarah setelah 5 tahun.';

  @override
  String get progressAutoSaved => 'Progres tersimpan otomatis';

  @override
  String get policies => 'Kebijakan';

  @override
  String get tabOverview => 'Ikhtisar';

  @override
  String get tabEconomy => 'Ekonomi';

  @override
  String get tabMilitary => 'Militer';

  @override
  String get tabDiplomacy => 'Diplomasi';

  @override
  String get tabSocial => 'Sosial';

  @override
  String advanceToYear(int year) {
    return 'Maju ke $year';
  }

  @override
  String get leaveGameTitle => 'Keluar Game?';

  @override
  String get leaveGameContent =>
      'Game tersimpan otomatis. Anda dapat melanjutkan dari menu utama.';

  @override
  String get cancel => 'Batal';

  @override
  String get leave => 'Keluar';

  @override
  String get approval => 'Persetujuan';

  @override
  String leaderInfo(String title, int year, int yearsIn) {
    return '$title • Tahun $year • $yearsIn thn berkuasa';
  }

  @override
  String get statHappiness => 'Kebahagiaan';

  @override
  String get statStability => 'Stabilitas';

  @override
  String get statGdpGrowth => 'Pertumbuhan PDB';

  @override
  String get statCorruption => 'Korupsi';

  @override
  String get gdpStatusBooming => 'Sedang Tumbuh';

  @override
  String get gdpStatusStable => 'Stabil';

  @override
  String get gdpStatusRecession => 'Resesi';

  @override
  String get statGdp => 'PDB';

  @override
  String get diplomaticRelations => 'Hubungan Diplomatik';

  @override
  String get allies => 'Sekutu';

  @override
  String get rivals => 'Rival';

  @override
  String get activePolicies => 'Kebijakan Aktif';

  @override
  String activePoliciesCount(int count) {
    return 'Kebijakan Aktif ($count)';
  }

  @override
  String get atWarBadge => 'SEDANG BERPERANG';

  @override
  String get population => 'Populasi';

  @override
  String get economicIndicators => 'Indikator Ekonomi';

  @override
  String get totalGdp => 'Total PDB';

  @override
  String get gdpPerCapita => 'PDB per Kapita';

  @override
  String get inflation => 'Inflasi';

  @override
  String get unemployment => 'Pengangguran';

  @override
  String get taxRate => 'Tarif Pajak';

  @override
  String get nationalDebt => 'Utang Nasional';

  @override
  String get taxRateSliderTitle => 'Tarif Pajak';

  @override
  String get taxZoneSafe => 'Zona Aman';

  @override
  String get taxZoneWarning => 'Zona Peringatan';

  @override
  String get taxZoneDanger => 'Zona Bahaya';

  @override
  String get capitalFlightWarning => 'Risiko Pelarian Modal';

  @override
  String get taxProtestImminent => 'Protes Pajak Akan Segera Terjadi';

  @override
  String get treasury => 'Kas Negara';

  @override
  String get treasuryBalance => 'Saldo Saat Ini';

  @override
  String get budgetBreakdown => 'RINCIAN ANGGARAN';

  @override
  String get taxRevenue => 'Pendapatan Pajak';

  @override
  String get govSpending => 'Belanja Pemerintah';

  @override
  String get govSpendingSub => '20% dari PDB';

  @override
  String get militaryBudgetLabel => 'Anggaran Militer';

  @override
  String get healthcareLabel => 'Kesehatan';

  @override
  String get educationLabel => 'Pendidikan';

  @override
  String get buildingMaintenance => 'Perawatan Bangunan';

  @override
  String get buildingMaintenanceSub => '2%/lv/tahun';

  @override
  String get activePoliciesCost => 'biaya tahunan gabungan';

  @override
  String get netPerYear => 'Net per tahun';

  @override
  String get treasuryDeficit =>
      'Defisit kas — pertumbuhan PDB dan kebahagiaan terdampak';

  @override
  String get militaryStrength => 'Kekuatan Militer';

  @override
  String get militaryBudget => 'Anggaran Militer';

  @override
  String get activeTroops => 'Pasukan Aktif';

  @override
  String get readiness => 'Kesiapan';

  @override
  String get warStatus => 'Status Perang';

  @override
  String get atWar => 'Sedang Berperang';

  @override
  String get atPeace => 'Dalam Damai';

  @override
  String get declareWar => 'Nyatakan Perang';

  @override
  String get sueForPeace => 'Minta Gencatan Senjata';

  @override
  String get warControls => 'Kontrol Perang';

  @override
  String get militaryRank => 'Pangkat Militer';

  @override
  String get strategicResources => 'Sumber Daya Strategis';

  @override
  String get educationIndex => 'Indeks Pendidikan';

  @override
  String get literacyRate => 'Tingkat Melek Huruf';

  @override
  String get foodSecurity => 'Ketahanan Pangan';

  @override
  String get agriOutput => 'Hasil Pertanian';

  @override
  String get socialInvestment => 'Investasi Sosial';

  @override
  String get socialInvestmentSub =>
      'Dana tambahan di atas pengeluaran pemerintah dasar';

  @override
  String get none => 'Tidak Ada';

  @override
  String get foodAgricultureStatus => 'Status Pangan & Pertanian';

  @override
  String get foodSurplus => 'Surplus Pangan';

  @override
  String get foodSecure => 'Pangan Aman';

  @override
  String get moderateRisk => 'Risiko Sedang';

  @override
  String get foodInsecure => 'Pangan Tidak Aman';

  @override
  String get famineCrisis => 'Krisis Kelaparan';

  @override
  String get populationOverview => 'Ikhtisar Populasi';

  @override
  String get totalPopulation => 'Total Populasi';

  @override
  String get growthRate => 'Tingkat Pertumbuhan';

  @override
  String get capitalCity => 'Ibu Kota';

  @override
  String get continent => 'Benua';

  @override
  String get government => 'Pemerintahan';

  @override
  String get happinessScore => 'Skor Kebahagiaan';

  @override
  String get chooseYourResponse => 'Pilih Respons Anda:';

  @override
  String get confirmDecision => 'Konfirmasi Keputusan';

  @override
  String get selectOptionFirst => 'Pilih opsi terlebih dahulu';

  @override
  String get continueGoverning => 'Lanjutkan Memimpin';

  @override
  String get impeachedBadge => 'DICOPOT';

  @override
  String get termEndedBadge => 'MASA JABATAN BERAKHIR';

  @override
  String get invadedBadge => 'DIINVASI';

  @override
  String get countryFallen => 'Negara Telah Jatuh';

  @override
  String invadedVerdictText(String country) {
    return '$country telah ditaklukkan oleh kekuatan asing. Kegagalan Anda mempertahankan negara akan dikenang sepanjang sejarah.';
  }

  @override
  String get removedFromPower => 'Dicopot dari Kekuasaan';

  @override
  String get finalReport => 'Laporan Akhir';

  @override
  String get avgApproval => 'Rata-rata Persetujuan';

  @override
  String avgApprovalStat(String pct) {
    return 'Rata-rata persetujuan: $pct%';
  }

  @override
  String get finalGdp => 'PDB Akhir';

  @override
  String get militaryStat => 'Militer';

  @override
  String get diplomacy => 'Diplomasi';

  @override
  String get education => 'Pendidikan';

  @override
  String get policiesApplied => 'Kebijakan Diterapkan';

  @override
  String get yearsInPower => 'Tahun Berkuasa';

  @override
  String get historicalVerdict => 'Penilaian Sejarah';

  @override
  String get playAgain => 'Main Lagi';

  @override
  String get mainMenu => 'Menu Utama';

  @override
  String verdictGreat(String country) {
    return 'Sejarah akan mengingat kepemimpinan Anda dengan kekaguman besar. Anda mengubah $country menjadi mercusuar kemakmuran dan stabilitas.';
  }

  @override
  String verdictGood(String country) {
    return 'Anda memimpin $country dengan kompeten dan sangat dihormati oleh warga. Masa jabatan Anda menyaksikan kemajuan nyata di bidang-bidang utama.';
  }

  @override
  String verdictAverage(String country) {
    return 'Masa kepemimpinan Anda di $country bercampur aduk. Meskipun Anda menjaga stabilitas, banyak warga merasa lebih banyak yang bisa dicapai.';
  }

  @override
  String verdictPoor(String country) {
    return 'Kepemimpinan Anda memecah belah bangsa. Oposisi yang signifikan menandai masa jabatan Anda. $country menghadapi tantangan besar di bawah pemerintahan Anda.';
  }

  @override
  String verdictBad(String country) {
    return 'Masa jabatan Anda sebagai pemimpin $country akan diingat sebagai periode penuh gejolak. Institusi melemah dan reputasi negara menurun.';
  }

  @override
  String impeachText1(String country) {
    return 'Dengan tingkat persetujuan yang sangat rendah, rakyat $country turun ke jalan. Parlemen dengan suara bulat memilih untuk mencabut jabatan Anda. Anda akan diingat sebagai pemimpin terburuk dalam sejarah bangsa.';
  }

  @override
  String impeachText2(String country) {
    return 'Protes massal dan pemungutan suara parlemen memaksa Anda keluar dari jabatan. Kebijakan Anda gagal melayani rakyat $country dan sejarah tidak akan berpihak pada warisan Anda.';
  }

  @override
  String impeachText3(String country) {
    return 'Kepercayaan publik runtuh melampaui pemulihan. Menghadapi proses pemakzulan di parlemen, Anda dicopot dari jabatan. $country melanjutkan perjalanan tanpa Anda.';
  }

  @override
  String get selectCountry => 'Pilih Negara Anda';

  @override
  String get searchCountries => 'Cari negara...';

  @override
  String get filterAll => 'Semua';

  @override
  String get filterAfrica => 'Afrika';

  @override
  String get filterAsia => 'Asia';

  @override
  String get filterEurope => 'Eropa';

  @override
  String get filterAmericas => 'Amerika';

  @override
  String get filterOceania => 'Oseania';

  @override
  String get startGame => 'Mulai Game';

  @override
  String get countryGdp => 'PDB';

  @override
  String get countryPopulation => 'Populasi';

  @override
  String get countryMilitary => 'Militer';

  @override
  String get countryHdi => 'IPM';

  @override
  String get countryContinent => 'Benua';

  @override
  String get countryCapital => 'Ibu Kota';

  @override
  String get countryGovernment => 'Pemerintahan';

  @override
  String get policyScreen => 'Kebijakan';

  @override
  String get applyPolicy => 'Terapkan';

  @override
  String get removePolicy => 'Cabut';

  @override
  String get policyActive => 'Aktif';

  @override
  String get policyCost => 'Biaya';

  @override
  String get policyEffect => 'Efek';

  @override
  String get buildingsScreen => 'Infrastruktur';

  @override
  String get build => 'Bangun';

  @override
  String get upgrade => 'Tingkatkan';

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get maxLevel => 'Level Maks';

  @override
  String get natResources => 'SDA';

  @override
  String get oilReserves => 'Cadangan Minyak';

  @override
  String get diplomaticReputation => 'Reputasi Diplomatik';

  @override
  String get formAlliance => 'Bentuk Aliansi';

  @override
  String get breakAlliance => 'Putus Aliansi';

  @override
  String get imposeSanction => 'Jatuhkan Sanksi';

  @override
  String get liftSanction => 'Cabut Sanksi';

  @override
  String get allyRelation => 'Bersekutu';

  @override
  String get historicAlly => 'Sekutu Bersejarah';

  @override
  String get neutral => 'Netral';

  @override
  String get sanctioned => 'Disanksi';

  @override
  String get historicRival => 'Rival Bersejarah';

  @override
  String get yearSummary => 'Tinjauan Tahunan';

  @override
  String yearSummarySubtitle(int year) {
    return 'Hasil Tahun $year';
  }

  @override
  String get noChanges => 'Tidak ada perubahan signifikan tahun ini.';

  @override
  String get continueBtn => 'Lanjutkan';

  @override
  String get politicalCapital => 'Modal Politik';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get langEnglish => 'English';

  @override
  String get langIndonesian => 'Indonesia';

  @override
  String get settings => 'Pengaturan';

  @override
  String pageNotFound(String path) {
    return 'Halaman tidak ditemukan: $path';
  }

  @override
  String get goHome => 'Ke Beranda';

  @override
  String get ultraLowTaxRate => 'Sangat Rendah — ledakan sektor swasta';

  @override
  String get veryLowTaxRate => 'Sangat Rendah — layanan publik minimal';

  @override
  String get lowTaxRate => 'Rendah — pemerintah ramping';

  @override
  String get moderateTaxRate => 'Sedang — anggaran seimbang';

  @override
  String get highTaxRate => 'Tinggi — investasi publik kuat';

  @override
  String get veryHighTaxRate => 'Sangat Tinggi — risiko pelarian modal';

  @override
  String get extremeTaxRate => 'Ekstrem — pelarian modal + risiko protes';

  @override
  String get protestConditionsActive =>
      'KONDISI PROTES AKTIF — Protes massal akan meletus tahun depan. Turunkan pajak di bawah 45% atau naikkan kebahagiaan di atas 40 untuk mencegahnya.';

  @override
  String get capitalFlightActive =>
      'Pelarian modal aktif — investor pergi. Jika kebahagiaan turun di bawah 40, protes massal akan meletus.';

  @override
  String newRateTakesEffect(String taxRate) {
    return 'Tarif baru $taxRate% berlaku penuh tahun depan.';
  }

  @override
  String get taxZoneSafeLabel => 'Aman';

  @override
  String get taxZoneWarningLabel => 'Peringatan';

  @override
  String get taxZoneCrisisLabel => 'Krisis';

  @override
  String get healthyDebt => 'Tingkat utang sehat — ekonomi berkelanjutan.';

  @override
  String get moderateDebt => 'Utang sedang — pantau dengan cermat.';

  @override
  String get dangerousDebt => 'Tingkat utang berbahaya — risiko gagal bayar!';

  @override
  String get declareWarTitle => 'Nyatakan Perang?';

  @override
  String get declareWarSubtitle =>
      'Ini akan menempatkan negara Anda dalam kondisi perang.';

  @override
  String get ongoingWarPenalties => 'Penalti perang berkelanjutan (per tahun):';

  @override
  String get militaryWeakWarning =>
      'Militer sangat lemah — negosiasi damai akan dipaksakan di akhir tahun.';

  @override
  String get countryAtPeace => 'Negara Anda saat ini dalam keadaan damai.';

  @override
  String get declareWarWarning =>
      'Menyatakan perang akan memberlakukan penalti tahunan yang berat pada kebahagiaan, stabilitas, dan pertumbuhan PDB hingga perdamaian dinegosiasikan.';

  @override
  String get sueForPeaceTitle => 'Minta Gencatan Senjata?';

  @override
  String get sueForPeaceSubtitle => 'Akhiri konflik dan kembali ke masa damai.';

  @override
  String get activeConflict => 'Konflik Aktif';

  @override
  String get percentOfGdp => '% dari PDB';

  @override
  String get minimalMilBudget => 'Minimal — kemampuan pertahanan menurun';

  @override
  String get lowMilBudget => 'Rendah — pencegahan dasar saja';

  @override
  String get moderateMilBudget => 'Sedang — pertahanan seimbang';

  @override
  String get highMilBudget => 'Tinggi — kekuatan regional kuat';

  @override
  String get veryHighMilBudget => 'Sangat Tinggi — investasi militer besar';

  @override
  String get maxMilBudget => 'Maksimum — kompleks industri militer penuh';

  @override
  String newBudgetTakesEffect(String percent, String budget) {
    return 'Anggaran baru $percent% PDB ($budget) berlaku tahun depan.';
  }

  @override
  String get globalSuperpower => 'Adikuasa Global';

  @override
  String get majorMilitaryPower => 'Kekuatan Militer Besar';

  @override
  String get regionalPower => 'Kekuatan Regional';

  @override
  String get moderateForce => 'Kekuatan Sedang';

  @override
  String get limitedCapability => 'Kemampuan Terbatas';

  @override
  String get minimalDefense => 'Pertahanan Minimal';

  @override
  String get noCountriesMatch =>
      'Tidak ada negara yang cocok dengan pencarian Anda.';

  @override
  String get repLocked =>
      'Rep < 30 — aliansi terkunci.\nTingkatkan reputasi untuk membuka.';

  @override
  String get yourAlliances => 'Aliansi Anda';

  @override
  String get yourSanctions => 'Sanksi Anda';

  @override
  String get historicAllies => 'Sekutu Bersejarah';

  @override
  String get historicRivals => 'Rival Bersejarah';

  @override
  String get noActiveRelations =>
      'Tidak ada hubungan aktif.\nGunakan browser →\nuntuk membentuk aliansi.';

  @override
  String get preExisting => 'Sudah Ada';

  @override
  String alliancesCount(int count) {
    return '$count Sekutu';
  }

  @override
  String rivalsCount(int count) {
    return '$count Rival';
  }

  @override
  String allianceGdpBonus(String bonus) {
    return '+$bonus% PDB/thn dari aliansi';
  }

  @override
  String confirmFormAlliance(String country) {
    return 'Bentuk Aliansi dengan $country?';
  }

  @override
  String confirmBreakAlliance(String country) {
    return 'Putus Aliansi dengan $country?';
  }

  @override
  String confirmSanction(String country) {
    return 'Jatuhkan Sanksi pada $country?';
  }

  @override
  String confirmLiftSanction(String country) {
    return 'Cabut Sanksi pada $country?';
  }

  @override
  String get economicTab => 'Ekonomi';

  @override
  String get diplomaticTab => 'Diplomatik';

  @override
  String policyNotEnoughCapital(int needed, int have) {
    return 'Modal Politik tidak cukup (butuh $needed, punya $have).';
  }

  @override
  String notEnoughApproval(int minApproval) {
    return 'Anda butuh minimal $minApproval% persetujuan untuk menerapkan kebijakan ini.';
  }

  @override
  String policyAlreadyActive(String policy) {
    return '$policy sudah aktif.';
  }

  @override
  String policyApplied(String policy) {
    return '$policy telah diterapkan!';
  }

  @override
  String revokePolicy(String policy) {
    return 'Cabut \"$policy\"?';
  }

  @override
  String get revokeDescription => 'Mencabut kebijakan ini akan:';

  @override
  String get revokeCostDrain => 'Menghentikan pengeluaran tahunan';

  @override
  String get revokeEffectsReversal => 'Membalikkan efek sebagian (40%)';

  @override
  String revokeRefund(int refund) {
    return 'Mengembalikan $refund Modal Politik';
  }

  @override
  String get revokePolicyButton => 'Cabut Kebijakan';

  @override
  String revokeSuccess(String policy, int refund) {
    return '$policy dicabut. +$refund dikembalikan.';
  }

  @override
  String get bonusPerLevel => 'Bonus per level / tahun:';

  @override
  String get infrastructureTitle => 'Infrastruktur';

  @override
  String get energyTab => 'Energi';

  @override
  String get foodTab => 'Pangan';

  @override
  String get resourcesTab => 'Sumber Daya';

  @override
  String get powerGrid => 'Jaringan Listrik';

  @override
  String get noPowerCapacity =>
      'Tidak ada kapasitas listrik! Buka tab Energi dan bangun pembangkit listrik terlebih dahulu — semua bangunan lain membutuhkan listrik.';

  @override
  String noEnergyWarning(int needed, int available) {
    return 'Tidak cukup energi (butuh $needed MW, hanya $available MW tersedia). Bangun lebih banyak pembangkit listrik!';
  }

  @override
  String buildingNotEnoughCapital(int need, int have) {
    return 'Modal Politik tidak cukup (butuh $need, punya $have).';
  }

  @override
  String notEnoughTreasury(String needed, String have) {
    return 'Kas tidak cukup (butuh ${needed}M, punya ${have}M). Tunggu pendapatan tahunan!';
  }

  @override
  String buildingBuilt(String building) {
    return '$building dibangun!';
  }

  @override
  String buildingUpgraded(String building, int level) {
    return '$building ditingkatkan ke Level $level!';
  }

  @override
  String countriesFound(int count) {
    return '$count negara ditemukan';
  }

  @override
  String get hdi => 'IPM';

  @override
  String get corruptionIndex => 'Indeks Korupsi';

  @override
  String get taxPolicyTitle => 'Kebijakan Pajak';

  @override
  String get baseGovSpending => 'Belanja Pemerintah Dasar';

  @override
  String get revenueLabel => 'Pendapatan';

  @override
  String get capitalFlightLabel => 'Pelarian Modal';

  @override
  String needsCapitalToWar(int cost) {
    return 'Butuh 💎$cost modal politik untuk menyatakan perang.';
  }

  @override
  String get warConflict => 'Perang & Konflik';

  @override
  String get atWarStatus => 'BERPERANG';

  @override
  String get atPeaceStatus => 'DAMAI';

  @override
  String get currentlyAtPeace => 'Negara Anda saat ini dalam keadaan damai.';

  @override
  String get declaringWarWarning =>
      'Menyatakan perang akan memberikan penalti tahunan berat pada kebahagiaan, stabilitas, dan pertumbuhan PDB hingga perdamaian tercapai.';

  @override
  String get militaryCriticallyWeak =>
      'Militer sangat lemah — negosiasi damai akan dipaksa di akhir tahun.';

  @override
  String get militaryClassification => 'Klasifikasi Militer';

  @override
  String get naturalResources => 'Sumber Daya Alam';

  @override
  String get oilEnergyReserves => 'Cadangan Minyak & Energi';

  @override
  String get milBudgetMinimal => 'Minimal — kemampuan pertahanan menurun';

  @override
  String get milBudgetLow => 'Rendah — hanya deterensi dasar';

  @override
  String get milBudgetModerate => 'Sedang — pertahanan seimbang';

  @override
  String get milBudgetHigh => 'Tinggi — kekuatan regional yang kuat';

  @override
  String get milBudgetVeryHigh => 'Sangat Tinggi — investasi militer besar';

  @override
  String get milBudgetMaximum => 'Maksimum — kompleks industri militer penuh';

  @override
  String get strengthLabel => 'Kekuatan';

  @override
  String get troopsLabel => 'Pasukan';

  @override
  String get diploRepLabel => 'Rep. Diplo';

  @override
  String nationalDebtPct(String debt) {
    return '$debt% dari PDB';
  }

  @override
  String get alliedRelLabel => 'Bersekutu';

  @override
  String get diplomaticReputationTitle => 'Reputasi Diplomatik';

  @override
  String get highlyRespected => 'Sangat Dihormati';

  @override
  String get wellRegarded => 'Dipandang Baik';

  @override
  String get neutralStanding => 'Posisi Netral';

  @override
  String get controversial => 'Kontroversial';

  @override
  String get pariahState => 'Negara Pariah';

  @override
  String searchNCountries(int n) {
    return 'Cari $n negara…';
  }

  @override
  String get breakActionLabel => 'Putus';

  @override
  String get liftActionLabel => 'Cabut';

  @override
  String get allyActionLabel => 'Aliansi';

  @override
  String get sanctionActionLabel => 'Sanksi';

  @override
  String get historicLabel => 'Bersejarah';

  @override
  String get rivalLabel => 'Saingan';

  @override
  String get oneTimeCost => 'BIAYA SATU KALI';

  @override
  String get annualBenefits => 'MANFAAT TAHUNAN';

  @override
  String get effectsLabel => 'EFEK';

  @override
  String get repTooLow =>
      'Reputasi diplomatik terlalu rendah (butuh ≥30 untuk membentuk aliansi).';

  @override
  String notEnoughCapitalDiplo(int cost) {
    return '💎 Modal Politik tidak cukup (butuh $cost).';
  }

  @override
  String allianceFormedMsg(String country) {
    return '🤝 Aliansi terbentuk dengan $country!';
  }

  @override
  String allianceEndedMsg(String country) {
    return '✂️ Aliansi dengan $country berakhir.';
  }

  @override
  String sanctionsImposedMsg(String country) {
    return '⚠️ Sanksi diberlakukan pada $country.';
  }

  @override
  String sanctionsLiftedMsg(String country) {
    return '✅ Sanksi pada $country dicabut.';
  }

  @override
  String get allianceRepEffect => '+6 Reputasi Diplomatik';

  @override
  String get allianceGdpYearEffect => '+0.4% Pertumbuhan PDB per tahun';

  @override
  String get allianceHappinessEffect => '+2 Kebahagiaan';

  @override
  String get allianceStabilityEffect => '+1.5 Stabilitas per tahun';

  @override
  String get alliancePerAllyBonus => '+0.1% PDB/thn bonus per sekutu';

  @override
  String get breakRepEffect => '-8 Reputasi Diplomatik';

  @override
  String get breakGdpEffect => '-0.3% Pertumbuhan PDB';

  @override
  String get breakGdpBonusEffect => 'Kehilangan bonus PDB aliansi';

  @override
  String get sanctionRepEffect => '-4 Reputasi Diplomatik';

  @override
  String get sanctionGdpEffect =>
      '-0.05% Pertumbuhan PDB per negara yang disanksi/thn';

  @override
  String get sanctionTradeEffect => 'Menghentikan manfaat perdagangan';

  @override
  String get liftRepEffect => '+3 Reputasi Diplomatik';

  @override
  String get liftGdpEffect => 'Menghapus hambatan PDB -0.05%/thn';

  @override
  String get liftPathEffect => 'Membuka jalan menuju aliansi';

  @override
  String get costLabel => 'Biaya';

  @override
  String get splashTitle => 'WORLD PRESIDENT';

  @override
  String get splashSubtitle => 'SIMULATOR';

  @override
  String get applyButton => 'Terapkan';

  @override
  String get revokeButton => 'Cabut';

  @override
  String needCapitalButton(int cost) {
    return 'Butuh 💎$cost';
  }

  @override
  String get searchHint => 'Cari...';

  @override
  String get continentLabel => 'BENUA';

  @override
  String get allRegions => 'Semua Wilayah';

  @override
  String get leadNation => 'Pimpin Negara';

  @override
  String get countryProfile => 'Profil Negara';

  @override
  String get naturalAllies => 'Sekutu Alami';

  @override
  String get noActiveGame => 'Tidak ada permainan aktif';

  @override
  String get noPower => 'Tanpa Listrik';

  @override
  String mwUsed(String consumption, String capacity) {
    return '$consumption/$capacity MW terpakai';
  }

  @override
  String mwFree(String available) {
    return '($available MW tersedia)';
  }

  @override
  String generatesEnergyPerLevel(String mw, String max) {
    return 'Menghasilkan +$mw MW per level  •  Maks $max level';
  }

  @override
  String requiresEnergyActive(String mw) {
    return 'Membutuhkan $mw MW untuk beroperasi';
  }

  @override
  String requiresEnergyInactive(String mw) {
    return 'Membutuhkan $mw MW untuk beroperasi  •  belum dibangun';
  }

  @override
  String get notBuiltLabel => 'Belum Dibangun';

  @override
  String levelProgress(int level, int maxLevel) {
    return 'Lv $level / $maxLevel';
  }

  @override
  String upgradeToLevel(int level) {
    return 'Tingkatkan → Lv $level';
  }

  @override
  String needCapitalForBuilding(int cost) {
    return '💎 Butuh $cost';
  }

  @override
  String needMoneyForBuilding(String cost) {
    return '🪙 Butuh \$${cost}M';
  }

  @override
  String needEnergyForBuilding(String mw) {
    return '⚡ Butuh $mw MW';
  }

  @override
  String get impeachRisk => 'RISIKO PEMAKZULAN';

  @override
  String get lowApproval => 'Dukungan Rendah';

  @override
  String get happyLabel => 'Bahagia';

  @override
  String get stableLabel => 'Stabil';

  @override
  String get statusLabel => 'Status';

  @override
  String get approvalCritical =>
      'KRITIS — Majukan tahun untuk memicu pemakzulan!';

  @override
  String get approvalDangerouslyLow =>
      'Dukungan sangat rendah — dipakzulkan di 15%';

  @override
  String get capitalLabel => 'Modal';

  @override
  String get yourNation => 'Negara Anda';

  @override
  String get cannotBreakLabel => 'Tidak bisa diputus';

  @override
  String get needRepLabel => 'Perlu rep ≥30';

  @override
  String get fixedRelLabel => 'Tetap';

  @override
  String get diplomacyHeader => 'DIPLOMASI';

  @override
  String get diplomacyTab => 'Diplomasi';

  @override
  String get militaryTab => 'Militer';

  @override
  String get militaryIntel => 'INTELIJEN MILITER';

  @override
  String get estMilPower => 'Est. Kekuatan Mil.';

  @override
  String get estTroops => 'Est. Pasukan';

  @override
  String get threatLevel => 'Tingkat Ancaman';

  @override
  String get threatLow => 'Rendah';

  @override
  String get threatMedium => 'Sedang';

  @override
  String get threatHigh => 'TINGGI';

  @override
  String get warStatusLabel => 'Status Perang';

  @override
  String get notAtWarLabel => 'Damai';

  @override
  String get alreadyAtWar => 'Sudah berperang';

  @override
  String get cannotAttackAlly => 'Tidak bisa serang sekutu';

  @override
  String warDeclaredMsg(String country) {
    return '⚔️ Perang dideklarasikan terhadap $country!';
  }

  @override
  String peaceSuedMsg(String country) {
    return '🕊️ Damai dengan $country!';
  }

  @override
  String get peacefulNation => 'Damai';

  @override
  String get dashboardLabel => 'Dasbor';

  @override
  String get economySection => 'Ekonomi';

  @override
  String get societySection => 'Masyarakat';

  @override
  String get militaryDiplomacy => 'Militer & Diplomasi';

  @override
  String get resourcesSection => 'Sumber Daya';

  @override
  String get ratingLabel => 'Peringkat';

  @override
  String get growthLabel => 'Pertumbuhan';

  @override
  String get militaryStrLabel => 'Kekuatan Mil.';

  @override
  String get reputationLabel => 'Reputasi';

  @override
  String get treasuryBudgetTitle => 'Kas & Anggaran';

  @override
  String get netPerYearBadge => 'Net / tahun';

  @override
  String get govSpendingShort => 'Belanja Gov.';

  @override
  String get maintenanceLabel => 'Pemeliharaan';

  @override
  String get netThisYear => 'Net tahun ini';

  @override
  String currentApprovalPct(String approval) {
    return 'Dukungan saat ini: $approval%';
  }

  @override
  String get approvalCriticalNote =>
      'Dukungan kritis — dimakzulkan jika turun di bawah 15%';

  @override
  String advanceToYearTitle(int year) {
    return 'Majukan ke Tahun $year';
  }

  @override
  String yearsInOfficeLabel(int year) {
    return 'Tahun $year menjabat';
  }

  @override
  String get budgetProjection => 'PROYEKSI ANGGARAN';

  @override
  String yearXSummary(int year) {
    return 'Ringkasan Tahun $year';
  }

  @override
  String capitalEarned(int amount) {
    return 'Modal Politik diperoleh: +$amount 💎';
  }

  @override
  String get statChanges => 'PERUBAHAN STAT';

  @override
  String get criticalImpeachImminent =>
      'KRITIS: Pemakzulan segera jika dukungan turun di bawah 15%!';

  @override
  String warningApprovalAction(String approval) {
    return 'Peringatan: Dukungan di $approval% — ambil tindakan sebelum tahun depan.';
  }

  @override
  String get literacyLabel => 'Melek Huruf';

  @override
  String get milReadinessLabel => 'Kesiapan Mil.';

  @override
  String get govDemocracy => 'Demokrasi';

  @override
  String get govRepublic => 'Republik';

  @override
  String get govConstMonarchy => 'Monarki Konstitusional';

  @override
  String get govMonarchy => 'Monarki';

  @override
  String get govCommunist => 'Komunis';

  @override
  String get govTheocracy => 'Teokrasi';

  @override
  String get govAuthoritarian => 'Otoriter';

  @override
  String get govFederalRepublic => 'Republik Federal';

  @override
  String get govParliamentary => 'Parlementer';

  @override
  String get govMilitaryJunta => 'Junta Militer';

  @override
  String taxRevenueSub(String gdp, String rate) {
    return 'PDB \$$gdp × $rate%';
  }

  @override
  String pctOfGdpSub(String pct) {
    return '$pct% dari PDB';
  }

  @override
  String get tutStep1Title => '🌍 Selamat Datang, Pemimpin Dunia!';

  @override
  String get tutStep1Body =>
      'Anda sekarang memimpin sebuah negara. Peta dunia menampilkan semua negara — ketuk mana saja untuk melihat detail atau mengelola hubungan diplomatik.';

  @override
  String get tutStep2Title => '⏭️ Majukan Tahun';

  @override
  String get tutStep2Body =>
      'Ketuk tombol \"Tahun XXXX\" untuk melaju ke masa depan. Setiap tahun ekonomi, kebahagiaan, dan dukungan Anda diperbarui berdasarkan pilihan Anda.';

  @override
  String get tutStep3Title => '👑 Rating Dukungan';

  @override
  String get tutStep3Body =>
      'Jaga dukungan Anda di atas 15% atau Anda akan dimakzulkan! Seimbangkan tarif pajak, kebijakan, dan kebahagiaan untuk tetap berkuasa.';

  @override
  String get tutStep4Title => '📋 Kebijakan & Bangunan';

  @override
  String get tutStep4Body =>
      'Belanjakan 💎 Modal Politik untuk kebijakan, dan 🪙 Kas untuk bangunan. Selalu bangun Pembangkit Listrik terlebih dahulu — bangunan lain membutuhkan listrik!';

  @override
  String get tutStep5Title => '🪙 Kas & Diplomasi';

  @override
  String get tutStep5Body =>
      'Kas Anda mendanai negara. Ketuk lencana 🪙 untuk melihat anggaran lengkap. Ketuk negara mana saja untuk membentuk aliansi atau memberlakukan sanksi.';

  @override
  String tipCounter(int step, int total) {
    return 'TIP $step/$total';
  }

  @override
  String get skipLabel => 'Lewati';

  @override
  String get gotItLabel => 'Mengerti!';

  @override
  String get nextArrow => 'Selanjutnya →';

  @override
  String get warProgressLabel => 'Degradasi Musuh';
}
