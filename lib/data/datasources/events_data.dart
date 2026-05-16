import '../models/event_model.dart';
import '../models/policy_model.dart';

class EventsData {
  EventsData._();

  static const List<EventModel> all = [
    // ═══════════════════ ECONOMIC EVENTS ═══════════════════
    EventModel(
      id: 'global_recession', emoji: '📉',
      title: 'Global Economic Recession',
      description: 'A worldwide financial crisis has triggered a severe recession. Markets are crashing, unemployment is rising, and your advisors are divided on the response.',
      severity: EventSeverity.critical,
      choices: [
        EventChoice(
          label: 'Massive Stimulus Package',
          description: 'Inject billions into the economy through government spending.',
          effects: [StatEffect('GDP Growth', 3.0), StatEffect('National Debt', -8.0), StatEffect('Employment', 4.0), StatEffect('Approval', 5.0)],
        ),
        EventChoice(
          label: 'Austerity & Cuts',
          description: 'Slash government spending to prevent runaway debt.',
          effects: [StatEffect('GDP Growth', -3.0), StatEffect('National Debt', 6.0), StatEffect('Happiness', -8.0), StatEffect('Approval', -6.0)],
        ),
        EventChoice(
          label: 'Do Nothing',
          description: 'Let the market correct itself naturally.',
          effects: [StatEffect('GDP Growth', -5.0), StatEffect('Happiness', -5.0), StatEffect('Employment', -3.0), StatEffect('Approval', -4.0)],
        ),
      ],
    ),
    EventModel(
      id: 'oil_price_spike', emoji: '🛢️',
      title: 'Global Oil Price Surge',
      description: 'Oil prices have skyrocketed by 80% following conflict in the Middle East. Energy costs are surging and inflation is rising.',
      severity: EventSeverity.high,
      choices: [
        EventChoice(
          label: 'Subsidize Energy',
          description: 'Use government funds to keep fuel prices affordable.',
          effects: [StatEffect('Happiness', 5.0), StatEffect('National Debt', -4.0), StatEffect('GDP Growth', 1.0), StatEffect('Approval', 4.0)],
        ),
        EventChoice(
          label: 'Accelerate Renewables',
          description: 'Emergency investment in renewable energy infrastructure.',
          effects: [StatEffect('Happiness', 2.0), StatEffect('GDP Growth', 1.5), StatEffect('Stability', 4.0), StatEffect('Approval', 3.0)],
        ),
        EventChoice(
          label: 'Let Prices Rise',
          description: 'Allow the market to set energy prices freely.',
          effects: [StatEffect('Inflation', -5.0), StatEffect('Happiness', -7.0), StatEffect('GDP Growth', -2.0), StatEffect('Approval', -5.0)],
        ),
      ],
    ),
    EventModel(
      id: 'tech_boom', emoji: '💻',
      title: 'Technology Boom',
      description: 'A wave of innovation has created a booming tech sector in your country. Silicon Valley investors are interested in relocating.',
      severity: EventSeverity.low,
      choices: [
        EventChoice(
          label: 'Attract Tech Giants',
          description: 'Offer tax incentives to bring major tech companies.',
          effects: [StatEffect('GDP Growth', 4.0), StatEffect('Employment', 3.0), StatEffect('Education', 2.0), StatEffect('Approval', 5.0)],
        ),
        EventChoice(
          label: 'Regulate the Sector',
          description: 'Impose oversight to ensure fair competition and data privacy.',
          effects: [StatEffect('GDP Growth', 1.5), StatEffect('Happiness', 3.0), StatEffect('Corruption', 3.0), StatEffect('Approval', 3.0)],
        ),
        EventChoice(
          label: 'Nationalize Tech',
          description: 'Create state-owned technology enterprises.',
          effects: [StatEffect('GDP Growth', -1.0), StatEffect('Diplomatic Rep', -4.0), StatEffect('Stability', 2.0), StatEffect('Approval', -2.0)],
        ),
      ],
    ),
    EventModel(
      id: 'currency_crisis', emoji: '💸',
      title: 'Currency Crisis',
      description: 'Your national currency has lost 40% of its value in a week. Imports are now unaffordable and inflation is spiraling.',
      severity: EventSeverity.critical,
      choices: [
        EventChoice(
          label: 'IMF Bailout',
          description: 'Accept IMF conditions in exchange for emergency loans.',
          effects: [StatEffect('National Debt', 10.0), StatEffect('GDP Growth', -1.0), StatEffect('Happiness', -5.0), StatEffect('Approval', -4.0)],
        ),
        EventChoice(
          label: 'Capital Controls',
          description: 'Restrict currency flows to stabilize the exchange rate.',
          effects: [StatEffect('Inflation', 4.0), StatEffect('Diplomatic Rep', -4.0), StatEffect('Stability', 4.0), StatEffect('Approval', -1.0)],
        ),
        EventChoice(
          label: 'Default & Restructure',
          description: 'Default on debt and renegotiate with creditors.',
          effects: [StatEffect('National Debt', 15.0), StatEffect('Diplomatic Rep', -10.0), StatEffect('GDP Growth', -4.0), StatEffect('Approval', -6.0)],
        ),
      ],
    ),

    // ═══════════════════ NATURAL DISASTERS ═══════════════════
    EventModel(
      id: 'earthquake', emoji: '🌍',
      title: 'Massive Earthquake',
      description: 'A devastating 7.8 magnitude earthquake has struck your country, destroying infrastructure and killing thousands.',
      severity: EventSeverity.critical,
      choices: [
        EventChoice(
          label: 'Emergency Declaration + Massive Relief',
          description: 'Mobilize the full power of the state for disaster response.',
          effects: [StatEffect('Happiness', 5.0), StatEffect('Approval', 8.0), StatEffect('National Debt', -6.0), StatEffect('GDP Growth', -1.5)],
        ),
        EventChoice(
          label: 'Request International Aid',
          description: 'Call on the international community for assistance.',
          effects: [StatEffect('Diplomatic Rep', 6.0), StatEffect('Happiness', 2.0), StatEffect('Approval', 4.0), StatEffect('GDP Growth', -0.5)],
        ),
        EventChoice(
          label: 'Minimal Response',
          description: 'Leave recovery mostly to local governments and markets.',
          effects: [StatEffect('Happiness', -10.0), StatEffect('Approval', -9.0), StatEffect('Stability', -5.0), StatEffect('GDP Growth', -3.0)],
        ),
      ],
    ),
    EventModel(
      id: 'pandemic', emoji: '🦠',
      title: 'Deadly Pandemic Outbreak',
      description: 'A new highly contagious disease is spreading rapidly across your country. The healthcare system is under severe strain.',
      severity: EventSeverity.critical,
      choices: [
        EventChoice(
          label: 'Strict Lockdown',
          description: 'Shut down the economy to control the spread.',
          effects: [StatEffect('Healthcare', 8.0), StatEffect('GDP Growth', -5.0), StatEffect('Happiness', -6.0), StatEffect('Approval', 2.0)],
        ),
        EventChoice(
          label: 'Vaccine Fast-Track',
          description: 'Emergency funding for accelerated vaccine development.',
          effects: [StatEffect('Healthcare', 10.0), StatEffect('GDP Growth', -1.0), StatEffect('National Debt', -5.0), StatEffect('Approval', 7.0)],
        ),
        EventChoice(
          label: 'Herd Immunity Strategy',
          description: 'Keep the economy open and let the virus run its course.',
          effects: [StatEffect('GDP Growth', 1.0), StatEffect('Healthcare', -8.0), StatEffect('Happiness', -8.0), StatEffect('Approval', -7.0)],
        ),
      ],
    ),
    EventModel(
      id: 'flood', emoji: '🌊',
      title: 'Catastrophic Flooding',
      description: 'Record rainfall has caused massive flooding across several regions, displacing millions and destroying farmland.',
      severity: EventSeverity.high,
      choices: [
        EventChoice(
          label: 'Emergency Infrastructure Fund',
          description: 'Build flood defenses and relocate affected populations.',
          effects: [StatEffect('Happiness', 4.0), StatEffect('Approval', 5.0), StatEffect('National Debt', -4.0), StatEffect('GDP Growth', 1.0)],
        ),
        EventChoice(
          label: 'International Climate Aid',
          description: 'Seek climate reparations from major polluting nations.',
          effects: [StatEffect('Diplomatic Rep', 4.0), StatEffect('Happiness', 2.0), StatEffect('Approval', 3.0), StatEffect('GDP Growth', 0.5)],
        ),
        EventChoice(
          label: 'Ignore and Rebuild Slowly',
          description: 'Provide minimal support and let communities self-recover.',
          effects: [StatEffect('Happiness', -7.0), StatEffect('Approval', -6.0), StatEffect('Stability', -3.0), StatEffect('GDP Growth', -1.0)],
        ),
      ],
    ),
    EventModel(
      id: 'drought', emoji: '☀️',
      title: 'Severe Drought',
      description: 'A prolonged drought is devastating agricultural production, threatening food security and causing mass rural unemployment.',
      severity: EventSeverity.high,
      choices: [
        EventChoice(
          label: 'Emergency Food Imports',
          description: 'Purchase food from international markets to prevent shortages.',
          effects: [StatEffect('Happiness', 3.0), StatEffect('Approval', 4.0), StatEffect('National Debt', -3.0), StatEffect('GDP Growth', -0.5)],
        ),
        EventChoice(
          label: 'Farmer Subsidies',
          description: 'Support affected farmers with direct financial aid.',
          effects: [StatEffect('Happiness', 5.0), StatEffect('Employment', 2.0), StatEffect('Approval', 5.0), StatEffect('National Debt', -2.0)],
        ),
        EventChoice(
          label: 'Ignore the Crisis',
          description: 'Allow market forces to respond to food shortages.',
          effects: [StatEffect('Happiness', -9.0), StatEffect('Stability', -5.0), StatEffect('Approval', -8.0), StatEffect('GDP Growth', -2.0)],
        ),
      ],
    ),

    // ═══════════════════ POLITICAL EVENTS ═══════════════════
    EventModel(
      id: 'coup_attempt', emoji: '🪖',
      title: 'Military Coup Attempt',
      description: 'A faction of military generals has staged a coup attempt. Tanks are on the streets and your government is in chaos.',
      severity: EventSeverity.critical,
      choices: [
        EventChoice(
          label: 'Crush the Coup',
          description: 'Use loyal forces to decisively suppress the rebellion.',
          effects: [StatEffect('Stability', 8.0), StatEffect('Military Strength', -5.0), StatEffect('Corruption', -5.0), StatEffect('Approval', 6.0)],
        ),
        EventChoice(
          label: 'Negotiate with Rebels',
          description: 'Offer concessions to prevent a bloody conflict.',
          effects: [StatEffect('Stability', 3.0), StatEffect('Happiness', 2.0), StatEffect('Approval', -2.0), StatEffect('Corruption', -3.0)],
        ),
        EventChoice(
          label: 'Flee into Exile',
          description: 'Abandon power to avoid civil war.',
          effects: [StatEffect('Stability', -15.0), StatEffect('Happiness', -15.0), StatEffect('Approval', -20.0), StatEffect('Military Strength', -10.0)],
        ),
      ],
    ),
    EventModel(
      id: 'protest', emoji: '✊',
      title: 'Mass Pro-Democracy Protests',
      description: 'Millions of citizens have taken to the streets demanding political reforms, greater freedoms, and accountability.',
      severity: EventSeverity.high,
      choices: [
        EventChoice(
          label: 'Embrace Reform',
          description: 'Meet with protest leaders and announce genuine political reforms.',
          effects: [StatEffect('Happiness', 8.0), StatEffect('Diplomatic Rep', 5.0), StatEffect('Approval', 7.0), StatEffect('Stability', 4.0)],
        ),
        EventChoice(
          label: 'Offer Limited Concessions',
          description: 'Promise minor reforms while maintaining current power structure.',
          effects: [StatEffect('Happiness', 2.0), StatEffect('Approval', 1.0), StatEffect('Stability', 1.0), StatEffect('Corruption', -2.0)],
        ),
        EventChoice(
          label: 'Violent Crackdown',
          description: 'Deploy security forces to disperse protesters.',
          effects: [StatEffect('Happiness', -12.0), StatEffect('Diplomatic Rep', -10.0), StatEffect('Approval', -10.0), StatEffect('Stability', -5.0)],
        ),
      ],
    ),
    EventModel(
      id: 'election_scandal', emoji: '🗳️',
      title: 'Election Fraud Allegations',
      description: 'Opposition parties and international observers are alleging widespread fraud in the recent election. Protests are growing.',
      severity: EventSeverity.high,
      choices: [
        EventChoice(
          label: 'Independent Investigation',
          description: 'Allow a fully independent audit of election results.',
          effects: [StatEffect('Diplomatic Rep', 7.0), StatEffect('Happiness', 5.0), StatEffect('Approval', 5.0), StatEffect('Corruption', 5.0)],
        ),
        EventChoice(
          label: 'Dismiss the Claims',
          description: 'Declare the election legitimate and continue governing.',
          effects: [StatEffect('Diplomatic Rep', -6.0), StatEffect('Happiness', -5.0), StatEffect('Approval', -4.0), StatEffect('Stability', -3.0)],
        ),
        EventChoice(
          label: 'Call New Elections',
          description: 'Voluntarily hold new elections to restore confidence.',
          effects: [StatEffect('Diplomatic Rep', 5.0), StatEffect('Happiness', 6.0), StatEffect('Approval', 4.0), StatEffect('Stability', 5.0)],
        ),
      ],
    ),
    EventModel(
      id: 'assassination_attempt', emoji: '🎯',
      title: 'Assassination Attempt',
      description: 'An armed group has attempted to assassinate you. You escaped unharmed, but national security is on high alert.',
      severity: EventSeverity.critical,
      choices: [
        EventChoice(
          label: 'Declare State of Emergency',
          description: 'Grant expanded powers to security forces to find the perpetrators.',
          effects: [StatEffect('Stability', 6.0), StatEffect('Military Strength', 3.0), StatEffect('Happiness', -3.0), StatEffect('Approval', 3.0)],
        ),
        EventChoice(
          label: 'Blame Rival Nation',
          description: 'Publicly accuse a foreign power of orchestrating the attempt.',
          effects: [StatEffect('Diplomatic Rep', -8.0), StatEffect('Military Strength', 2.0), StatEffect('Approval', 2.0), StatEffect('Stability', 1.0)],
        ),
        EventChoice(
          label: 'Show Calm Leadership',
          description: 'Address the nation calmly and vow to continue governing.',
          effects: [StatEffect('Approval', 7.0), StatEffect('Happiness', 4.0), StatEffect('Stability', 5.0), StatEffect('Diplomatic Rep', 3.0)],
        ),
      ],
    ),

    // ═══════════════════ INTERNATIONAL EVENTS ═══════════════════
    EventModel(
      id: 'border_dispute', emoji: '⚔️',
      title: 'Border Conflict Erupts',
      description: 'Armed clashes have broken out on your border with a neighboring nation over disputed territory. International pressure is mounting.',
      severity: EventSeverity.critical,
      choices: [
        EventChoice(
          label: 'Military Force',
          description: 'Send troops to seize and hold the disputed territory.',
          effects: [StatEffect('Military Strength', 5.0), StatEffect('Diplomatic Rep', -10.0), StatEffect('National Debt', -8.0), StatEffect('Approval', 2.0)],
        ),
        EventChoice(
          label: 'UN Mediation',
          description: 'Refer the dispute to the United Nations for mediation.',
          effects: [StatEffect('Diplomatic Rep', 8.0), StatEffect('Stability', 4.0), StatEffect('Approval', 4.0), StatEffect('Happiness', 2.0)],
        ),
        EventChoice(
          label: 'Direct Negotiation',
          description: 'Negotiate directly with the neighboring country\'s leader.',
          effects: [StatEffect('Diplomatic Rep', 5.0), StatEffect('Stability', 3.0), StatEffect('Approval', 3.0), StatEffect('Happiness', 2.0)],
        ),
      ],
    ),
    EventModel(
      id: 'refugee_crisis', emoji: '🏕️',
      title: 'Refugee Crisis at Borders',
      description: 'Hundreds of thousands of refugees are fleeing conflict in a neighboring country and seeking asylum in your nation.',
      severity: EventSeverity.high,
      choices: [
        EventChoice(
          label: 'Open Borders & Integration',
          description: 'Welcome refugees and invest in integration programs.',
          effects: [StatEffect('Diplomatic Rep', 8.0), StatEffect('Happiness', -3.0), StatEffect('GDP Growth', 1.5), StatEffect('Approval', -1.0)],
        ),
        EventChoice(
          label: 'Controlled Refugee Program',
          description: 'Accept limited numbers with thorough screening.',
          effects: [StatEffect('Diplomatic Rep', 3.0), StatEffect('Happiness', 1.0), StatEffect('Approval', 2.0), StatEffect('Stability', 1.0)],
        ),
        EventChoice(
          label: 'Close the Borders',
          description: 'Seal the borders and turn away all refugees.',
          effects: [StatEffect('Diplomatic Rep', -8.0), StatEffect('Happiness', 2.0), StatEffect('Approval', -2.0), StatEffect('Stability', 3.0)],
        ),
      ],
    ),
    EventModel(
      id: 'trade_deal', emoji: '🤝',
      title: 'Major Trade Deal Opportunity',
      description: 'A powerful economic bloc is offering your country a comprehensive trade agreement with significant market access.',
      severity: EventSeverity.medium,
      choices: [
        EventChoice(
          label: 'Sign the Deal',
          description: 'Accept the terms and join the economic partnership.',
          effects: [StatEffect('GDP Growth', 3.0), StatEffect('Diplomatic Rep', 6.0), StatEffect('Employment', 2.0), StatEffect('Approval', 4.0)],
        ),
        EventChoice(
          label: 'Renegotiate Terms',
          description: 'Push for better terms before signing.',
          effects: [StatEffect('GDP Growth', 1.5), StatEffect('Diplomatic Rep', 2.0), StatEffect('Approval', 2.0), StatEffect('Happiness', 1.0)],
        ),
        EventChoice(
          label: 'Reject the Deal',
          description: 'Decline and protect national economic independence.',
          effects: [StatEffect('GDP Growth', -1.0), StatEffect('Diplomatic Rep', -3.0), StatEffect('Approval', -1.0), StatEffect('Happiness', 1.0)],
        ),
      ],
    ),
    EventModel(
      id: 'cyber_attack', emoji: '💻',
      title: 'Major Cyber Attack',
      description: 'Foreign hackers have penetrated critical government and infrastructure systems, causing widespread disruption.',
      severity: EventSeverity.high,
      choices: [
        EventChoice(
          label: 'Cyber Retaliation',
          description: 'Launch a counter cyber offensive against the suspected nation.',
          effects: [StatEffect('Military Strength', 3.0), StatEffect('Diplomatic Rep', -5.0), StatEffect('Stability', 2.0), StatEffect('Approval', 3.0)],
        ),
        EventChoice(
          label: 'Harden Defenses',
          description: 'Invest massively in cybersecurity and defensive capabilities.',
          effects: [StatEffect('Military Strength', 5.0), StatEffect('Stability', 5.0), StatEffect('GDP Growth', -0.5), StatEffect('Approval', 4.0)],
        ),
        EventChoice(
          label: 'Diplomatic Protest',
          description: 'Issue formal protests through diplomatic channels.',
          effects: [StatEffect('Diplomatic Rep', 2.0), StatEffect('Stability', 1.0), StatEffect('Approval', 1.0), StatEffect('Military Strength', 1.0)],
        ),
      ],
    ),
    EventModel(
      id: 'space_program', emoji: '🚀',
      title: 'Space Program Milestone',
      description: 'Your space agency has achieved a breakthrough — you can now launch your own satellites. Expand or commercialize?',
      severity: EventSeverity.low,
      choices: [
        EventChoice(
          label: 'Moon Mission Announcement',
          description: 'Announce an ambitious crewed moon mission.',
          effects: [StatEffect('Happiness', 8.0), StatEffect('Education', 5.0), StatEffect('Approval', 7.0), StatEffect('National Debt', -5.0)],
        ),
        EventChoice(
          label: 'Commercialize',
          description: 'Open the space program to private investment.',
          effects: [StatEffect('GDP Growth', 3.0), StatEffect('Education', 3.0), StatEffect('Approval', 4.0), StatEffect('Happiness', 4.0)],
        ),
        EventChoice(
          label: 'Military Satellites',
          description: 'Prioritize military and surveillance satellite network.',
          effects: [StatEffect('Military Strength', 8.0), StatEffect('Diplomatic Rep', -3.0), StatEffect('Stability', 4.0), StatEffect('Approval', 2.0)],
        ),
      ],
    ),
  ];

