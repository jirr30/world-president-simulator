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
/// import 'l10n/app_localizations.dart';
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
    Locale('id')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'World President Simulator'**
  String get appTitle;

  /// Splash screen line 1
  ///
  /// In en, this message translates to:
  /// **'WORLD PRESIDENT'**
  String get appTitleLine1;

  /// Splash screen line 2
  ///
  /// In en, this message translates to:
  /// **'SIMULATOR'**
  String get appTitleLine2;

  /// Home screen branding title
  ///
  /// In en, this message translates to:
  /// **'World President\nSimulator'**
  String get appTagline1;

  /// Home screen branding subtitle
  ///
  /// In en, this message translates to:
  /// **'Lead any of 100+ real nations.\nShape history. Leave a legacy.'**
  String get appTagline2;

  /// No description provided for @featureCountries.
  ///
  /// In en, this message translates to:
  /// **'195 Countries'**
  String get featureCountries;

  /// No description provided for @featureRealData.
  ///
  /// In en, this message translates to:
  /// **'Real Data'**
  String get featureRealData;

  /// No description provided for @featureLiveEvents.
  ///
  /// In en, this message translates to:
  /// **'Live Events'**
  String get featureLiveEvents;

  /// No description provided for @featureAutoSave.
  ///
  /// In en, this message translates to:
  /// **'Auto-Save'**
  String get featureAutoSave;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue Game'**
  String get continueGame;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// No description provided for @savedGameFound.
  ///
  /// In en, this message translates to:
  /// **'Saved game found'**
  String get savedGameFound;

  /// No description provided for @startNewGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Start New Game?'**
  String get startNewGameTitle;

  /// No description provided for @startNewGameContent.
  ///
  /// In en, this message translates to:
  /// **'Your saved progress will be overwritten when you start a new game.'**
  String get startNewGameContent;

  /// No description provided for @howToPlay1Title.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Country'**
  String get howToPlay1Title;

  /// No description provided for @howToPlay1Desc.
  ///
  /// In en, this message translates to:
  /// **'Pick from 195 real nations with actual economic and military data.'**
  String get howToPlay1Desc;

  /// No description provided for @howToPlay2Title.
  ///
  /// In en, this message translates to:
  /// **'Apply Policies'**
  String get howToPlay2Title;

  /// No description provided for @howToPlay2Desc.
  ///
  /// In en, this message translates to:
  /// **'Choose economic, military, social, or diplomatic policies each term.'**
  String get howToPlay2Desc;

  /// No description provided for @howToPlay3Title.
  ///
  /// In en, this message translates to:
  /// **'Handle Events'**
  String get howToPlay3Title;

  /// No description provided for @howToPlay3Desc.
  ///
  /// In en, this message translates to:
  /// **'Random world events will challenge your leadership. Choose wisely.'**
  String get howToPlay3Desc;

  /// No description provided for @howToPlay4Title.
  ///
  /// In en, this message translates to:
  /// **'Advance Year'**
  String get howToPlay4Title;

  /// No description provided for @howToPlay4Desc.
  ///
  /// In en, this message translates to:
  /// **'Each year your decisions affect your approval rating and country stats.'**
  String get howToPlay4Desc;

  /// No description provided for @howToPlay5Title.
  ///
  /// In en, this message translates to:
  /// **'Auto-Save'**
  String get howToPlay5Title;

  /// No description provided for @howToPlay5Desc.
  ///
  /// In en, this message translates to:
  /// **'Progress is saved automatically. Leave and continue anytime.'**
  String get howToPlay5Desc;

  /// No description provided for @howToPlay6Title.
  ///
  /// In en, this message translates to:
  /// **'Leave a Legacy'**
  String get howToPlay6Title;

  /// No description provided for @howToPlay6Desc.
  ///
  /// In en, this message translates to:
  /// **'Survive your full term and be judged by history after 5 years.'**
  String get howToPlay6Desc;

  /// No description provided for @progressAutoSaved.
  ///
  /// In en, this message translates to:
  /// **'Progress auto-saved'**
  String get progressAutoSaved;

  /// No description provided for @policies.
  ///
  /// In en, this message translates to:
  /// **'Policies'**
  String get policies;

  /// No description provided for @tabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tabOverview;

  /// No description provided for @tabEconomy.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get tabEconomy;

  /// No description provided for @tabMilitary.
  ///
  /// In en, this message translates to:
  /// **'Military'**
  String get tabMilitary;

  /// No description provided for @tabDiplomacy.
  ///
  /// In en, this message translates to:
  /// **'Diplomacy'**
  String get tabDiplomacy;

  /// No description provided for @tabSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get tabSocial;

  /// No description provided for @advanceToYear.
  ///
  /// In en, this message translates to:
  /// **'Advance to {year}'**
  String advanceToYear(int year);

  /// No description provided for @leaveGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Game?'**
  String get leaveGameTitle;

  /// No description provided for @leaveGameContent.
  ///
  /// In en, this message translates to:
  /// **'Game is auto-saved. You can continue from the main menu.'**
  String get leaveGameContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @approval.
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get approval;

  /// No description provided for @leaderInfo.
  ///
  /// In en, this message translates to:
  /// **'{title} • Year {year} • {yearsIn} yrs in power'**
  String leaderInfo(String title, int year, int yearsIn);

  /// No description provided for @statHappiness.
  ///
  /// In en, this message translates to:
  /// **'Happiness'**
  String get statHappiness;

  /// No description provided for @statStability.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get statStability;

  /// No description provided for @statGdpGrowth.
  ///
  /// In en, this message translates to:
  /// **'GDP Growth'**
  String get statGdpGrowth;

  /// No description provided for @statCorruption.
  ///
  /// In en, this message translates to:
  /// **'Corruption'**
  String get statCorruption;

  /// No description provided for @gdpStatusBooming.
  ///
  /// In en, this message translates to:
  /// **'Booming'**
  String get gdpStatusBooming;

  /// No description provided for @gdpStatusStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get gdpStatusStable;

  /// No description provided for @gdpStatusRecession.
  ///
  /// In en, this message translates to:
  /// **'Recession'**
  String get gdpStatusRecession;

  /// No description provided for @statGdp.
  ///
  /// In en, this message translates to:
  /// **'GDP'**
  String get statGdp;

  /// No description provided for @diplomaticRelations.
  ///
  /// In en, this message translates to:
  /// **'Diplomatic Relations'**
  String get diplomaticRelations;

  /// No description provided for @allies.
  ///
  /// In en, this message translates to:
  /// **'Allies'**
  String get allies;

  /// No description provided for @rivals.
  ///
  /// In en, this message translates to:
  /// **'Rivals'**
  String get rivals;

  /// No description provided for @activePolicies.
  ///
  /// In en, this message translates to:
  /// **'Active Policies'**
  String get activePolicies;

  /// No description provided for @activePoliciesCount.
  ///
  /// In en, this message translates to:
  /// **'Active Policies ({count})'**
  String activePoliciesCount(int count);

  /// No description provided for @atWarBadge.
  ///
  /// In en, this message translates to:
  /// **'AT WAR'**
  String get atWarBadge;

  /// No description provided for @population.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get population;

  /// No description provided for @economicIndicators.
  ///
  /// In en, this message translates to:
  /// **'Economic Indicators'**
  String get economicIndicators;

  /// No description provided for @totalGdp.
  ///
  /// In en, this message translates to:
  /// **'Total GDP'**
  String get totalGdp;

  /// No description provided for @gdpPerCapita.
  ///
  /// In en, this message translates to:
  /// **'GDP per Capita'**
  String get gdpPerCapita;

  /// No description provided for @inflation.
  ///
  /// In en, this message translates to:
  /// **'Inflation'**
  String get inflation;

  /// No description provided for @unemployment.
  ///
  /// In en, this message translates to:
  /// **'Unemployment'**
  String get unemployment;

  /// No description provided for @taxRate.
  ///
  /// In en, this message translates to:
  /// **'Tax Rate'**
  String get taxRate;

  /// No description provided for @nationalDebt.
  ///
  /// In en, this message translates to:
  /// **'National Debt'**
  String get nationalDebt;

  /// No description provided for @taxRateSliderTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax Rate'**
  String get taxRateSliderTitle;

  /// No description provided for @taxZoneSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe Zone'**
  String get taxZoneSafe;

  /// No description provided for @taxZoneWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning Zone'**
  String get taxZoneWarning;

  /// No description provided for @taxZoneDanger.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get taxZoneDanger;

  /// No description provided for @capitalFlightWarning.
  ///
  /// In en, this message translates to:
  /// **'Capital Flight Risk'**
  String get capitalFlightWarning;

  /// No description provided for @taxProtestImminent.
  ///
  /// In en, this message translates to:
  /// **'Tax Protest Imminent'**
  String get taxProtestImminent;

  /// No description provided for @treasury.
  ///
  /// In en, this message translates to:
  /// **'Treasury'**
  String get treasury;

  /// No description provided for @treasuryBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get treasuryBalance;

  /// No description provided for @budgetBreakdown.
  ///
  /// In en, this message translates to:
  /// **'BUDGET BREAKDOWN'**
  String get budgetBreakdown;

  /// No description provided for @taxRevenue.
  ///
  /// In en, this message translates to:
  /// **'Tax Revenue'**
  String get taxRevenue;

  /// No description provided for @govSpending.
  ///
  /// In en, this message translates to:
  /// **'Government Spending'**
  String get govSpending;

  /// No description provided for @govSpendingSub.
  ///
  /// In en, this message translates to:
  /// **'20% of GDP'**
  String get govSpendingSub;

  /// No description provided for @militaryBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Military Budget'**
  String get militaryBudgetLabel;

  /// No description provided for @healthcareLabel.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get healthcareLabel;

  /// No description provided for @educationLabel.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get educationLabel;

  /// No description provided for @buildingMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Building Maintenance'**
  String get buildingMaintenance;

  /// No description provided for @buildingMaintenanceSub.
  ///
  /// In en, this message translates to:
  /// **'2%/lvl/year'**
  String get buildingMaintenanceSub;

  /// No description provided for @activePoliciesCost.
  ///
  /// In en, this message translates to:
  /// **'combined annual cost'**
  String get activePoliciesCost;

  /// No description provided for @netPerYear.
  ///
  /// In en, this message translates to:
  /// **'Net per year'**
  String get netPerYear;

  /// No description provided for @treasuryDeficit.
  ///
  /// In en, this message translates to:
  /// **'Treasury deficit — GDP growth and happiness penalized'**
  String get treasuryDeficit;

  /// No description provided for @militaryStrength.
  ///
  /// In en, this message translates to:
  /// **'Military Strength'**
  String get militaryStrength;

  /// No description provided for @militaryBudget.
  ///
  /// In en, this message translates to:
  /// **'Military Budget'**
  String get militaryBudget;

  /// No description provided for @activeTroops.
  ///
  /// In en, this message translates to:
  /// **'Active Troops'**
  String get activeTroops;

  /// No description provided for @readiness.
  ///
  /// In en, this message translates to:
  /// **'Readiness'**
  String get readiness;

  /// No description provided for @warStatus.
  ///
  /// In en, this message translates to:
  /// **'War Status'**
  String get warStatus;

  /// No description provided for @atWar.
  ///
  /// In en, this message translates to:
  /// **'At War'**
  String get atWar;

  /// No description provided for @atPeace.
  ///
  /// In en, this message translates to:
  /// **'At Peace'**
  String get atPeace;

  /// No description provided for @declareWar.
  ///
  /// In en, this message translates to:
  /// **'Declare War'**
  String get declareWar;

  /// No description provided for @sueForPeace.
  ///
  /// In en, this message translates to:
  /// **'Sue for Peace'**
  String get sueForPeace;

  /// No description provided for @warControls.
  ///
  /// In en, this message translates to:
  /// **'War Controls'**
  String get warControls;

  /// No description provided for @militaryRank.
  ///
  /// In en, this message translates to:
  /// **'Military Rank'**
  String get militaryRank;

  /// No description provided for @strategicResources.
  ///
  /// In en, this message translates to:
  /// **'Strategic Resources'**
  String get strategicResources;

  /// No description provided for @educationIndex.
  ///
  /// In en, this message translates to:
  /// **'Education Index'**
  String get educationIndex;

  /// No description provided for @literacyRate.
  ///
  /// In en, this message translates to:
  /// **'Literacy Rate'**
  String get literacyRate;

  /// No description provided for @foodSecurity.
  ///
  /// In en, this message translates to:
  /// **'Food Security'**
  String get foodSecurity;

  /// No description provided for @agriOutput.
  ///
  /// In en, this message translates to:
  /// **'Agri. Output'**
  String get agriOutput;

  /// No description provided for @socialInvestment.
  ///
  /// In en, this message translates to:
  /// **'Social Investment'**
  String get socialInvestment;

  /// No description provided for @socialInvestmentSub.
  ///
  /// In en, this message translates to:
  /// **'Extra funding on top of base government spending'**
  String get socialInvestmentSub;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @foodAgricultureStatus.
  ///
  /// In en, this message translates to:
  /// **'Food & Agriculture Status'**
  String get foodAgricultureStatus;

  /// No description provided for @foodSurplus.
  ///
  /// In en, this message translates to:
  /// **'Food Surplus'**
  String get foodSurplus;

  /// No description provided for @foodSecure.
  ///
  /// In en, this message translates to:
  /// **'Food Secure'**
  String get foodSecure;

  /// No description provided for @moderateRisk.
  ///
  /// In en, this message translates to:
  /// **'Moderate Risk'**
  String get moderateRisk;

  /// No description provided for @foodInsecure.
  ///
  /// In en, this message translates to:
  /// **'Food Insecure'**
  String get foodInsecure;

  /// No description provided for @famineCrisis.
  ///
  /// In en, this message translates to:
  /// **'Famine Crisis'**
  String get famineCrisis;

  /// No description provided for @populationOverview.
  ///
  /// In en, this message translates to:
  /// **'Population Overview'**
  String get populationOverview;

  /// No description provided for @totalPopulation.
  ///
  /// In en, this message translates to:
  /// **'Total Population'**
  String get totalPopulation;

  /// No description provided for @growthRate.
  ///
  /// In en, this message translates to:
  /// **'Growth Rate'**
  String get growthRate;

  /// No description provided for @capitalCity.
  ///
  /// In en, this message translates to:
  /// **'Capital City'**
  String get capitalCity;

  /// No description provided for @continent.
  ///
  /// In en, this message translates to:
  /// **'Continent'**
  String get continent;

  /// No description provided for @government.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get government;

  /// No description provided for @happinessScore.
  ///
  /// In en, this message translates to:
  /// **'Happiness Score'**
  String get happinessScore;

  /// No description provided for @chooseYourResponse.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Response:'**
  String get chooseYourResponse;

  /// No description provided for @confirmDecision.
  ///
  /// In en, this message translates to:
  /// **'Confirm Decision'**
  String get confirmDecision;

  /// No description provided for @selectOptionFirst.
  ///
  /// In en, this message translates to:
  /// **'Select an option first'**
  String get selectOptionFirst;

  /// No description provided for @continueGoverning.
  ///
  /// In en, this message translates to:
  /// **'Continue Governing'**
  String get continueGoverning;

  /// No description provided for @impeachedBadge.
  ///
  /// In en, this message translates to:
  /// **'IMPEACHED'**
  String get impeachedBadge;

  /// No description provided for @termEndedBadge.
  ///
  /// In en, this message translates to:
  /// **'TERM ENDED'**
  String get termEndedBadge;

  /// No description provided for @invadedBadge.
  ///
  /// In en, this message translates to:
  /// **'INVADED'**
  String get invadedBadge;

  /// No description provided for @countryFallen.
  ///
  /// In en, this message translates to:
  /// **'Country Has Fallen'**
  String get countryFallen;

  /// No description provided for @invadedVerdictText.
  ///
  /// In en, this message translates to:
  /// **'{country} has been conquered by a foreign power. Your failure to defend the nation will be remembered throughout history.'**
  String invadedVerdictText(String country);

  /// No description provided for @removedFromPower.
  ///
  /// In en, this message translates to:
  /// **'Removed from Power'**
  String get removedFromPower;

  /// No description provided for @finalReport.
  ///
  /// In en, this message translates to:
  /// **'Final Report'**
  String get finalReport;

  /// No description provided for @avgApproval.
  ///
  /// In en, this message translates to:
  /// **'Avg Approval'**
  String get avgApproval;

  /// No description provided for @avgApprovalStat.
  ///
  /// In en, this message translates to:
  /// **'Avg. approval: {pct}%'**
  String avgApprovalStat(String pct);

  /// No description provided for @finalGdp.
  ///
  /// In en, this message translates to:
  /// **'Final GDP'**
  String get finalGdp;

  /// No description provided for @militaryStat.
  ///
  /// In en, this message translates to:
  /// **'Military'**
  String get militaryStat;

  /// No description provided for @diplomacy.
  ///
  /// In en, this message translates to:
  /// **'Diplomacy'**
  String get diplomacy;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @policiesApplied.
  ///
  /// In en, this message translates to:
  /// **'Policies Applied'**
  String get policiesApplied;

  /// No description provided for @yearsInPower.
  ///
  /// In en, this message translates to:
  /// **'Years in Power'**
  String get yearsInPower;

  /// No description provided for @historicalVerdict.
  ///
  /// In en, this message translates to:
  /// **'Historical Verdict'**
  String get historicalVerdict;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get mainMenu;

  /// No description provided for @verdictGreat.
  ///
  /// In en, this message translates to:
  /// **'History will remember your leadership with great admiration. You transformed {country} into a beacon of prosperity and stability.'**
  String verdictGreat(String country);

  /// No description provided for @verdictGood.
  ///
  /// In en, this message translates to:
  /// **'You led {country} competently and are well-regarded by your citizens. Your tenure saw genuine progress in key areas.'**
  String verdictGood(String country);

  /// No description provided for @verdictAverage.
  ///
  /// In en, this message translates to:
  /// **'Your time as leader of {country} was mixed. While you maintained stability, many citizens felt more could have been accomplished.'**
  String verdictAverage(String country);

  /// No description provided for @verdictPoor.
  ///
  /// In en, this message translates to:
  /// **'Your leadership divided the nation. Significant opposition marked your term. {country} faced considerable challenges under your governance.'**
  String verdictPoor(String country);

  /// No description provided for @verdictBad.
  ///
  /// In en, this message translates to:
  /// **'Your term as leader of {country} will be remembered as a turbulent period. Institutions weakened and the country\'\'s reputation declined.'**
  String verdictBad(String country);

  /// No description provided for @impeachText1.
  ///
  /// In en, this message translates to:
  /// **'With approval at a catastrophic low, the people of {country} took to the streets. Parliament voted unanimously to remove you. You will be remembered as the worst leader in the nation\'\'s history.'**
  String impeachText1(String country);

  /// No description provided for @impeachText2.
  ///
  /// In en, this message translates to:
  /// **'Mass protests and a parliamentary vote forced you out of office. Your policies failed the people of {country} and history will not be kind to your legacy.'**
  String impeachText2(String country);

  /// No description provided for @impeachText3.
  ///
  /// In en, this message translates to:
  /// **'Public trust collapsed beyond recovery. Facing impeachment proceedings in parliament, you were removed from office. {country} moves forward without you.'**
  String impeachText3(String country);

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Your Country'**
  String get selectCountry;

  /// No description provided for @searchCountries.
  ///
  /// In en, this message translates to:
  /// **'Search countries...'**
  String get searchCountries;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterAfrica.
  ///
  /// In en, this message translates to:
  /// **'Africa'**
  String get filterAfrica;

  /// No description provided for @filterAsia.
  ///
  /// In en, this message translates to:
  /// **'Asia'**
  String get filterAsia;

  /// No description provided for @filterEurope.
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get filterEurope;

  /// No description provided for @filterAmericas.
  ///
  /// In en, this message translates to:
  /// **'Americas'**
  String get filterAmericas;

  /// No description provided for @filterOceania.
  ///
  /// In en, this message translates to:
  /// **'Oceania'**
  String get filterOceania;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @countryGdp.
  ///
  /// In en, this message translates to:
  /// **'GDP'**
  String get countryGdp;

  /// No description provided for @countryPopulation.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get countryPopulation;

  /// No description provided for @countryMilitary.
  ///
  /// In en, this message translates to:
  /// **'Military'**
  String get countryMilitary;

  /// No description provided for @countryHdi.
  ///
  /// In en, this message translates to:
  /// **'HDI'**
  String get countryHdi;

  /// No description provided for @countryContinent.
  ///
  /// In en, this message translates to:
  /// **'Continent'**
  String get countryContinent;

  /// No description provided for @countryCapital.
  ///
  /// In en, this message translates to:
  /// **'Capital'**
  String get countryCapital;

  /// No description provided for @countryGovernment.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get countryGovernment;

  /// No description provided for @policyScreen.
  ///
  /// In en, this message translates to:
  /// **'Policies'**
  String get policyScreen;

  /// No description provided for @applyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyPolicy;

  /// No description provided for @removePolicy.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removePolicy;

  /// No description provided for @policyActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get policyActive;

  /// No description provided for @policyCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get policyCost;

  /// No description provided for @policyEffect.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get policyEffect;

  /// No description provided for @buildingsScreen.
  ///
  /// In en, this message translates to:
  /// **'Infrastructure'**
  String get buildingsScreen;

  /// No description provided for @build.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get build;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// No description provided for @maxLevel.
  ///
  /// In en, this message translates to:
  /// **'Max Level'**
  String get maxLevel;

  /// No description provided for @natResources.
  ///
  /// In en, this message translates to:
  /// **'Nat. Resources'**
  String get natResources;

  /// No description provided for @oilReserves.
  ///
  /// In en, this message translates to:
  /// **'Oil Reserves'**
  String get oilReserves;

  /// No description provided for @diplomaticReputation.
  ///
  /// In en, this message translates to:
  /// **'Diplomatic Rep.'**
  String get diplomaticReputation;

  /// No description provided for @formAlliance.
  ///
  /// In en, this message translates to:
  /// **'Form Alliance'**
  String get formAlliance;

  /// No description provided for @breakAlliance.
  ///
  /// In en, this message translates to:
  /// **'Break Alliance'**
  String get breakAlliance;

  /// No description provided for @imposeSanction.
  ///
  /// In en, this message translates to:
  /// **'Impose Sanction'**
  String get imposeSanction;

  /// No description provided for @liftSanction.
  ///
  /// In en, this message translates to:
  /// **'Lift Sanction'**
  String get liftSanction;

  /// No description provided for @allyRelation.
  ///
  /// In en, this message translates to:
  /// **'Allied'**
  String get allyRelation;

  /// No description provided for @historicAlly.
  ///
  /// In en, this message translates to:
  /// **'Historic Ally'**
  String get historicAlly;

  /// No description provided for @neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get neutral;

  /// No description provided for @sanctioned.
  ///
  /// In en, this message translates to:
  /// **'Sanctioned'**
  String get sanctioned;

  /// No description provided for @historicRival.
  ///
  /// In en, this message translates to:
  /// **'Historic Rival'**
  String get historicRival;

  /// No description provided for @yearSummary.
  ///
  /// In en, this message translates to:
  /// **'Year in Review'**
  String get yearSummary;

  /// No description provided for @yearSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Year {year} Results'**
  String yearSummarySubtitle(int year);

  /// No description provided for @noChanges.
  ///
  /// In en, this message translates to:
  /// **'No significant changes this year.'**
  String get noChanges;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @politicalCapital.
  ///
  /// In en, this message translates to:
  /// **'Political Capital'**
  String get politicalCapital;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get langIndonesian;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found: {path}'**
  String pageNotFound(String path);

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @ultraLowTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Ultra Low — private sector surge'**
  String get ultraLowTaxRate;

  /// No description provided for @veryLowTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Very Low — minimal public services'**
  String get veryLowTaxRate;

  /// No description provided for @lowTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Low — lean government'**
  String get lowTaxRate;

  /// No description provided for @moderateTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Moderate — balanced budget'**
  String get moderateTaxRate;

  /// No description provided for @highTaxRate.
  ///
  /// In en, this message translates to:
  /// **'High — strong public investment'**
  String get highTaxRate;

  /// No description provided for @veryHighTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Very High — risk of capital flight'**
  String get veryHighTaxRate;

  /// No description provided for @extremeTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Extreme — capital flight + protest risk'**
  String get extremeTaxRate;

  /// No description provided for @protestConditionsActive.
  ///
  /// In en, this message translates to:
  /// **'PROTEST CONDITIONS ACTIVE — Mass protests will erupt next year. Lower tax below 45% or raise happiness above 40 to prevent them.'**
  String get protestConditionsActive;

  /// No description provided for @capitalFlightActive.
  ///
  /// In en, this message translates to:
  /// **'Capital flight active — investors are leaving. If happiness falls below 40, mass protests will erupt.'**
  String get capitalFlightActive;

  /// No description provided for @newRateTakesEffect.
  ///
  /// In en, this message translates to:
  /// **'New rate {taxRate}% takes full effect next year.'**
  String newRateTakesEffect(String taxRate);

  /// No description provided for @taxZoneSafeLabel.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get taxZoneSafeLabel;

  /// No description provided for @taxZoneWarningLabel.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get taxZoneWarningLabel;

  /// No description provided for @taxZoneCrisisLabel.
  ///
  /// In en, this message translates to:
  /// **'Crisis'**
  String get taxZoneCrisisLabel;

  /// No description provided for @healthyDebt.
  ///
  /// In en, this message translates to:
  /// **'Healthy debt level — economy is sustainable.'**
  String get healthyDebt;

  /// No description provided for @moderateDebt.
  ///
  /// In en, this message translates to:
  /// **'Moderate debt — monitor carefully.'**
  String get moderateDebt;

  /// No description provided for @dangerousDebt.
  ///
  /// In en, this message translates to:
  /// **'Dangerous debt level — risk of default!'**
  String get dangerousDebt;

  /// No description provided for @declareWarTitle.
  ///
  /// In en, this message translates to:
  /// **'Declare War?'**
  String get declareWarTitle;

  /// No description provided for @declareWarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This will put your country on a war footing.'**
  String get declareWarSubtitle;

  /// No description provided for @ongoingWarPenalties.
  ///
  /// In en, this message translates to:
  /// **'Ongoing war penalties (per year):'**
  String get ongoingWarPenalties;

  /// No description provided for @militaryWeakWarning.
  ///
  /// In en, this message translates to:
  /// **'Military critically weak — peace negotiations will be forced at end of year.'**
  String get militaryWeakWarning;

  /// No description provided for @countryAtPeace.
  ///
  /// In en, this message translates to:
  /// **'Your country is currently at peace.'**
  String get countryAtPeace;

  /// No description provided for @declareWarWarning.
  ///
  /// In en, this message translates to:
  /// **'Declaring war will impose severe annual penalties on happiness, stability, and GDP growth until peace is negotiated.'**
  String get declareWarWarning;

  /// No description provided for @sueForPeaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Sue for Peace?'**
  String get sueForPeaceTitle;

  /// No description provided for @sueForPeaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'End the conflict and return to peacetime.'**
  String get sueForPeaceSubtitle;

  /// No description provided for @activeConflict.
  ///
  /// In en, this message translates to:
  /// **'Active Conflict'**
  String get activeConflict;

  /// No description provided for @percentOfGdp.
  ///
  /// In en, this message translates to:
  /// **'% of GDP'**
  String get percentOfGdp;

  /// No description provided for @minimalMilBudget.
  ///
  /// In en, this message translates to:
  /// **'Minimal — defense capability degrading'**
  String get minimalMilBudget;

  /// No description provided for @lowMilBudget.
  ///
  /// In en, this message translates to:
  /// **'Low — basic deterrence only'**
  String get lowMilBudget;

  /// No description provided for @moderateMilBudget.
  ///
  /// In en, this message translates to:
  /// **'Moderate — balanced defense'**
  String get moderateMilBudget;

  /// No description provided for @highMilBudget.
  ///
  /// In en, this message translates to:
  /// **'High — strong regional power'**
  String get highMilBudget;

  /// No description provided for @veryHighMilBudget.
  ///
  /// In en, this message translates to:
  /// **'Very High — major military investment'**
  String get veryHighMilBudget;

  /// No description provided for @maxMilBudget.
  ///
  /// In en, this message translates to:
  /// **'Maximum — full military-industrial complex'**
  String get maxMilBudget;

  /// No description provided for @newBudgetTakesEffect.
  ///
  /// In en, this message translates to:
  /// **'New budget {percent}% GDP ({budget}) takes effect next year.'**
  String newBudgetTakesEffect(String percent, String budget);

  /// No description provided for @globalSuperpower.
  ///
  /// In en, this message translates to:
  /// **'Global Superpower'**
  String get globalSuperpower;

  /// No description provided for @majorMilitaryPower.
  ///
  /// In en, this message translates to:
  /// **'Major Military Power'**
  String get majorMilitaryPower;

  /// No description provided for @regionalPower.
  ///
  /// In en, this message translates to:
  /// **'Regional Power'**
  String get regionalPower;

  /// No description provided for @moderateForce.
  ///
  /// In en, this message translates to:
  /// **'Moderate Force'**
  String get moderateForce;

  /// No description provided for @limitedCapability.
  ///
  /// In en, this message translates to:
  /// **'Limited Capability'**
  String get limitedCapability;

  /// No description provided for @minimalDefense.
  ///
  /// In en, this message translates to:
  /// **'Minimal Defense'**
  String get minimalDefense;

  /// No description provided for @noCountriesMatch.
  ///
  /// In en, this message translates to:
  /// **'No countries match your search.'**
  String get noCountriesMatch;

  /// No description provided for @repLocked.
  ///
  /// In en, this message translates to:
  /// **'Rep < 30 — alliances locked.\nImprove reputation to unlock.'**
  String get repLocked;

  /// No description provided for @yourAlliances.
  ///
  /// In en, this message translates to:
  /// **'Your Alliances'**
  String get yourAlliances;

  /// No description provided for @yourSanctions.
  ///
  /// In en, this message translates to:
  /// **'Your Sanctions'**
  String get yourSanctions;

  /// No description provided for @historicAllies.
  ///
  /// In en, this message translates to:
  /// **'Historic Allies'**
  String get historicAllies;

  /// No description provided for @historicRivals.
  ///
  /// In en, this message translates to:
  /// **'Historic Rivals'**
  String get historicRivals;

  /// No description provided for @noActiveRelations.
  ///
  /// In en, this message translates to:
  /// **'No active relations.\nUse the browser →\nto form alliances.'**
  String get noActiveRelations;

  /// No description provided for @preExisting.
  ///
  /// In en, this message translates to:
  /// **'Pre-existing'**
  String get preExisting;

  /// No description provided for @alliancesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Allies'**
  String alliancesCount(int count);

  /// No description provided for @rivalsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Rivals'**
  String rivalsCount(int count);

  /// No description provided for @allianceGdpBonus.
  ///
  /// In en, this message translates to:
  /// **'+{bonus}% GDP/yr from alliances'**
  String allianceGdpBonus(String bonus);

  /// No description provided for @confirmFormAlliance.
  ///
  /// In en, this message translates to:
  /// **'Form Alliance with {country}?'**
  String confirmFormAlliance(String country);

  /// No description provided for @confirmBreakAlliance.
  ///
  /// In en, this message translates to:
  /// **'Break Alliance with {country}?'**
  String confirmBreakAlliance(String country);

  /// No description provided for @confirmSanction.
  ///
  /// In en, this message translates to:
  /// **'Impose Sanctions on {country}?'**
  String confirmSanction(String country);

  /// No description provided for @confirmLiftSanction.
  ///
  /// In en, this message translates to:
  /// **'Lift Sanctions on {country}?'**
  String confirmLiftSanction(String country);

  /// No description provided for @economicTab.
  ///
  /// In en, this message translates to:
  /// **'Economic'**
  String get economicTab;

  /// No description provided for @diplomaticTab.
  ///
  /// In en, this message translates to:
  /// **'Diplomatic'**
  String get diplomaticTab;

  /// No description provided for @policyNotEnoughCapital.
  ///
  /// In en, this message translates to:
  /// **'Not enough Political Capital (need {needed}, have {have}).'**
  String policyNotEnoughCapital(int needed, int have);

  /// No description provided for @notEnoughApproval.
  ///
  /// In en, this message translates to:
  /// **'You need at least {minApproval}% approval to apply this policy.'**
  String notEnoughApproval(int minApproval);

  /// No description provided for @policyAlreadyActive.
  ///
  /// In en, this message translates to:
  /// **'{policy} is already active.'**
  String policyAlreadyActive(String policy);

  /// No description provided for @policyApplied.
  ///
  /// In en, this message translates to:
  /// **'{policy} has been applied!'**
  String policyApplied(String policy);

  /// No description provided for @revokePolicy.
  ///
  /// In en, this message translates to:
  /// **'Revoke \"{policy}\"?'**
  String revokePolicy(String policy);

  /// No description provided for @revokeDescription.
  ///
  /// In en, this message translates to:
  /// **'Revoking this policy will:'**
  String get revokeDescription;

  /// No description provided for @revokeCostDrain.
  ///
  /// In en, this message translates to:
  /// **'Stop the annual cost drain'**
  String get revokeCostDrain;

  /// No description provided for @revokeEffectsReversal.
  ///
  /// In en, this message translates to:
  /// **'Partially reverse effects (40%)'**
  String get revokeEffectsReversal;

  /// No description provided for @revokeRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund {refund} Political Capital'**
  String revokeRefund(int refund);

  /// No description provided for @revokePolicyButton.
  ///
  /// In en, this message translates to:
  /// **'Revoke Policy'**
  String get revokePolicyButton;

  /// No description provided for @revokeSuccess.
  ///
  /// In en, this message translates to:
  /// **'{policy} revoked. +{refund} refunded.'**
  String revokeSuccess(String policy, int refund);

  /// No description provided for @bonusPerLevel.
  ///
  /// In en, this message translates to:
  /// **'Bonus per level / year:'**
  String get bonusPerLevel;

  /// No description provided for @infrastructureTitle.
  ///
  /// In en, this message translates to:
  /// **'Infrastructure'**
  String get infrastructureTitle;

  /// No description provided for @energyTab.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energyTab;

  /// No description provided for @foodTab.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get foodTab;

  /// No description provided for @resourcesTab.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resourcesTab;

  /// No description provided for @powerGrid.
  ///
  /// In en, this message translates to:
  /// **'Power Grid'**
  String get powerGrid;

  /// No description provided for @noPowerCapacity.
  ///
  /// In en, this message translates to:
  /// **'No power capacity! Go to the Energy tab and build a power plant first — all other buildings require electricity.'**
  String get noPowerCapacity;

  /// No description provided for @noEnergyWarning.
  ///
  /// In en, this message translates to:
  /// **'Not enough energy (need {needed} MW, only {available} MW free). Build more power plants!'**
  String noEnergyWarning(int needed, int available);

  /// No description provided for @buildingNotEnoughCapital.
  ///
  /// In en, this message translates to:
  /// **'Not enough Political Capital (need {need}, have {have}).'**
  String buildingNotEnoughCapital(int need, int have);

  /// No description provided for @notEnoughTreasury.
  ///
  /// In en, this message translates to:
  /// **'Not enough Treasury (need \${needed}B, have \${have}B). Wait for annual income!'**
  String notEnoughTreasury(String needed, String have);

  /// No description provided for @buildingBuilt.
  ///
  /// In en, this message translates to:
  /// **'{building} built!'**
  String buildingBuilt(String building);

  /// No description provided for @buildingUpgraded.
  ///
  /// In en, this message translates to:
  /// **'{building} upgraded to Level {level}!'**
  String buildingUpgraded(String building, int level);

  /// No description provided for @countriesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} countries found'**
  String countriesFound(int count);

  /// No description provided for @hdi.
  ///
  /// In en, this message translates to:
  /// **'HDI'**
  String get hdi;

  /// No description provided for @corruptionIndex.
  ///
  /// In en, this message translates to:
  /// **'Corruption Index'**
  String get corruptionIndex;

  /// No description provided for @taxPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax Policy'**
  String get taxPolicyTitle;

  /// No description provided for @baseGovSpending.
  ///
  /// In en, this message translates to:
  /// **'Base Gov. Spending'**
  String get baseGovSpending;

  /// No description provided for @revenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenueLabel;

  /// No description provided for @capitalFlightLabel.
  ///
  /// In en, this message translates to:
  /// **'Capital Flight'**
  String get capitalFlightLabel;

  /// No description provided for @needsCapitalToWar.
  ///
  /// In en, this message translates to:
  /// **'Need 💎{cost} political capital to declare war.'**
  String needsCapitalToWar(int cost);

  /// No description provided for @warConflict.
  ///
  /// In en, this message translates to:
  /// **'War & Conflict'**
  String get warConflict;

  /// No description provided for @atWarStatus.
  ///
  /// In en, this message translates to:
  /// **'AT WAR'**
  String get atWarStatus;

  /// No description provided for @atPeaceStatus.
  ///
  /// In en, this message translates to:
  /// **'AT PEACE'**
  String get atPeaceStatus;

  /// No description provided for @currentlyAtPeace.
  ///
  /// In en, this message translates to:
  /// **'Your country is currently at peace.'**
  String get currentlyAtPeace;

  /// No description provided for @declaringWarWarning.
  ///
  /// In en, this message translates to:
  /// **'Declaring war will impose severe annual penalties on happiness, stability, and GDP growth until peace is negotiated.'**
  String get declaringWarWarning;

  /// No description provided for @militaryCriticallyWeak.
  ///
  /// In en, this message translates to:
  /// **'Military critically weak — peace negotiations will be forced at end of year.'**
  String get militaryCriticallyWeak;

  /// No description provided for @militaryClassification.
  ///
  /// In en, this message translates to:
  /// **'Military Classification'**
  String get militaryClassification;

  /// No description provided for @naturalResources.
  ///
  /// In en, this message translates to:
  /// **'Natural Resources'**
  String get naturalResources;

  /// No description provided for @oilEnergyReserves.
  ///
  /// In en, this message translates to:
  /// **'Oil & Energy Reserves'**
  String get oilEnergyReserves;

  /// No description provided for @milBudgetMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal — defense capability degrading'**
  String get milBudgetMinimal;

  /// No description provided for @milBudgetLow.
  ///
  /// In en, this message translates to:
  /// **'Low — basic deterrence only'**
  String get milBudgetLow;

  /// No description provided for @milBudgetModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate — balanced defense'**
  String get milBudgetModerate;

  /// No description provided for @milBudgetHigh.
  ///
  /// In en, this message translates to:
  /// **'High — strong regional power'**
  String get milBudgetHigh;

  /// No description provided for @milBudgetVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High — major military investment'**
  String get milBudgetVeryHigh;

  /// No description provided for @milBudgetMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum — full military-industrial complex'**
  String get milBudgetMaximum;

  /// No description provided for @strengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strengthLabel;

  /// No description provided for @troopsLabel.
  ///
  /// In en, this message translates to:
  /// **'Troops'**
  String get troopsLabel;

  /// No description provided for @diploRepLabel.
  ///
  /// In en, this message translates to:
  /// **'Diplo Rep'**
  String get diploRepLabel;

  /// No description provided for @nationalDebtPct.
  ///
  /// In en, this message translates to:
  /// **'{debt}% of GDP'**
  String nationalDebtPct(String debt);

  /// No description provided for @alliedRelLabel.
  ///
  /// In en, this message translates to:
  /// **'Allied'**
  String get alliedRelLabel;

  /// No description provided for @diplomaticReputationTitle.
  ///
  /// In en, this message translates to:
  /// **'Diplomatic Reputation'**
  String get diplomaticReputationTitle;

  /// No description provided for @highlyRespected.
  ///
  /// In en, this message translates to:
  /// **'Highly Respected'**
  String get highlyRespected;

  /// No description provided for @wellRegarded.
  ///
  /// In en, this message translates to:
  /// **'Well-regarded'**
  String get wellRegarded;

  /// No description provided for @neutralStanding.
  ///
  /// In en, this message translates to:
  /// **'Neutral Standing'**
  String get neutralStanding;

  /// No description provided for @controversial.
  ///
  /// In en, this message translates to:
  /// **'Controversial'**
  String get controversial;

  /// No description provided for @pariahState.
  ///
  /// In en, this message translates to:
  /// **'Pariah State'**
  String get pariahState;

  /// No description provided for @searchNCountries.
  ///
  /// In en, this message translates to:
  /// **'Search {n} countries…'**
  String searchNCountries(int n);

  /// No description provided for @breakActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get breakActionLabel;

  /// No description provided for @liftActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Lift'**
  String get liftActionLabel;

  /// No description provided for @allyActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Ally'**
  String get allyActionLabel;

  /// No description provided for @sanctionActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Sanction'**
  String get sanctionActionLabel;

  /// No description provided for @historicLabel.
  ///
  /// In en, this message translates to:
  /// **'Historic'**
  String get historicLabel;

  /// No description provided for @rivalLabel.
  ///
  /// In en, this message translates to:
  /// **'Rival'**
  String get rivalLabel;

  /// No description provided for @oneTimeCost.
  ///
  /// In en, this message translates to:
  /// **'ONE-TIME COST'**
  String get oneTimeCost;

  /// No description provided for @annualBenefits.
  ///
  /// In en, this message translates to:
  /// **'ANNUAL BENEFITS'**
  String get annualBenefits;

  /// No description provided for @effectsLabel.
  ///
  /// In en, this message translates to:
  /// **'EFFECTS'**
  String get effectsLabel;

  /// No description provided for @repTooLow.
  ///
  /// In en, this message translates to:
  /// **'Diplomatic reputation too low (need ≥30 to form alliances).'**
  String get repTooLow;

  /// No description provided for @notEnoughCapitalDiplo.
  ///
  /// In en, this message translates to:
  /// **'💎 Not enough Political Capital (need {cost}).'**
  String notEnoughCapitalDiplo(int cost);

  /// No description provided for @allianceFormedMsg.
  ///
  /// In en, this message translates to:
  /// **'🤝 Alliance formed with {country}!'**
  String allianceFormedMsg(String country);

  /// No description provided for @allianceEndedMsg.
  ///
  /// In en, this message translates to:
  /// **'✂️ Alliance with {country} ended.'**
  String allianceEndedMsg(String country);

  /// No description provided for @sanctionsImposedMsg.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Sanctions imposed on {country}.'**
  String sanctionsImposedMsg(String country);

  /// No description provided for @sanctionsLiftedMsg.
  ///
  /// In en, this message translates to:
  /// **'✅ Sanctions on {country} lifted.'**
  String sanctionsLiftedMsg(String country);

  /// No description provided for @allianceRepEffect.
  ///
  /// In en, this message translates to:
  /// **'+6 Diplomatic Reputation'**
  String get allianceRepEffect;

  /// No description provided for @allianceGdpYearEffect.
  ///
  /// In en, this message translates to:
  /// **'+0.4% GDP Growth per year'**
  String get allianceGdpYearEffect;

  /// No description provided for @allianceHappinessEffect.
  ///
  /// In en, this message translates to:
  /// **'+2 Happiness'**
  String get allianceHappinessEffect;

  /// No description provided for @allianceStabilityEffect.
  ///
  /// In en, this message translates to:
  /// **'+1.5 Stability per year'**
  String get allianceStabilityEffect;

  /// No description provided for @alliancePerAllyBonus.
  ///
  /// In en, this message translates to:
  /// **'+0.1% GDP/yr bonus per total ally'**
  String get alliancePerAllyBonus;

  /// No description provided for @breakRepEffect.
  ///
  /// In en, this message translates to:
  /// **'-8 Diplomatic Reputation'**
  String get breakRepEffect;

  /// No description provided for @breakGdpEffect.
  ///
  /// In en, this message translates to:
  /// **'-0.3% GDP Growth'**
  String get breakGdpEffect;

  /// No description provided for @breakGdpBonusEffect.
  ///
  /// In en, this message translates to:
  /// **'Lose ongoing alliance GDP bonus'**
  String get breakGdpBonusEffect;

  /// No description provided for @sanctionRepEffect.
  ///
  /// In en, this message translates to:
  /// **'-4 Diplomatic Reputation'**
  String get sanctionRepEffect;

  /// No description provided for @sanctionGdpEffect.
  ///
  /// In en, this message translates to:
  /// **'-0.05% GDP Growth per sanctioned country/yr'**
  String get sanctionGdpEffect;

  /// No description provided for @sanctionTradeEffect.
  ///
  /// In en, this message translates to:
  /// **'Stops ongoing trade benefits'**
  String get sanctionTradeEffect;

  /// No description provided for @liftRepEffect.
  ///
  /// In en, this message translates to:
  /// **'+3 Diplomatic Reputation'**
  String get liftRepEffect;

  /// No description provided for @liftGdpEffect.
  ///
  /// In en, this message translates to:
  /// **'Removes -0.05% GDP drag/yr'**
  String get liftGdpEffect;

  /// No description provided for @liftPathEffect.
  ///
  /// In en, this message translates to:
  /// **'Opens path to future alliance'**
  String get liftPathEffect;

  /// No description provided for @costLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get costLabel;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'WORLD PRESIDENT'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SIMULATOR'**
  String get splashSubtitle;

  /// No description provided for @applyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyButton;

  /// No description provided for @revokeButton.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revokeButton;

  /// No description provided for @needCapitalButton.
  ///
  /// In en, this message translates to:
  /// **'Need 💎{cost}'**
  String needCapitalButton(int cost);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @continentLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTINENT'**
  String get continentLabel;

  /// No description provided for @allRegions.
  ///
  /// In en, this message translates to:
  /// **'All Regions'**
  String get allRegions;

  /// No description provided for @leadNation.
  ///
  /// In en, this message translates to:
  /// **'Lead Nation'**
  String get leadNation;

  /// No description provided for @countryProfile.
  ///
  /// In en, this message translates to:
  /// **'Country Profile'**
  String get countryProfile;

  /// No description provided for @naturalAllies.
  ///
  /// In en, this message translates to:
  /// **'Natural Allies'**
  String get naturalAllies;

  /// No description provided for @noActiveGame.
  ///
  /// In en, this message translates to:
  /// **'No active game'**
  String get noActiveGame;

  /// No description provided for @noPower.
  ///
  /// In en, this message translates to:
  /// **'No Power'**
  String get noPower;

  /// No description provided for @mwUsed.
  ///
  /// In en, this message translates to:
  /// **'{consumption}/{capacity} MW used'**
  String mwUsed(String consumption, String capacity);

  /// No description provided for @mwFree.
  ///
  /// In en, this message translates to:
  /// **'({available} MW free)'**
  String mwFree(String available);

  /// No description provided for @generatesEnergyPerLevel.
  ///
  /// In en, this message translates to:
  /// **'Generates +{mw} MW per level  •  Max {max} levels'**
  String generatesEnergyPerLevel(String mw, String max);

  /// No description provided for @requiresEnergyActive.
  ///
  /// In en, this message translates to:
  /// **'Requires {mw} MW to operate'**
  String requiresEnergyActive(String mw);

  /// No description provided for @requiresEnergyInactive.
  ///
  /// In en, this message translates to:
  /// **'Requires {mw} MW to operate  •  not yet built'**
  String requiresEnergyInactive(String mw);

  /// No description provided for @notBuiltLabel.
  ///
  /// In en, this message translates to:
  /// **'Not Built'**
  String get notBuiltLabel;

  /// No description provided for @levelProgress.
  ///
  /// In en, this message translates to:
  /// **'Lv {level} / {maxLevel}'**
  String levelProgress(int level, int maxLevel);

  /// No description provided for @upgradeToLevel.
  ///
  /// In en, this message translates to:
  /// **'Upgrade → Lv {level}'**
  String upgradeToLevel(int level);

  /// No description provided for @needCapitalForBuilding.
  ///
  /// In en, this message translates to:
  /// **'💎 Need {cost}'**
  String needCapitalForBuilding(int cost);

  /// No description provided for @needMoneyForBuilding.
  ///
  /// In en, this message translates to:
  /// **'🪙 Need \${cost}B'**
  String needMoneyForBuilding(String cost);

  /// No description provided for @needEnergyForBuilding.
  ///
  /// In en, this message translates to:
  /// **'⚡ Need {mw} MW'**
  String needEnergyForBuilding(String mw);

  /// No description provided for @impeachRisk.
  ///
  /// In en, this message translates to:
  /// **'IMPEACH RISK'**
  String get impeachRisk;

  /// No description provided for @lowApproval.
  ///
  /// In en, this message translates to:
  /// **'Low Approval'**
  String get lowApproval;

  /// No description provided for @happyLabel.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get happyLabel;

  /// No description provided for @stableLabel.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stableLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @approvalCritical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL — Advance year to trigger impeachment!'**
  String get approvalCritical;

  /// No description provided for @approvalDangerouslyLow.
  ///
  /// In en, this message translates to:
  /// **'Approval dangerously low — impeached at 15%'**
  String get approvalDangerouslyLow;

  /// No description provided for @capitalLabel.
  ///
  /// In en, this message translates to:
  /// **'Capital'**
  String get capitalLabel;

  /// No description provided for @yourNation.
  ///
  /// In en, this message translates to:
  /// **'Your Nation'**
  String get yourNation;

  /// No description provided for @cannotBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Cannot break'**
  String get cannotBreakLabel;

  /// No description provided for @needRepLabel.
  ///
  /// In en, this message translates to:
  /// **'Need rep ≥30'**
  String get needRepLabel;

  /// No description provided for @fixedRelLabel.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixedRelLabel;

  /// No description provided for @diplomacyHeader.
  ///
  /// In en, this message translates to:
  /// **'DIPLOMACY'**
  String get diplomacyHeader;

  /// No description provided for @dashboardLabel.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardLabel;

  /// No description provided for @economySection.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get economySection;

  /// No description provided for @societySection.
  ///
  /// In en, this message translates to:
  /// **'Society'**
  String get societySection;

  /// No description provided for @militaryDiplomacy.
  ///
  /// In en, this message translates to:
  /// **'Military & Diplomacy'**
  String get militaryDiplomacy;

  /// No description provided for @resourcesSection.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resourcesSection;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @growthLabel.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growthLabel;

  /// No description provided for @militaryStrLabel.
  ///
  /// In en, this message translates to:
  /// **'Military Str.'**
  String get militaryStrLabel;

  /// No description provided for @reputationLabel.
  ///
  /// In en, this message translates to:
  /// **'Reputation'**
  String get reputationLabel;

  /// No description provided for @treasuryBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Treasury & Budget'**
  String get treasuryBudgetTitle;

  /// No description provided for @netPerYearBadge.
  ///
  /// In en, this message translates to:
  /// **'Net / year'**
  String get netPerYearBadge;

  /// No description provided for @govSpendingShort.
  ///
  /// In en, this message translates to:
  /// **'Gov. Spending'**
  String get govSpendingShort;

  /// No description provided for @maintenanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenanceLabel;

  /// No description provided for @netThisYear.
  ///
  /// In en, this message translates to:
  /// **'Net this year'**
  String get netThisYear;

  /// No description provided for @currentApprovalPct.
  ///
  /// In en, this message translates to:
  /// **'Current approval: {approval}%'**
  String currentApprovalPct(String approval);

  /// No description provided for @approvalCriticalNote.
  ///
  /// In en, this message translates to:
  /// **'Approval critical — impeached if it drops below 15%'**
  String get approvalCriticalNote;

  /// No description provided for @advanceToYearTitle.
  ///
  /// In en, this message translates to:
  /// **'Advance to Year {year}'**
  String advanceToYearTitle(int year);

  /// No description provided for @yearsInOfficeLabel.
  ///
  /// In en, this message translates to:
  /// **'Year {year} in office'**
  String yearsInOfficeLabel(int year);

  /// No description provided for @budgetProjection.
  ///
  /// In en, this message translates to:
  /// **'BUDGET PROJECTION'**
  String get budgetProjection;

  /// No description provided for @yearXSummary.
  ///
  /// In en, this message translates to:
  /// **'Year {year} Summary'**
  String yearXSummary(int year);

  /// No description provided for @capitalEarned.
  ///
  /// In en, this message translates to:
  /// **'Political Capital earned: +{amount} 💎'**
  String capitalEarned(int amount);

  /// No description provided for @statChanges.
  ///
  /// In en, this message translates to:
  /// **'STAT CHANGES'**
  String get statChanges;

  /// No description provided for @criticalImpeachImminent.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL: Impeachment imminent if approval drops below 15%!'**
  String get criticalImpeachImminent;

  /// No description provided for @warningApprovalAction.
  ///
  /// In en, this message translates to:
  /// **'Warning: Approval at {approval}% — take action before next year.'**
  String warningApprovalAction(String approval);

  /// No description provided for @literacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Literacy'**
  String get literacyLabel;

  /// No description provided for @milReadinessLabel.
  ///
  /// In en, this message translates to:
  /// **'Mil. Readiness'**
  String get milReadinessLabel;

  /// No description provided for @govDemocracy.
  ///
  /// In en, this message translates to:
  /// **'Democracy'**
  String get govDemocracy;

  /// No description provided for @govRepublic.
  ///
  /// In en, this message translates to:
  /// **'Republic'**
  String get govRepublic;

  /// No description provided for @govConstMonarchy.
  ///
  /// In en, this message translates to:
  /// **'Const. Monarchy'**
  String get govConstMonarchy;

  /// No description provided for @govMonarchy.
  ///
  /// In en, this message translates to:
  /// **'Monarchy'**
  String get govMonarchy;

  /// No description provided for @govCommunist.
  ///
  /// In en, this message translates to:
  /// **'Communist'**
  String get govCommunist;

  /// No description provided for @govTheocracy.
  ///
  /// In en, this message translates to:
  /// **'Theocracy'**
  String get govTheocracy;

  /// No description provided for @govAuthoritarian.
  ///
  /// In en, this message translates to:
  /// **'Authoritarian'**
  String get govAuthoritarian;

  /// No description provided for @govFederalRepublic.
  ///
  /// In en, this message translates to:
  /// **'Federal Republic'**
  String get govFederalRepublic;

  /// No description provided for @govParliamentary.
  ///
  /// In en, this message translates to:
  /// **'Parliamentary'**
  String get govParliamentary;

  /// No description provided for @govMilitaryJunta.
  ///
  /// In en, this message translates to:
  /// **'Military Junta'**
  String get govMilitaryJunta;

  /// No description provided for @taxRevenueSub.
  ///
  /// In en, this message translates to:
  /// **'GDP \${gdp} × {rate}%'**
  String taxRevenueSub(String gdp, String rate);

  /// No description provided for @pctOfGdpSub.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of GDP'**
  String pctOfGdpSub(String pct);

  /// No description provided for @tutStep1Title.
  ///
  /// In en, this message translates to:
  /// **'🌍 Welcome, World Leader!'**
  String get tutStep1Title;

  /// No description provided for @tutStep1Body.
  ///
  /// In en, this message translates to:
  /// **'You are now in charge of a nation. The world map shows all countries — tap any to view details or manage diplomatic relations.'**
  String get tutStep1Body;

  /// No description provided for @tutStep2Title.
  ///
  /// In en, this message translates to:
  /// **'⏭️ Advance the Year'**
  String get tutStep2Title;

  /// No description provided for @tutStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"Year XXXX\" button to move time forward. Each year your economy, happiness, and approval update based on your choices.'**
  String get tutStep2Body;

  /// No description provided for @tutStep3Title.
  ///
  /// In en, this message translates to:
  /// **'👑 Approval Rating'**
  String get tutStep3Title;

  /// No description provided for @tutStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Keep your approval above 15% or you\'\'ll be impeached! Balance tax rates, policies, and happiness to stay in power.'**
  String get tutStep3Body;

  /// No description provided for @tutStep4Title.
  ///
  /// In en, this message translates to:
  /// **'📋 Policies & Buildings'**
  String get tutStep4Title;

  /// No description provided for @tutStep4Body.
  ///
  /// In en, this message translates to:
  /// **'Spend 💎 Political Capital on policies, and 🪙 Treasury on buildings. Always build a Power Plant first — other buildings need electricity!'**
  String get tutStep4Body;

  /// No description provided for @tutStep5Title.
  ///
  /// In en, this message translates to:
  /// **'🪙 Treasury & Diplomacy'**
  String get tutStep5Title;

  /// No description provided for @tutStep5Body.
  ///
  /// In en, this message translates to:
  /// **'Your treasury funds the nation. Tap the 🪙 badge to see the full budget. Tap any country to form alliances or impose sanctions.'**
  String get tutStep5Body;

  /// No description provided for @tipCounter.
  ///
  /// In en, this message translates to:
  /// **'TIP {step}/{total}'**
  String tipCounter(int step, int total);

  /// No description provided for @skipLabel.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipLabel;

  /// No description provided for @gotItLabel.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotItLabel;

  /// No description provided for @nextArrow.
  ///
  /// In en, this message translates to:
  /// **'Next →'**
  String get nextArrow;
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
      'that was used.');
}
