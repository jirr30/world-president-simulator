// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'World President Simulator';

  @override
  String get appTitleLine1 => 'WORLD PRESIDENT';

  @override
  String get appTitleLine2 => 'SIMULATOR';

  @override
  String get appTagline1 => 'World President\nSimulator';

  @override
  String get appTagline2 =>
      'Lead any of 100+ real nations.\nShape history. Leave a legacy.';

  @override
  String get featureCountries => '195 Countries';

  @override
  String get featureRealData => 'Real Data';

  @override
  String get featureLiveEvents => 'Live Events';

  @override
  String get featureAutoSave => 'Auto-Save';

  @override
  String get continueGame => 'Continue Game';

  @override
  String get newGame => 'New Game';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get savedGameFound => 'Saved game found';

  @override
  String get startNewGameTitle => 'Start New Game?';

  @override
  String get startNewGameContent =>
      'Your saved progress will be overwritten when you start a new game.';

  @override
  String get howToPlay1Title => 'Choose Your Country';

  @override
  String get howToPlay1Desc =>
      'Pick from 195 real nations with actual economic and military data.';

  @override
  String get howToPlay2Title => 'Apply Policies';

  @override
  String get howToPlay2Desc =>
      'Choose economic, military, social, or diplomatic policies each term.';

  @override
  String get howToPlay3Title => 'Handle Events';

  @override
  String get howToPlay3Desc =>
      'Random world events will challenge your leadership. Choose wisely.';

  @override
  String get howToPlay4Title => 'Advance Year';

  @override
  String get howToPlay4Desc =>
      'Each year your decisions affect your approval rating and country stats.';

  @override
  String get howToPlay5Title => 'Auto-Save';

  @override
  String get howToPlay5Desc =>
      'Progress is saved automatically. Leave and continue anytime.';

  @override
  String get howToPlay6Title => 'Leave a Legacy';

  @override
  String get howToPlay6Desc =>
      'Survive your full term and be judged by history after 5 years.';

  @override
  String get progressAutoSaved => 'Progress auto-saved';

  @override
  String get policies => 'Policies';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabEconomy => 'Economy';

  @override
  String get tabMilitary => 'Military';

  @override
  String get tabDiplomacy => 'Diplomacy';

  @override
  String get tabSocial => 'Social';

  @override
  String advanceToYear(int year) {
    return 'Advance to $year';
  }

  @override
  String get leaveGameTitle => 'Leave Game?';

  @override
  String get leaveGameContent =>
      'Game is auto-saved. You can continue from the main menu.';

  @override
  String get cancel => 'Cancel';

  @override
  String get leave => 'Leave';

  @override
  String get approval => 'Approval';

  @override
  String leaderInfo(String title, int year, int yearsIn) {
    return '$title • Year $year • $yearsIn yrs in power';
  }

  @override
  String get statHappiness => 'Happiness';

  @override
  String get statStability => 'Stability';

  @override
  String get statGdpGrowth => 'GDP Growth';

  @override
  String get statCorruption => 'Corruption';

  @override
  String get gdpStatusBooming => 'Booming';

  @override
  String get gdpStatusStable => 'Stable';

  @override
  String get gdpStatusRecession => 'Recession';

  @override
  String get statGdp => 'GDP';

  @override
  String get diplomaticRelations => 'Diplomatic Relations';

  @override
  String get allies => 'Allies';

  @override
  String get rivals => 'Rivals';

  @override
  String get activePolicies => 'Active Policies';

  @override
  String activePoliciesCount(int count) {
    return 'Active Policies ($count)';
  }

  @override
  String get atWarBadge => 'AT WAR';

  @override
  String get population => 'Population';

  @override
  String get economicIndicators => 'Economic Indicators';

  @override
  String get totalGdp => 'Total GDP';

  @override
  String get gdpPerCapita => 'GDP per Capita';

  @override
  String get inflation => 'Inflation';

  @override
  String get unemployment => 'Unemployment';

  @override
  String get taxRate => 'Tax Rate';

  @override
  String get nationalDebt => 'National Debt';

  @override
  String get taxRateSliderTitle => 'Tax Rate';

  @override
  String get taxZoneSafe => 'Safe Zone';

  @override
  String get taxZoneWarning => 'Warning Zone';

  @override
  String get taxZoneDanger => 'Danger Zone';

  @override
  String get capitalFlightWarning => 'Capital Flight Risk';

  @override
  String get taxProtestImminent => 'Tax Protest Imminent';

  @override
  String get treasury => 'Treasury';

  @override
  String get treasuryBalance => 'Current Balance';

  @override
  String get budgetBreakdown => 'BUDGET BREAKDOWN';

  @override
  String get taxRevenue => 'Tax Revenue';

  @override
  String get govSpending => 'Government Spending';

  @override
  String get govSpendingSub => '20% of GDP';

  @override
  String get militaryBudgetLabel => 'Military Budget';

  @override
  String get healthcareLabel => 'Healthcare';

  @override
  String get educationLabel => 'Education';

  @override
  String get buildingMaintenance => 'Building Maintenance';

  @override
  String get buildingMaintenanceSub => '2%/lvl/year';

  @override
  String get activePoliciesCost => 'combined annual cost';

  @override
  String get netPerYear => 'Net per year';

  @override
  String get treasuryDeficit =>
      'Treasury deficit — GDP growth and happiness penalized';

  @override
  String get militaryStrength => 'Military Strength';

  @override
  String get militaryBudget => 'Military Budget';

  @override
  String get activeTroops => 'Active Troops';

  @override
  String get readiness => 'Readiness';

  @override
  String get warStatus => 'War Status';

  @override
  String get atWar => 'At War';

  @override
  String get atPeace => 'At Peace';

  @override
  String get declareWar => 'Declare War';

  @override
  String get sueForPeace => 'Sue for Peace';

  @override
  String get warControls => 'War Controls';

  @override
  String get militaryRank => 'Military Rank';

  @override
  String get strategicResources => 'Strategic Resources';

  @override
  String get educationIndex => 'Education Index';

  @override
  String get literacyRate => 'Literacy Rate';

  @override
  String get foodSecurity => 'Food Security';

  @override
  String get agriOutput => 'Agri. Output';

  @override
  String get socialInvestment => 'Social Investment';

  @override
  String get socialInvestmentSub =>
      'Extra funding on top of base government spending';

  @override
  String get none => 'None';

  @override
  String get foodAgricultureStatus => 'Food & Agriculture Status';

  @override
  String get foodSurplus => 'Food Surplus';

  @override
  String get foodSecure => 'Food Secure';

  @override
  String get moderateRisk => 'Moderate Risk';

  @override
  String get foodInsecure => 'Food Insecure';

  @override
  String get famineCrisis => 'Famine Crisis';

  @override
  String get populationOverview => 'Population Overview';

  @override
  String get totalPopulation => 'Total Population';

  @override
  String get growthRate => 'Growth Rate';

  @override
  String get capitalCity => 'Capital City';

  @override
  String get continent => 'Continent';

  @override
  String get government => 'Government';

  @override
  String get happinessScore => 'Happiness Score';

  @override
  String get chooseYourResponse => 'Choose Your Response:';

  @override
  String get confirmDecision => 'Confirm Decision';

  @override
  String get selectOptionFirst => 'Select an option first';

  @override
  String get continueGoverning => 'Continue Governing';

  @override
  String get impeachedBadge => 'IMPEACHED';

  @override
  String get termEndedBadge => 'TERM ENDED';

  @override
  String get invadedBadge => 'INVADED';

  @override
  String get countryFallen => 'Country Has Fallen';

  @override
  String invadedVerdictText(String country) {
    return '$country has been conquered by a foreign power. Your failure to defend the nation will be remembered throughout history.';
  }

  @override
  String get removedFromPower => 'Removed from Power';

  @override
  String get finalReport => 'Final Report';

  @override
  String get avgApproval => 'Avg Approval';

  @override
  String avgApprovalStat(String pct) {
    return 'Avg. approval: $pct%';
  }

  @override
  String get finalGdp => 'Final GDP';

  @override
  String get militaryStat => 'Military';

  @override
  String get diplomacy => 'Diplomacy';

  @override
  String get education => 'Education';

  @override
  String get policiesApplied => 'Policies Applied';

  @override
  String get yearsInPower => 'Years in Power';

  @override
  String get historicalVerdict => 'Historical Verdict';

  @override
  String get playAgain => 'Play Again';

  @override
  String get mainMenu => 'Main Menu';

  @override
  String verdictGreat(String country) {
    return 'History will remember your leadership with great admiration. You transformed $country into a beacon of prosperity and stability.';
  }

  @override
  String verdictGood(String country) {
    return 'You led $country competently and are well-regarded by your citizens. Your tenure saw genuine progress in key areas.';
  }

  @override
  String verdictAverage(String country) {
    return 'Your time as leader of $country was mixed. While you maintained stability, many citizens felt more could have been accomplished.';
  }

  @override
  String verdictPoor(String country) {
    return 'Your leadership divided the nation. Significant opposition marked your term. $country faced considerable challenges under your governance.';
  }

  @override
  String verdictBad(String country) {
    return 'Your term as leader of $country will be remembered as a turbulent period. Institutions weakened and the country\'\'s reputation declined.';
  }

  @override
  String impeachText1(String country) {
    return 'With approval at a catastrophic low, the people of $country took to the streets. Parliament voted unanimously to remove you. You will be remembered as the worst leader in the nation\'\'s history.';
  }

  @override
  String impeachText2(String country) {
    return 'Mass protests and a parliamentary vote forced you out of office. Your policies failed the people of $country and history will not be kind to your legacy.';
  }

  @override
  String impeachText3(String country) {
    return 'Public trust collapsed beyond recovery. Facing impeachment proceedings in parliament, you were removed from office. $country moves forward without you.';
  }

  @override
  String get selectCountry => 'Select Your Country';

  @override
  String get searchCountries => 'Search countries...';

  @override
  String get filterAll => 'All';

  @override
  String get filterAfrica => 'Africa';

  @override
  String get filterAsia => 'Asia';

  @override
  String get filterEurope => 'Europe';

  @override
  String get filterAmericas => 'Americas';

  @override
  String get filterOceania => 'Oceania';

  @override
  String get startGame => 'Start Game';

  @override
  String get countryGdp => 'GDP';

  @override
  String get countryPopulation => 'Population';

  @override
  String get countryMilitary => 'Military';

  @override
  String get countryHdi => 'HDI';

  @override
  String get countryContinent => 'Continent';

  @override
  String get countryCapital => 'Capital';

  @override
  String get countryGovernment => 'Government';

  @override
  String get policyScreen => 'Policies';

  @override
  String get applyPolicy => 'Apply';

  @override
  String get removePolicy => 'Remove';

  @override
  String get policyActive => 'Active';

  @override
  String get policyCost => 'Cost';

  @override
  String get policyEffect => 'Effects';

  @override
  String get buildingsScreen => 'Infrastructure';

  @override
  String get build => 'Build';

  @override
  String get upgrade => 'Upgrade';

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get maxLevel => 'Max Level';

  @override
  String get natResources => 'Nat. Resources';

  @override
  String get oilReserves => 'Oil Reserves';

  @override
  String get diplomaticReputation => 'Diplomatic Rep.';

  @override
  String get formAlliance => 'Form Alliance';

  @override
  String get breakAlliance => 'Break Alliance';

  @override
  String get imposeSanction => 'Impose Sanction';

  @override
  String get liftSanction => 'Lift Sanction';

  @override
  String get allyRelation => 'Allied';

  @override
  String get historicAlly => 'Historic Ally';

  @override
  String get neutral => 'Neutral';

  @override
  String get sanctioned => 'Sanctioned';

  @override
  String get historicRival => 'Historic Rival';

  @override
  String get yearSummary => 'Year in Review';

  @override
  String yearSummarySubtitle(int year) {
    return 'Year $year Results';
  }

  @override
  String get noChanges => 'No significant changes this year.';

  @override
  String get continueBtn => 'Continue';

  @override
  String get politicalCapital => 'Political Capital';

  @override
  String get languageLabel => 'Language';

  @override
  String get langEnglish => 'English';

  @override
  String get langIndonesian => 'Indonesia';

  @override
  String get settings => 'Settings';

  @override
  String pageNotFound(String path) {
    return 'Page not found: $path';
  }

  @override
  String get goHome => 'Go Home';

  @override
  String get ultraLowTaxRate => 'Ultra Low — private sector surge';

  @override
  String get veryLowTaxRate => 'Very Low — minimal public services';

  @override
  String get lowTaxRate => 'Low — lean government';

  @override
  String get moderateTaxRate => 'Moderate — balanced budget';

  @override
  String get highTaxRate => 'High — strong public investment';

  @override
  String get veryHighTaxRate => 'Very High — risk of capital flight';

  @override
  String get extremeTaxRate => 'Extreme — capital flight + protest risk';

  @override
  String get protestConditionsActive =>
      'PROTEST CONDITIONS ACTIVE — Mass protests will erupt next year. Lower tax below 45% or raise happiness above 40 to prevent them.';

  @override
  String get capitalFlightActive =>
      'Capital flight active — investors are leaving. If happiness falls below 40, mass protests will erupt.';

  @override
  String newRateTakesEffect(String taxRate) {
    return 'New rate $taxRate% takes full effect next year.';
  }

  @override
  String get taxZoneSafeLabel => 'Safe';

  @override
  String get taxZoneWarningLabel => 'Warning';

  @override
  String get taxZoneCrisisLabel => 'Crisis';

  @override
  String get healthyDebt => 'Healthy debt level — economy is sustainable.';

  @override
  String get moderateDebt => 'Moderate debt — monitor carefully.';

  @override
  String get dangerousDebt => 'Dangerous debt level — risk of default!';

  @override
  String get declareWarTitle => 'Declare War?';

  @override
  String get declareWarSubtitle =>
      'This will put your country on a war footing.';

  @override
  String get ongoingWarPenalties => 'Ongoing war penalties (per year):';

  @override
  String get militaryWeakWarning =>
      'Military critically weak — peace negotiations will be forced at end of year.';

  @override
  String get countryAtPeace => 'Your country is currently at peace.';

  @override
  String get declareWarWarning =>
      'Declaring war will impose severe annual penalties on happiness, stability, and GDP growth until peace is negotiated.';

  @override
  String get sueForPeaceTitle => 'Sue for Peace?';

  @override
  String get sueForPeaceSubtitle => 'End the conflict and return to peacetime.';

  @override
  String get activeConflict => 'Active Conflict';

  @override
  String get percentOfGdp => '% of GDP';

  @override
  String get minimalMilBudget => 'Minimal — defense capability degrading';

  @override
  String get lowMilBudget => 'Low — basic deterrence only';

  @override
  String get moderateMilBudget => 'Moderate — balanced defense';

  @override
  String get highMilBudget => 'High — strong regional power';

  @override
  String get veryHighMilBudget => 'Very High — major military investment';

  @override
  String get maxMilBudget => 'Maximum — full military-industrial complex';

  @override
  String newBudgetTakesEffect(String percent, String budget) {
    return 'New budget $percent% GDP ($budget) takes effect next year.';
  }

  @override
  String get globalSuperpower => 'Global Superpower';

  @override
  String get majorMilitaryPower => 'Major Military Power';

  @override
  String get regionalPower => 'Regional Power';

  @override
  String get moderateForce => 'Moderate Force';

  @override
  String get limitedCapability => 'Limited Capability';

  @override
  String get minimalDefense => 'Minimal Defense';

  @override
  String get noCountriesMatch => 'No countries match your search.';

  @override
  String get repLocked =>
      'Rep < 30 — alliances locked.\nImprove reputation to unlock.';

  @override
  String get yourAlliances => 'Your Alliances';

  @override
  String get yourSanctions => 'Your Sanctions';

  @override
  String get historicAllies => 'Historic Allies';

  @override
  String get historicRivals => 'Historic Rivals';

  @override
  String get noActiveRelations =>
      'No active relations.\nUse the browser →\nto form alliances.';

  @override
  String get preExisting => 'Pre-existing';

  @override
  String alliancesCount(int count) {
    return '$count Allies';
  }

  @override
  String rivalsCount(int count) {
    return '$count Rivals';
  }

  @override
  String allianceGdpBonus(String bonus) {
    return '+$bonus% GDP/yr from alliances';
  }

  @override
  String confirmFormAlliance(String country) {
    return 'Form Alliance with $country?';
  }

  @override
  String confirmBreakAlliance(String country) {
    return 'Break Alliance with $country?';
  }

  @override
  String confirmSanction(String country) {
    return 'Impose Sanctions on $country?';
  }

  @override
  String confirmLiftSanction(String country) {
    return 'Lift Sanctions on $country?';
  }

  @override
  String get economicTab => 'Economic';

  @override
  String get diplomaticTab => 'Diplomatic';

  @override
  String policyNotEnoughCapital(int needed, int have) {
    return 'Not enough Political Capital (need $needed, have $have).';
  }

  @override
  String notEnoughApproval(int minApproval) {
    return 'You need at least $minApproval% approval to apply this policy.';
  }

  @override
  String policyAlreadyActive(String policy) {
    return '$policy is already active.';
  }

  @override
  String policyApplied(String policy) {
    return '$policy has been applied!';
  }

  @override
  String revokePolicy(String policy) {
    return 'Revoke \"$policy\"?';
  }

  @override
  String get revokeDescription => 'Revoking this policy will:';

  @override
  String get revokeCostDrain => 'Stop the annual cost drain';

  @override
  String get revokeEffectsReversal => 'Partially reverse effects (40%)';

  @override
  String revokeRefund(int refund) {
    return 'Refund $refund Political Capital';
  }

  @override
  String get revokePolicyButton => 'Revoke Policy';

  @override
  String revokeSuccess(String policy, int refund) {
    return '$policy revoked. +$refund refunded.';
  }

  @override
  String get bonusPerLevel => 'Bonus per level / year:';

  @override
  String get infrastructureTitle => 'Infrastructure';

  @override
  String get energyTab => 'Energy';

  @override
  String get foodTab => 'Food';

  @override
  String get resourcesTab => 'Resources';

  @override
  String get powerGrid => 'Power Grid';

  @override
  String get noPowerCapacity =>
      'No power capacity! Go to the Energy tab and build a power plant first — all other buildings require electricity.';

  @override
  String noEnergyWarning(int needed, int available) {
    return 'Not enough energy (need $needed MW, only $available MW free). Build more power plants!';
  }

  @override
  String buildingNotEnoughCapital(int need, int have) {
    return 'Not enough Political Capital (need $need, have $have).';
  }

  @override
  String notEnoughTreasury(String needed, String have) {
    return 'Not enough Treasury (need \$${needed}B, have \$${have}B). Wait for annual income!';
  }

  @override
  String buildingBuilt(String building) {
    return '$building built!';
  }

  @override
  String buildingUpgraded(String building, int level) {
    return '$building upgraded to Level $level!';
  }

  @override
  String countriesFound(int count) {
    return '$count countries found';
  }

  @override
  String get hdi => 'HDI';

  @override
  String get corruptionIndex => 'Corruption Index';

  @override
  String get taxPolicyTitle => 'Tax Policy';

  @override
  String get baseGovSpending => 'Base Gov. Spending';

  @override
  String get revenueLabel => 'Revenue';

  @override
  String get capitalFlightLabel => 'Capital Flight';

  @override
  String needsCapitalToWar(int cost) {
    return 'Need 💎$cost political capital to declare war.';
  }

  @override
  String get warConflict => 'War & Conflict';

  @override
  String get atWarStatus => 'AT WAR';

  @override
  String get atPeaceStatus => 'AT PEACE';

  @override
  String get currentlyAtPeace => 'Your country is currently at peace.';

  @override
  String get declaringWarWarning =>
      'Declaring war will impose severe annual penalties on happiness, stability, and GDP growth until peace is negotiated.';

  @override
  String get militaryCriticallyWeak =>
      'Military critically weak — peace negotiations will be forced at end of year.';

  @override
  String get militaryClassification => 'Military Classification';

  @override
  String get naturalResources => 'Natural Resources';

  @override
  String get oilEnergyReserves => 'Oil & Energy Reserves';

  @override
  String get milBudgetMinimal => 'Minimal — defense capability degrading';

  @override
  String get milBudgetLow => 'Low — basic deterrence only';

  @override
  String get milBudgetModerate => 'Moderate — balanced defense';

  @override
  String get milBudgetHigh => 'High — strong regional power';

  @override
  String get milBudgetVeryHigh => 'Very High — major military investment';

  @override
  String get milBudgetMaximum => 'Maximum — full military-industrial complex';

  @override
  String get strengthLabel => 'Strength';

  @override
  String get troopsLabel => 'Troops';

  @override
  String get diploRepLabel => 'Diplo Rep';

  @override
  String nationalDebtPct(String debt) {
    return '$debt% of GDP';
  }

  @override
  String get alliedRelLabel => 'Allied';

  @override
  String get diplomaticReputationTitle => 'Diplomatic Reputation';

  @override
  String get highlyRespected => 'Highly Respected';

  @override
  String get wellRegarded => 'Well-regarded';

  @override
  String get neutralStanding => 'Neutral Standing';

  @override
  String get controversial => 'Controversial';

  @override
  String get pariahState => 'Pariah State';

  @override
  String searchNCountries(int n) {
    return 'Search $n countries…';
  }

  @override
  String get breakActionLabel => 'Break';

  @override
  String get liftActionLabel => 'Lift';

  @override
  String get allyActionLabel => 'Ally';

  @override
  String get sanctionActionLabel => 'Sanction';

  @override
  String get historicLabel => 'Historic';

  @override
  String get rivalLabel => 'Rival';

  @override
  String get oneTimeCost => 'ONE-TIME COST';

  @override
  String get annualBenefits => 'ANNUAL BENEFITS';

  @override
  String get effectsLabel => 'EFFECTS';

  @override
  String get repTooLow =>
      'Diplomatic reputation too low (need ≥30 to form alliances).';

  @override
  String notEnoughCapitalDiplo(int cost) {
    return '💎 Not enough Political Capital (need $cost).';
  }

  @override
  String allianceFormedMsg(String country) {
    return '🤝 Alliance formed with $country!';
  }

  @override
  String allianceEndedMsg(String country) {
    return '✂️ Alliance with $country ended.';
  }

  @override
  String sanctionsImposedMsg(String country) {
    return '⚠️ Sanctions imposed on $country.';
  }

  @override
  String sanctionsLiftedMsg(String country) {
    return '✅ Sanctions on $country lifted.';
  }

  @override
  String get allianceRepEffect => '+6 Diplomatic Reputation';

  @override
  String get allianceGdpYearEffect => '+0.4% GDP Growth per year';

  @override
  String get allianceHappinessEffect => '+2 Happiness';

  @override
  String get allianceStabilityEffect => '+1.5 Stability per year';

  @override
  String get alliancePerAllyBonus => '+0.1% GDP/yr bonus per total ally';

  @override
  String get breakRepEffect => '-8 Diplomatic Reputation';

  @override
  String get breakGdpEffect => '-0.3% GDP Growth';

  @override
  String get breakGdpBonusEffect => 'Lose ongoing alliance GDP bonus';

  @override
  String get sanctionRepEffect => '-4 Diplomatic Reputation';

  @override
  String get sanctionGdpEffect => '-0.05% GDP Growth per sanctioned country/yr';

  @override
  String get sanctionTradeEffect => 'Stops ongoing trade benefits';

  @override
  String get liftRepEffect => '+3 Diplomatic Reputation';

  @override
  String get liftGdpEffect => 'Removes -0.05% GDP drag/yr';

  @override
  String get liftPathEffect => 'Opens path to future alliance';

  @override
  String get costLabel => 'Cost';

  @override
  String get splashTitle => 'WORLD PRESIDENT';

  @override
  String get splashSubtitle => 'SIMULATOR';

  @override
  String get applyButton => 'Apply';

  @override
  String get revokeButton => 'Revoke';

  @override
  String needCapitalButton(int cost) {
    return 'Need 💎$cost';
  }

  @override
  String get searchHint => 'Search...';

  @override
  String get continentLabel => 'CONTINENT';

  @override
  String get allRegions => 'All Regions';

  @override
  String get leadNation => 'Lead Nation';

  @override
  String get countryProfile => 'Country Profile';

  @override
  String get naturalAllies => 'Natural Allies';

  @override
  String get noActiveGame => 'No active game';

  @override
  String get noPower => 'No Power';

  @override
  String mwUsed(String consumption, String capacity) {
    return '$consumption/$capacity MW used';
  }

  @override
  String mwFree(String available) {
    return '($available MW free)';
  }

  @override
  String generatesEnergyPerLevel(String mw, String max) {
    return 'Generates +$mw MW per level  •  Max $max levels';
  }

  @override
  String requiresEnergyActive(String mw) {
    return 'Requires $mw MW to operate';
  }

  @override
  String requiresEnergyInactive(String mw) {
    return 'Requires $mw MW to operate  •  not yet built';
  }

  @override
  String get notBuiltLabel => 'Not Built';

  @override
  String levelProgress(int level, int maxLevel) {
    return 'Lv $level / $maxLevel';
  }

  @override
  String upgradeToLevel(int level) {
    return 'Upgrade → Lv $level';
  }

  @override
  String needCapitalForBuilding(int cost) {
    return '💎 Need $cost';
  }

  @override
  String needMoneyForBuilding(String cost) {
    return '🪙 Need \$${cost}B';
  }

  @override
  String needEnergyForBuilding(String mw) {
    return '⚡ Need $mw MW';
  }

  @override
  String get impeachRisk => 'IMPEACH RISK';

  @override
  String get lowApproval => 'Low Approval';

  @override
  String get happyLabel => 'Happy';

  @override
  String get stableLabel => 'Stable';

  @override
  String get statusLabel => 'Status';

  @override
  String get approvalCritical =>
      'CRITICAL — Advance year to trigger impeachment!';

  @override
  String get approvalDangerouslyLow =>
      'Approval dangerously low — impeached at 15%';

  @override
  String get capitalLabel => 'Capital';

  @override
  String get yourNation => 'Your Nation';

  @override
  String get cannotBreakLabel => 'Cannot break';

  @override
  String get needRepLabel => 'Need rep ≥30';

  @override
  String get fixedRelLabel => 'Fixed';

  @override
  String get diplomacyHeader => 'DIPLOMACY';

  @override
  String get dashboardLabel => 'Dashboard';

  @override
  String get economySection => 'Economy';

  @override
  String get societySection => 'Society';

  @override
  String get militaryDiplomacy => 'Military & Diplomacy';

  @override
  String get resourcesSection => 'Resources';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get growthLabel => 'Growth';

  @override
  String get militaryStrLabel => 'Military Str.';

  @override
  String get reputationLabel => 'Reputation';

  @override
  String get treasuryBudgetTitle => 'Treasury & Budget';

  @override
  String get netPerYearBadge => 'Net / year';

  @override
  String get govSpendingShort => 'Gov. Spending';

  @override
  String get maintenanceLabel => 'Maintenance';

  @override
  String get netThisYear => 'Net this year';

  @override
  String currentApprovalPct(String approval) {
    return 'Current approval: $approval%';
  }

  @override
  String get approvalCriticalNote =>
      'Approval critical — impeached if it drops below 15%';

  @override
  String advanceToYearTitle(int year) {
    return 'Advance to Year $year';
  }

  @override
  String yearsInOfficeLabel(int year) {
    return 'Year $year in office';
  }

  @override
  String get budgetProjection => 'BUDGET PROJECTION';

  @override
  String yearXSummary(int year) {
    return 'Year $year Summary';
  }

  @override
  String capitalEarned(int amount) {
    return 'Political Capital earned: +$amount 💎';
  }

  @override
  String get statChanges => 'STAT CHANGES';

  @override
  String get criticalImpeachImminent =>
      'CRITICAL: Impeachment imminent if approval drops below 15%!';

  @override
  String warningApprovalAction(String approval) {
    return 'Warning: Approval at $approval% — take action before next year.';
  }

  @override
  String get literacyLabel => 'Literacy';

  @override
  String get milReadinessLabel => 'Mil. Readiness';

  @override
  String get govDemocracy => 'Democracy';

  @override
  String get govRepublic => 'Republic';

  @override
  String get govConstMonarchy => 'Const. Monarchy';

  @override
  String get govMonarchy => 'Monarchy';

  @override
  String get govCommunist => 'Communist';

  @override
  String get govTheocracy => 'Theocracy';

  @override
  String get govAuthoritarian => 'Authoritarian';

  @override
  String get govFederalRepublic => 'Federal Republic';

  @override
  String get govParliamentary => 'Parliamentary';

  @override
  String get govMilitaryJunta => 'Military Junta';

  @override
  String taxRevenueSub(String gdp, String rate) {
    return 'GDP \$$gdp × $rate%';
  }

  @override
  String pctOfGdpSub(String pct) {
    return '$pct% of GDP';
  }

  @override
  String get tutStep1Title => '🌍 Welcome, World Leader!';

  @override
  String get tutStep1Body =>
      'You are now in charge of a nation. The world map shows all countries — tap any to view details or manage diplomatic relations.';

  @override
  String get tutStep2Title => '⏭️ Advance the Year';

  @override
  String get tutStep2Body =>
      'Tap the \"Year XXXX\" button to move time forward. Each year your economy, happiness, and approval update based on your choices.';

  @override
  String get tutStep3Title => '👑 Approval Rating';

  @override
  String get tutStep3Body =>
      'Keep your approval above 15% or you\'\'ll be impeached! Balance tax rates, policies, and happiness to stay in power.';

  @override
  String get tutStep4Title => '📋 Policies & Buildings';

  @override
  String get tutStep4Body =>
      'Spend 💎 Political Capital on policies, and 🪙 Treasury on buildings. Always build a Power Plant first — other buildings need electricity!';

  @override
  String get tutStep5Title => '🪙 Treasury & Diplomacy';

  @override
  String get tutStep5Body =>
      'Your treasury funds the nation. Tap the 🪙 badge to see the full budget. Tap any country to form alliances or impose sanctions.';

  @override
  String tipCounter(int step, int total) {
    return 'TIP $step/$total';
  }

  @override
  String get skipLabel => 'Skip';

  @override
  String get gotItLabel => 'Got it!';

  @override
  String get nextArrow => 'Next →';
}