  static List<EventModel> getRandomEvents({int count = 1, String? continent}) {
    final eligible = continent == null
        ? List<EventModel>.from(all)
        : all.where((e) => e.applicableContinent.isEmpty || e.applicableContinent.contains(continent)).toList();
    eligible.shuffle();
    return eligible.take(count).toList();
  }

  // Forced event: at war AND militaryStrength < 25
  static EventModel peaceOfferEvent() => EventModel(
    id: 'peace_offer',
    emoji: '🕊️',
    title: 'Peace Negotiations',
    description:
        'Your military is struggling under sustained combat losses. '
        'International mediators have stepped in and are offering to broker a ceasefire. '
        'This may be your last chance to end the conflict before the country collapses.',
    severity: EventSeverity.high,
    choices: [
      EventChoice(
        label: 'Accept Ceasefire',
        description: 'End the war under international mediation.',
        effects: [
          StatEffect('At War', -1.0),
          StatEffect('Happiness', 8.0),
          StatEffect('Diplomatic Rep', 5.0),
          StatEffect('Stability', 6.0),
          StatEffect('Approval', 4.0),
        ],
      ),
      EventChoice(
        label: 'Fight On',
        description: 'Reject the offer and continue fighting to the end.',
        effects: [
          StatEffect('Military Strength', -6.0),
          StatEffect('Happiness', -7.0),
          StatEffect('Approval', -5.0),
          StatEffect('Stability', -3.0),
        ],
      ),
      EventChoice(
        label: 'Direct Talks',
        description: 'Negotiate directly with the opposing side on your own terms.',
        effects: [
          StatEffect('At War', -1.0),
          StatEffect('Diplomatic Rep', -2.0),
          StatEffect('Stability', 3.0),
          StatEffect('Happiness', 5.0),
        ],
      ),
    ],
  );

