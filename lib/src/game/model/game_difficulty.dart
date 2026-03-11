enum GameDifficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case GameDifficulty.easy:
        return 'Kolay';
      case GameDifficulty.medium:
        return 'Orta';
      case GameDifficulty.hard:
        return 'Zor';
    }
  }

  int get revealSeconds {
    switch (this) {
      case GameDifficulty.easy:
        return 12;
      case GameDifficulty.medium:
        return 10;
      case GameDifficulty.hard:
        return 7;
    }
  }

  int get guessSeconds {
    switch (this) {
      case GameDifficulty.easy:
        return 18;
      case GameDifficulty.medium:
        return 15;
      case GameDifficulty.hard:
        return 10;
    }
  }

  double get radiusMultiplier {
    switch (this) {
      case GameDifficulty.easy:
        return 0.75;
      case GameDifficulty.medium:
        return 1.0;
      case GameDifficulty.hard:
        return 1.25;
    }
  }

  double get xpMultiplier {
    switch (this) {
      case GameDifficulty.easy:
        return 0.9;
      case GameDifficulty.medium:
        return 1.0;
      case GameDifficulty.hard:
        return 1.2;
    }
  }

  bool get showDistrict {
    switch (this) {
      case GameDifficulty.easy:
      case GameDifficulty.medium:
        return true;
      case GameDifficulty.hard:
        return false;
    }
  }
}
