class XpEngine {
  XpEngine({this.xpPerQuest = 25}) : assert(xpPerQuest > 0);

  final int xpPerQuest;

  final Map<String, int> _awardedCompletions = {};

  int get totalXp => _awardedCompletions.values.fold(0, (sum, xp) => sum + xp);

  int get level {
    var currentLevel = 1;

    while (totalXp >= xpRequiredForLevel(currentLevel + 1)) {
      currentLevel++;
    }

    return currentLevel;
  }

  int xpRequiredForLevel(int targetLevel) {
    if (targetLevel < 1) {
      throw ArgumentError.value(
        targetLevel,
        'targetLevel',
        'Level must be at least 1',
      );
    }

    return 50 * targetLevel * (targetLevel - 1);
  }

  int get currentLevelXp => totalXp - xpRequiredForLevel(level);

  int get xpNeededForNextLevel =>
      xpRequiredForLevel(level + 1) - xpRequiredForLevel(level);

  double get levelProgress => currentLevelXp / xpNeededForNextLevel;

  int get xpRemaining => xpRequiredForLevel(level + 1) - totalXp;

  bool awardQuest(String completionId, {int? xp}) {
    if (completionId.trim().isEmpty) {
      throw ArgumentError('Completion ID cannot be empty');
    }

    if (_awardedCompletions.containsKey(completionId)) {
      return false;
    }

    final reward = xp ?? xpPerQuest;

    if (reward <= 0) {
      throw ArgumentError('XP reward must be positive');
    }

    _awardedCompletions[completionId] = reward;
    return true;
  }

  bool undoQuest(String completionId) {
    return _awardedCompletions.remove(completionId) != null;
  }

  bool hasAwarded(String completionId) =>
      _awardedCompletions.containsKey(completionId);
}
