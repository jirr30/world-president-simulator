import '../models/policy_model.dart';

class PoliciesData {
  PoliciesData._();

  static const List<PolicyModel> all = [
    // ═══════════════════ ECONOMIC ═══════════════════
    PolicyModel(
      id: 'tax_cut', name: 'Tax Reduction', cost: 5,
      description: 'Lower income tax rates to stimulate economic activity and consumer spending.',
      category: PolicyCategory.economic,
      effects: [
        StatEffect('GDP Growth', 2.0),
        StatEffect('Happiness', 5.0),
        StatEffect('National Debt', -3.0),
        StatEffect('Approval', 4.0),
      ],
    ),
    PolicyModel(
      id: 'tax_hike', name: 'Tax Increase', cost: 0,
      description: 'Raise taxes to reduce national debt and fund public services.',
      category: PolicyCategory.economic,
      effects: [
        StatEffect('GDP Growth', -1.5),
        StatEffect('Happiness', -6.0),
        StatEffect('National Debt', 8.0),
        StatEffect('Approval', -5.0),
      ],
    ),
    PolicyModel(
      id: 'infrastructure', name: 'Infrastructure Investment', cost: 15,
      description: 'Massive investment in roads, bridges, ports, and public transport.',
      category: PolicyCategory.economic,
      effects: [
        StatEffect('GDP Growth', 3.0),
        StatEffect('Employment', 4.0),
        StatEffect('Happiness', 6.0),
        StatEffect('Approval', 5.0),
      ],
    ),
    PolicyModel(
      id: 'privatization', name: 'Privatization Program', cost: 0,
      description: 'Sell state-owned enterprises to private investors to raise funds.',
      category: PolicyCategory.economic,
      effects: [
        StatEffect('GDP Growth', 1.5),
        StatEffect('Happiness', -4.0),
        StatEffect('National Debt', 5.0),
        StatEffect('Approval', -3.0),
      ],
    ),
    PolicyModel(
      id: 'free_trade', name: 'Free Trade Agreement', cost: 2,
      description: 'Open markets by reducing tariffs and trade barriers with partner nations.',
      category: PolicyCategory.economic,
      effects: [
        StatEffect('GDP Growth', 2.5),
        StatEffect('Diplomatic Rep', 5.0),
        StatEffect('Employment', -1.0),
        StatEffect('Approval', 2.0),
      ],
    ),
    PolicyModel(
      id: 'protectionism', name: 'Trade Protectionism', cost: 3,
      description: 'Impose tariffs and trade barriers to protect domestic industries.',
      category: PolicyCategory.economic,
      effects: [
        StatEffect('GDP Growth', -1.0),
        StatEffect('Diplomatic Rep', -4.0),
        StatEffect('Employment', 2.0),
        StatEffect('Approval', 1.0),
      ],
    ),
    PolicyModel(
      id: 'austerity', name: 'Austerity Measures', cost: 0,
      description: 'Cut government spending to reduce the national deficit.',
      category: PolicyCategory.economic,
      effects: [
        StatEffect('National Debt', 10.0),
        StatEffect('Happiness', -8.0),
        StatEffect('GDP Growth', -2.0),
        StatEffect('Approval', -7.0),
      ],
    ),
    PolicyModel(
      id: 'stimulus', name: 'Economic Stimulus', cost: 20,
      description: 'Government spending package to boost the economy during downturns.',
      category: PolicyCategory.economic,
      effects: [
        StatEffect('GDP Growth', 4.0),
        StatEffect('Employment', 3.0),
        StatEffect('National Debt', -5.0),
        StatEffect('Approval', 6.0),
      ],
    ),
    PolicyModel(
      id: 'tech_investment', name: 'Tech & Innovation Fund', cost: 10,
      description: 'Invest in research, development, and emerging technology sectors.',
      category: PolicyCategory.economic,
      effects: [
        StatEffect('GDP Growth', 2.0),
        StatEffect('Education', 4.0),
        StatEffect('Happiness', 3.0),
        StatEffect('Approval', 4.0),
      ],
    ),
    PolicyModel(
      id: 'renewable_energy', name: 'Renewable Energy Push', cost: 12,
      description: 'Transition to solar, wind, and clean energy sources.',
      category: PolicyCategory.economic,
      effects: [
        StatEffect('GDP Growth', 1.0),
        StatEffect('Happiness', 5.0),
        StatEffect('Stability', 3.0),
        StatEffect('Approval', 5.0),
      ],
    ),

    // ═══════════════════ MILITARY ═══════════════════
    PolicyModel(
      id: 'military_expansion', name: 'Military Expansion', cost: 25,
      description: 'Increase defense spending to build a stronger armed forces.',
      category: PolicyCategory.military,
      effects: [
        StatEffect('Military Strength', 10.0),
        StatEffect('GDP Growth', -1.0),
        StatEffect('Happiness', -2.0),
        StatEffect('Approval', 2.0),
      ],
    ),
    PolicyModel(
      id: 'military_cut', name: 'Defense Budget Cut', cost: 0,
      description: 'Reduce military spending and redirect funds to social programs.',
      category: PolicyCategory.military,
      effects: [
        StatEffect('Military Strength', -8.0),
        StatEffect('Happiness', 3.0),
        StatEffect('Education', 3.0),
        StatEffect('Approval', 1.0),
      ],
    ),
    PolicyModel(
      id: 'nuclear_program', name: 'Nuclear Deterrent', cost: 50,
      description: 'Develop nuclear weapons capability as a strategic deterrent.',
      category: PolicyCategory.military,
      minApprovalToApply: 40,
      effects: [
        StatEffect('Military Strength', 25.0),
        StatEffect('Diplomatic Rep', -15.0),
        StatEffect('Stability', 5.0),
        StatEffect('Approval', -3.0),
      ],
    ),
    PolicyModel(
      id: 'conscription', name: 'Mandatory Military Service', cost: 3,
      description: 'Require all citizens to serve in the military for a period.',
      category: PolicyCategory.military,
      effects: [
        StatEffect('Military Strength', 8.0),
        StatEffect('Happiness', -5.0),
        StatEffect('Education', -2.0),
        StatEffect('Approval', -4.0),
      ],
    ),
    PolicyModel(
      id: 'military_alliance', name: 'Join Military Alliance', cost: 2,
      description: 'Form a mutual defense pact with allied nations.',
      category: PolicyCategory.military,
      effects: [
        StatEffect('Military Strength', 5.0),
        StatEffect('Diplomatic Rep', 8.0),
        StatEffect('Stability', 5.0),
        StatEffect('Approval', 3.0),
      ],
    ),

    // ═══════════════════ SOCIAL ═══════════════════
    PolicyModel(
      id: 'universal_healthcare', name: 'Universal Healthcare', cost: 18,
      description: 'Provide free healthcare for all citizens.',
      category: PolicyCategory.social,
      effects: [
        StatEffect('Healthcare', 12.0),
        StatEffect('Happiness', 10.0),
        StatEffect('Approval', 8.0),
        StatEffect('GDP Growth', -1.0),
      ],
    ),
    PolicyModel(
      id: 'education_reform', name: 'Education Reform', cost: 12,
      description: 'Overhaul the education system with increased funding and curriculum reform.',
      category: PolicyCategory.social,
      effects: [
        StatEffect('Education', 10.0),
        StatEffect('Happiness', 6.0),
        StatEffect('Approval', 6.0),
        StatEffect('GDP Growth', 1.5),
      ],
    ),
    PolicyModel(
      id: 'anti_corruption', name: 'Anti-Corruption Drive', cost: 5,
      description: 'Launch a major campaign to root out government corruption.',
      category: PolicyCategory.social,
      minApprovalToApply: 35,
      effects: [
        StatEffect('Corruption', 12.0),
        StatEffect('Happiness', 5.0),
        StatEffect('Diplomatic Rep', 5.0),
        StatEffect('Approval', 7.0),
      ],
    ),
    PolicyModel(
      id: 'social_housing', name: 'Social Housing Program', cost: 10,
      description: 'Build affordable housing for low-income citizens.',
      category: PolicyCategory.social,
      effects: [
        StatEffect('Happiness', 8.0),
        StatEffect('Employment', 2.0),
        StatEffect('Approval', 6.0),
        StatEffect('Stability', 3.0),
      ],
    ),
    PolicyModel(
      id: 'media_freedom', name: 'Press Freedom', cost: 1,
      description: 'Guarantee freedom of the press and independent journalism.',
      category: PolicyCategory.social,
      effects: [
        StatEffect('Happiness', 5.0),
        StatEffect('Diplomatic Rep', 6.0),
        StatEffect('Corruption', 5.0),
        StatEffect('Approval', 3.0),
      ],
    ),
    PolicyModel(
      id: 'censorship', name: 'Media Censorship', cost: 1,
      description: 'Control state and private media to manage public narrative.',
      category: PolicyCategory.social,
      effects: [
        StatEffect('Happiness', -7.0),
        StatEffect('Stability', 4.0),
        StatEffect('Diplomatic Rep', -6.0),
        StatEffect('Approval', -5.0),
      ],
    ),

    // ═══════════════════ DIPLOMATIC ═══════════════════
    PolicyModel(
      id: 'foreign_aid', name: 'Foreign Aid Program', cost: 8,
      description: 'Provide financial and humanitarian aid to developing nations.',
      category: PolicyCategory.diplomatic,
      effects: [
        StatEffect('Diplomatic Rep', 10.0),
        StatEffect('Happiness', 2.0),
        StatEffect('Approval', 3.0),
        StatEffect('GDP Growth', -0.5),
      ],
    ),
    PolicyModel(
      id: 'sanctions', name: 'Economic Sanctions', cost: 1,
      description: 'Impose trade sanctions on a rival or rogue nation.',
      category: PolicyCategory.diplomatic,
      effects: [
        StatEffect('Diplomatic Rep', -5.0),
        StatEffect('Military Strength', 3.0),
        StatEffect('GDP Growth', -1.0),
        StatEffect('Approval', 1.0),
      ],
    ),
    PolicyModel(
      id: 'open_borders', name: 'Open Border Policy', cost: 2,
      description: 'Allow free movement of people and workers across borders.',
      category: PolicyCategory.diplomatic,
      effects: [
        StatEffect('Diplomatic Rep', 7.0),
        StatEffect('GDP Growth', 2.0),
        StatEffect('Happiness', -3.0),
        StatEffect('Approval', -2.0),
      ],
    ),
    PolicyModel(
      id: 'un_leadership', name: 'Seek UN Leadership', cost: 4,
      description: 'Campaign for a leadership role in United Nations bodies.',
      category: PolicyCategory.diplomatic,
      effects: [
        StatEffect('Diplomatic Rep', 12.0),
        StatEffect('Stability', 4.0),
        StatEffect('Military Strength', 2.0),
        StatEffect('Approval', 4.0),
      ],
    ),
  ];

  static List<PolicyModel> byCategory(PolicyCategory cat) =>
      all.where((p) => p.category == cat).toList();
}