  // Forced event: military < 30 AND stability < 40 AND not at war (foreign invasion)
  static EventModel invasionEvent() => EventModel(
    id: 'foreign_invasion',
    emoji: '⚔️',
    title: 'Foreign Invasion',
    description:
        'A neighboring country has launched a full-scale military assault on your borders. '
        'Your weakened armed forces are struggling to mount an effective defense. '
        'The nation is in crisis — every decision counts.',
    severity: EventSeverity.critical,
    choices: [
      EventChoice(
        label: 'Full Military Resistance',
        description: 'Order all available forces to repel the invasion at any cost.',
        effects: [
          StatEffect('At War', 1.0),
          StatEffect('Military Strength', -10.0),
          StatEffect('Happiness', -8.0),
          StatEffect('Approval', 6.0),
          StatEffect('Stability', -5.0),
        ],
      ),
      EventChoice(
        label: 'Emergency Mobilization',
        description: 'Declare a national emergency and conscript additional troops.',
        effects: [
          StatEffect('At War', 1.0),
          StatEffect('Military Strength', -5.0),
          StatEffect('Troops', 500.0),
          StatEffect('Happiness', -10.0),
          StatEffect('GDP Growth', -1.5),
        ],
      ),
      EventChoice(
        label: 'Seek Allied Support',
        description: 'Appeal to allies and international community for immediate military aid.',
        effects: [
          StatEffect('At War', 1.0),
          StatEffect('Military Strength', -8.0),
          StatEffect('Diplomatic Rep', -5.0),
          StatEffect('Happiness', -5.0),
          StatEffect('Stability', -3.0),
        ],
      ),
    ],
  );

