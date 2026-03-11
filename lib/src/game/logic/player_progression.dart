import 'package:flutter/foundation.dart';

class PlayerProgression extends ChangeNotifier {
  PlayerProgression._();

  static final PlayerProgression instance = PlayerProgression._();

  int _level = 1;
  int _xpInLevel = 0;
  int _totalXp = 0;

  int get level => _level;
  int get xpInLevel => _xpInLevel;
  int get totalXp => _totalXp;
  int get xpForNextLevel => 250 + ((_level - 1) * 120);

  double get progressRatio => _xpInLevel / xpForNextLevel;

  int addXp(int amount) {
    if (amount <= 0) {
      return 0;
    }

    final int initialLevel = _level;
    _totalXp += amount;
    _xpInLevel += amount;

    while (true) {
      final int neededXp = xpForNextLevel;
      if (_xpInLevel < neededXp) {
        break;
      }
      _xpInLevel -= neededXp;
      _level++;
    }

    notifyListeners();
    return _level - initialLevel;
  }
}
