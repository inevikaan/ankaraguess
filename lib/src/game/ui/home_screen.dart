import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../data/mock_round_repository.dart';
import '../logic/player_progression.dart';
import '../model/game_difficulty.dart';
import 'game_screen.dart';
import 'widgets/logo_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MockRoundRepository _repository = const MockRoundRepository();
  GameDifficulty _selectedDifficulty = GameDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppPalette.navy, AppPalette.navyDark],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: <Widget>[
                const Spacer(),
                const LogoBadge(scale: 1.08),
                const SizedBox(height: 26),
                Text(
                  '“Ankara\'yı avucumun içi gibi\nbilirim” diyenlere.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppPalette.textSecondary,
                    fontSize: 34,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedBuilder(
                  animation: PlayerProgression.instance,
                  builder: (BuildContext context, Widget? child) {
                    final PlayerProgression progression =
                        PlayerProgression.instance;
                    final int unlockedDistricts = _repository
                        .unlockedDistrictCount(progression.level);
                    return _ProgressionCard(
                      level: progression.level,
                      xpInLevel: progression.xpInLevel,
                      xpForNextLevel: progression.xpForNextLevel,
                      progressRatio: progression.progressRatio,
                      unlockedDistricts: unlockedDistricts,
                    );
                  },
                ),
                const SizedBox(height: 14),
                _DifficultySelector(
                  selected: _selectedDifficulty,
                  onChanged: (GameDifficulty difficulty) {
                    setState(() {
                      _selectedDifficulty = difficulty;
                    });
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            GameScreen(difficulty: _selectedDifficulty),
                      ),
                    );
                  },
                  child: const Text('OYNA'),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'made by inevi',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: AppPalette.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressionCard extends StatelessWidget {
  const _ProgressionCard({
    required this.level,
    required this.xpInLevel,
    required this.xpForNextLevel,
    required this.progressRatio,
    required this.unlockedDistricts,
  });

  final int level;
  final int xpInLevel;
  final int xpForNextLevel;
  final double progressRatio;
  final int unlockedDistricts;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Seviye $level',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppPalette.cyanSoft),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progressRatio.clamp(0, 1),
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(AppPalette.cyan),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$xpInLevel / $xpForNextLevel XP • Açık ilçe: $unlockedDistricts',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              color: AppPalette.textPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({required this.selected, required this.onChanged});

  final GameDifficulty selected;
  final ValueChanged<GameDifficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'Zorluk Seviyesi',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppPalette.cyanSoft),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: GameDifficulty.values.map((GameDifficulty difficulty) {
            final bool isSelected = selected == difficulty;
            return ChoiceChip(
              selected: isSelected,
              label: Text(
                '${difficulty.label} '
                '(${difficulty.revealSeconds}/${difficulty.guessSeconds} sn)',
              ),
              selectedColor: AppPalette.button,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppPalette.cyanSoft,
                fontWeight: FontWeight.w700,
              ),
              onSelected: (_) => onChanged(difficulty),
            );
          }).toList(),
        ),
      ],
    );
  }
}