  // Forced event: atWar AND warProgress >= 100 (enemy forces fully degraded)
  static EventModel warVictoryEvent() => EventModel(
    id: 'war_victory',
    emoji: '🏆',
    title: 'Military Victory',
    description:
        'Your armed forces have systematically degraded the enemy military. '
        'The opposing nation is on the brink of collapse — their generals are requesting talks. '
        'How will you end this conflict?',
    severity: EventSeverity.high,
    choices: [
      EventChoice(
        label: 'Demand Unconditional Surrender',
        description: 'Force the enemy to surrender completely on your terms.',
        effects: [
          StatEffect('At War', -1.0),
          StatEffect('Military Strength', 5.0),
          StatEffect('Approval', 12.0),
          StatEffect('Diplomatic Rep', -8.0),
          StatEffect('Stability', 5.0),
        ],
      ),
      EventChoice(
        label: 'Offer Generous Peace Terms',
        description: 'End the war with a fair settlement to build lasting peace.',
        effects: [
          StatEffect('At War', -1.0),
          StatEffect('Diplomatic Rep', 10.0),
          StatEffect('Happiness', 8.0),
          StatEffect('Approval', 8.0),
          StatEffect('Stability', 6.0),
        ],
      ),
      EventChoice(
        label: 'Occupy & Annex Territory',
        description: 'Claim enemy land as war reparations to expand your nation.',
        effects: [
          StatEffect('At War', -1.0),
          StatEffect('GDP Growth', 1.5),
          StatEffect('Natural Resources', 8.0),
          StatEffect('Diplomatic Rep', -15.0),
          StatEffect('Stability', -3.0),
          StatEffect('Approval', 6.0),
        ],
      ),
    ],
  );

