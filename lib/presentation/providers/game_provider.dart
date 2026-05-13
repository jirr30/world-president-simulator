import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/country_model.dart';
import '../../data/models/game_state_model.dart';
import '../../data/models/policy_model.dart';
import '../../data/models/event_model.dart';
import '../../services/simulation_engine.dart';
import '../../services/game_save_service.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameStateModel?>(
  (ref) => GameNotifier(),
);

final pendingEventProvider = StateProvider<EventModel?>((ref) => null);

class GameNotifier extends StateNotifier<GameStateModel?> {
  GameNotifier() : super(null);

  void startGame(CountryModel country) {
    state = SimulationEngine.initFromCountry(country);
    GameSaveService.save(state!);
  }

  Future<bool> loadGame() async {
    final saved = await GameSaveService.load();
    if (saved == null) return false;
    state = saved;
    return true;
  }

  void applyPolicy(PolicyModel policy) {
    if (state == null) return;
    state = SimulationEngine.applyPolicy(state!, policy);
    GameSaveService.save(state!);
  }

  void applyEventChoice(EventChoice choice) {
    if (state == null) return;
    state = SimulationEngine.applyEventChoice(state!, choice);
    GameSaveService.save(state!);
  }

  GameStateModel advanceYear() {
    if (state == null) return state!;
    state = SimulationEngine.advanceYear(state!);
    GameSaveService.save(state!);
    return state!;
  }

  // Leave mid-game: keeps save so player can continue later
  void leaveGame() {
    state = null;
  }

  // Game ended (term over or quit from game over screen): wipes save
  void endGame() {
    GameSaveService.delete();
    state = null;
  }

  // Legacy alias used by existing screens — same as endGame
  void reset() => endGame();
}
