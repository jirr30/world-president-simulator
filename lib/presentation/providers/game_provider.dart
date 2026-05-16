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

  void proposeAlliance(String countryName) {
    if (state == null) return;
    state = SimulationEngine.proposeAlliance(state!, countryName);
    GameSaveService.save(state!);
  }

  void breakAlliance(String countryName) {
    if (state == null) return;
    state = SimulationEngine.breakAlliance(state!, countryName);
    GameSaveService.save(state!);
  }

  void imposeSanction(String countryName) {
    if (state == null) return;
    state = SimulationEngine.imposeSanction(state!, countryName);
    GameSaveService.save(state!);
  }

  void liftSanction(String countryName) {
    if (state == null) return;
    state = SimulationEngine.liftSanction(state!, countryName);
    GameSaveService.save(state!);
  }

  void declareWar() {
    if (state == null) return;
    state = SimulationEngine.declareWar(state!);
    GameSaveService.save(state!);
  }

  void sueForPeace() {
    if (state == null) return;
    state = SimulationEngine.sueForPeace(state!);
    GameSaveService.save(state!);
  }

  void setTaxRate(double rate) {
    if (state == null) return;
    state = state!.copyWith(taxRate: rate.clamp(5.0, 60.0));
    GameSaveService.save(state!);
  }

  void setMilitaryBudget(double budget) {
    if (state == null) return;
    final min = state!.gdpBillion * 0.005;
    final max = state!.gdpBillion * 0.15;
    state = state!.copyWith(militaryBudget: budget.clamp(min, max));
    GameSaveService.save(state!);
  }

  void setHealthcareBudget(double budget) {
    if (state == null) return;
    final max = state!.gdpBillion * 0.08;
    state = state!.copyWith(healthcareBudget: budget.clamp(0.0, max));
    GameSaveService.save(state!);
  }

  void setEducationBudget(double budget) {
    if (state == null) return;
    final max = state!.gdpBillion * 0.08;
    state = state!.copyWith(educationBudget: budget.clamp(0.0, max));
    GameSaveService.save(state!);
  }

  void removePolicy(String policyId) {
    if (state == null) return;
    state = SimulationEngine.removePolicy(state!, policyId);
    GameSaveService.save(state!);
  }

  void buildOrUpgrade(String buildingId) {
    if (state == null) return;
    state = SimulationEngine.buildOrUpgrade(state!, buildingId);
    GameSaveService.save(state!);
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