  // Forced event: tax rate ≥ 45% AND happiness < 40
  static EventModel taxProtestEvent(double taxRate) => EventModel(
    id: 'tax_protest',
    emoji: '✊',
    title: 'Mass Tax Protests',
    description:
        'With the tax rate at ${taxRate.toStringAsFixed(0)}% and public morale at rock bottom, '
        'hundreds of thousands have taken to the streets demanding immediate relief. '
        'The international community is watching. How will you respond?',
    severity: EventSeverity.critical,
    choices: [
      EventChoice(
        label: 'Emergency Tax Cut',
        description: 'Slash the tax rate by 15 points immediately to restore public calm.',
        effects: [
          StatEffect('Tax Rate', -15.0),
          StatEffect('Happiness', 12.0),
          StatEffect('Approval', 10.0),
          StatEffect('GDP Growth', 1.5),
        ],
      ),
      EventChoice(
        label: 'Gradual Reform',
        description: 'Promise a phased tax reduction plan over the next two years.',
        effects: [
          StatEffect('Happiness', 5.0),
          StatEffect('Approval', 3.0),
          StatEffect('Stability', -2.0),
        ],
      ),
      EventChoice(
        label: 'Crack Down',
        description: 'Deploy police to disperse protests and maintain order.',
        effects: [
          StatEffect('Stability', 3.0),
          StatEffect('Happiness', -10.0),
          StatEffect('Approval', -12.0),
          StatEffect('Diplomatic Rep', -6.0),
        ],
      ),
    ],
  );
}
