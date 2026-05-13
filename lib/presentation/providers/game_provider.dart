import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/country_model.dart';
import '../../data/models/game_state_model.dart';
import '../../data/models/policy_model.dart';
import '../../data/models/event_model.dart';
import '../../services/simulation_engine.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameStateModel?>(
  (ref) => GameNotifier(),
);

final pendingEventProvider = StateProvider<EventModel?>((ref) => null);

class GameNotifier extends StateNotifier<GameStateModel?> {
  GameNotifier() : super(null);

  void startGame(CountryModel country) {
    state = SimulationEngine.initFromCountry(country);
  }

  void applyPolicy(PolicyModel policy) {
    if (state == null) return;
    state = SimulationEngine.applyPolicy(state!, policy);
  }

  void applyEventChoice(EventChoice choice) {
    if (state == null) return;
    state = SimulationEngine.applyEventChoice(state!, choice);
  }

  GameStateModel advanceYear() {
    if (state == null) return state!;
    state = SimulationEngine.advanceYear(state!);
    return state!;
  }

  void reset() => state = null;
}
