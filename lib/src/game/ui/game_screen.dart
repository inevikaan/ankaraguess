import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/app_theme.dart';
import '../data/mock_round_repository.dart';
import '../logic/player_progression.dart';
import '../logic/score_calculator.dart';
import '../model/game_difficulty.dart';
import '../model/game_round.dart';
import '../model/geo_point.dart';
import 'widgets/logo_badge.dart';

enum GamePhase { reveal, guess, result, finished }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.difficulty = GameDifficulty.medium});

  final GameDifficulty difficulty;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int _roundCount = 5;
  static const double _guessMinZoom = 9;
  static const double _guessMaxZoom = 18;
  static const double _guessInitialZoom = 11;
  static const GeoPoint _ankaraCenter = GeoPoint(
    latitude: 39.9250,
    longitude: 32.8369,
  );

  final MockRoundRepository _repository = const MockRoundRepository();
  final MapController _mapController = MapController();

  late List<GameRound> _rounds;
  Timer? _timer;
  GamePhase _phase = GamePhase.reveal;

  int _roundIndex = 0;
  int _totalScore = 0;
  int _earnedXpThisGame = 0;
  int _levelUpsThisGame = 0;
  int _revealSeconds = 0;
  int _guessSeconds = 0;

  LatLng? _guessLocation;
  LatLng _guessMapCenter = LatLng(
    _ankaraCenter.latitude,
    _ankaraCenter.longitude,
  );
  double _guessMapZoom = _guessInitialZoom;
  double? _lastDistanceMeters;
  int _lastRoundScore = 0;

  GameRound get _currentRound => _rounds[_roundIndex];
  PlayerProgression get _progression => PlayerProgression.instance;
  int get _revealDurationSeconds => widget.difficulty.revealSeconds;
  int get _guessDurationSeconds => widget.difficulty.guessSeconds;

  @override
  void initState() {
    super.initState();
    _rounds = _buildRounds();
    _startRevealPhase();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRevealPhase() {
    _timer?.cancel();
    setState(() {
      _phase = GamePhase.reveal;
      _revealSeconds = _revealDurationSeconds;
      _guessLocation = null;
      _lastDistanceMeters = null;
      _lastRoundScore = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_revealSeconds <= 1) {
        timer.cancel();
        _startGuessPhase();
        return;
      }
      setState(() {
        _revealSeconds--;
      });
    });
  }

  List<GameRound> _buildRounds() {
    return _repository.pickRounds(
      count: _roundCount,
      playerLevel: _progression.level,
      radiusMultiplier: widget.difficulty.radiusMultiplier,
    );
  }

  void _startGuessPhase() {
    _timer?.cancel();
    setState(() {
      _phase = GamePhase.guess;
      _guessSeconds = _guessDurationSeconds;
      _guessMapCenter = LatLng(_ankaraCenter.latitude, _ankaraCenter.longitude);
      _guessMapZoom = _guessInitialZoom;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _phase != GamePhase.guess) {
        return;
      }
      _mapController.move(_guessMapCenter, _guessMapZoom);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_guessSeconds <= 1) {
        timer.cancel();
        _submitGuess();
        return;
      }
      setState(() {
        _guessSeconds--;
      });
    });
  }

  void _zoomGuessMap(double delta) {
    if (_phase != GamePhase.guess) {
      return;
    }
    final double nextZoom = (_guessMapZoom + delta).clamp(
      _guessMinZoom,
      _guessMaxZoom,
    );
    _mapController.move(_guessMapCenter, nextZoom);
  }

  void _submitGuess() {
    if (_phase != GamePhase.guess) {
      return;
    }

    _timer?.cancel();

    final LatLng? guessed = _guessLocation;
    if (guessed == null) {
      setState(() {
        _phase = GamePhase.result;
        _lastDistanceMeters = null;
        _lastRoundScore = 0;
      });
      return;
    }

    final GeoPoint guessedPoint = GeoPoint(
      latitude: guessed.latitude,
      longitude: guessed.longitude,
    );

    final double distanceMeters = ScoreCalculator.distanceMeters(
      _currentRound.location,
      guessedPoint,
    );
    final int score = ScoreCalculator.calculate(
      distanceMeters: distanceMeters,
      remainingSeconds: _guessSeconds,
      maxGuessSeconds: _guessDurationSeconds,
    );
    final int gainedXp = _calculateRoundXp(score);
    final int levelUps = _progression.addXp(gainedXp);

    setState(() {
      _phase = GamePhase.result;
      _lastDistanceMeters = distanceMeters;
      _lastRoundScore = score;
      _totalScore += score;
      _earnedXpThisGame += gainedXp;
      _levelUpsThisGame += levelUps;
    });

    if (levelUps > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seviye atladın! Yeni seviye: ${_progression.level}'),
        ),
      );
    }
  }

  int _calculateRoundXp(int roundScore) {
    final double rawXp = (roundScore / 10) * widget.difficulty.xpMultiplier;
    return rawXp.round().clamp(0, 9999).toInt();
  }

  void _nextRound() {
    if (_roundIndex >= _rounds.length - 1) {
      setState(() {
        _phase = GamePhase.finished;
      });
      return;
    }

    setState(() {
      _roundIndex++;
    });
    _startRevealPhase();
  }

  void _restartGame() {
    _timer?.cancel();
    setState(() {
      _rounds = _buildRounds();
      _roundIndex = 0;
      _totalScore = 0;
      _earnedXpThisGame = 0;
      _levelUpsThisGame = 0;
    });
    _startRevealPhase();
  }

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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 8),
                const LogoBadge(scale: 0.52),
                const SizedBox(height: 10),
                _buildRoundHeader(context),
                const SizedBox(height: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    child: switch (_phase) {
                      GamePhase.reveal => _buildRevealView(context),
                      GamePhase.guess => _buildGuessView(context),
                      GamePhase.result => _buildResultView(context),
                      GamePhase.finished => _buildFinishedView(context),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Tur ${_roundIndex + 1}/$_roundCount • ${widget.difficulty.label}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 19),
          ),
          Text(
            'Toplam: $_totalScore',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 19,
              color: AppPalette.cyanSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealView(BuildContext context) {
    return Column(
      key: const ValueKey<String>('reveal-view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '$_revealDurationSeconds saniye boyunca harita ipucunu ezberle',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 12),
        Text(
          widget.difficulty.showDistrict
              ? 'İlçe: ${_currentRound.district}'
              : 'İlçe: Gizli',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: AppPalette.cyanSoft.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _MapPreviewCard(
            center: LatLng(
              _currentRound.location.latitude,
              _currentRound.location.longitude,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _CountdownText(seconds: _revealSeconds),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildGuessView(BuildContext context) {
    final LatLng? selectedPoint = _guessLocation;

    return Column(
      key: const ValueKey<String>('guess-view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Konumunu haritada seç!',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontSize: 53, height: 1),
        ),
        const SizedBox(height: 8),
        Text(
          '$_guessDurationSeconds saniyede doğru noktayı işaretle.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: <Widget>[
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _guessMapCenter,
                    initialZoom: _guessMapZoom,
                    minZoom: _guessMinZoom,
                    maxZoom: _guessMaxZoom,
                    onMapEvent: (MapEvent event) {
                      _guessMapCenter = event.camera.center;
                      _guessMapZoom = event.camera.zoom;
                    },
                    onTap: (_, LatLng position) {
                      setState(() {
                        _guessLocation = position;
                      });
                    },
                  ),
                  children: <Widget>[
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const <String>['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.example.ankara_guess',
                    ),
                    MarkerLayer(
                      markers: <Marker>[
                        if (selectedPoint != null)
                          Marker(
                            point: selectedPoint,
                            width: 42,
                            height: 42,
                            child: const Icon(
                              Icons.location_on,
                              color: AppPalette.danger,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: <Widget>[
                      _MapControlButton(
                        icon: Icons.add,
                        onTap: () => _zoomGuessMap(1),
                      ),
                      const SizedBox(height: 8),
                      _MapControlButton(
                        icon: Icons.remove,
                        onTap: () => _zoomGuessMap(-1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          selectedPoint == null
              ? 'Haritada bir nokta seç ve tahmini gönder.'
              : 'Seçilen nokta: '
                    '${selectedPoint.latitude.toStringAsFixed(4)}, '
                    '${selectedPoint.longitude.toStringAsFixed(4)}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 12),
        _CountdownText(seconds: _guessSeconds),
        const SizedBox(height: 10),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _submitGuess,
            child: const Text('Tahmin Et', style: TextStyle(fontSize: 22)),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(BuildContext context) {
    final GeoPoint target = _currentRound.location;
    final LatLng targetLatLng = LatLng(target.latitude, target.longitude);
    final LatLng? guessedPoint = _guessLocation;
    final double? distanceMeters = _lastDistanceMeters;
    final List<Marker> markers = <Marker>[
      Marker(
        point: targetLatLng,
        width: 44,
        height: 44,
        child: const Icon(
          Icons.flag_rounded,
          color: AppPalette.success,
          size: 36,
        ),
      ),
      if (guessedPoint != null)
        Marker(
          point: guessedPoint,
          width: 44,
          height: 44,
          child: const Icon(
            Icons.location_on,
            color: AppPalette.danger,
            size: 38,
          ),
        ),
    ];

    return Column(
      key: const ValueKey<String>('result-view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          _guessLocation == null ? 'Tahmin yok' : 'Tur Sonucu',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontSize: 52),
        ),
        const SizedBox(height: 10),
        Text(
          guessedPoint == null || distanceMeters == null
              ? 'Bu turda işaret koymadığın için 0 puan.'
              : '${distanceMeters.toStringAsFixed(0)} m sapma • '
                    '$_lastRoundScore puan',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 21,
            color: AppPalette.cyanSoft,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: targetLatLng,
                initialZoom: 12.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: <Widget>[
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                  subdomains: const <String>['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.ankara_guess',
                ),
                if (guessedPoint != null)
                  PolylineLayer(
                    polylines: <Polyline>[
                      Polyline(
                        points: <LatLng>[targetLatLng, guessedPoint],
                        strokeWidth: 4,
                        color: AppPalette.cyan,
                      ),
                    ],
                  ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _nextRound,
            child: Text(
              _roundIndex == _roundCount - 1 ? 'Skoru Göster' : 'Sonraki Tur',
              style: const TextStyle(fontSize: 21),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFinishedView(BuildContext context) {
    final PlayerProgression progression = PlayerProgression.instance;

    return Column(
      key: const ValueKey<String>('finished-view'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Oyun Bitti',
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontSize: 64),
        ),
        const SizedBox(height: 18),
        Text(
          'Toplam Skor',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 6),
        Text(
          '$_totalScore',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 86,
            color: AppPalette.cyanSoft,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '+$_earnedXpThisGame XP • Seviye ${progression.level}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
        ),
        if (_levelUpsThisGame > 0) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            'Bu oyunda $_levelUpsThisGame seviye atladın.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: AppPalette.success,
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _restartGame,
            child: const Text('Tekrar Oyna', style: TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppPalette.cyanSoft),
              foregroundColor: AppPalette.cyanSoft,
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Ana Menü'),
          ),
        ),
      ],
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({required this.center});

  final LatLng center;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.cyan.withValues(alpha: 0.2),
            blurRadius: 22,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: <Widget>[
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const <String>['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.ankara_guess',
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownText extends StatefulWidget {
  const _CountdownText({required this.seconds});

  final int seconds;

  @override
  State<_CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<_CountdownText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isUrgent => widget.seconds <= 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _syncAnimationState();
  }

  @override
  void didUpdateWidget(covariant _CountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seconds != widget.seconds) {
      _syncAnimationState();
    }
  }

  void _syncAnimationState() {
    if (_isUrgent) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
      return;
    }
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.value = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle =
        Theme.of(
          context,
        ).textTheme.displaySmall?.copyWith(fontSize: 66, height: 1) ??
        const TextStyle(
          fontSize: 66,
          height: 1,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        );

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double wave = _isUrgent
            ? math.sin(_controller.value * 2 * math.pi)
            : 0;
        final double shakeX = _isUrgent ? wave * 8 : 0;
        final double scale = _isUrgent ? 1.0 + (0.05 * wave.abs()) : 1.0;
        final Color countdownColor = _isUrgent
            ? Color.lerp(AppPalette.danger, Colors.white, 0.22 * wave.abs()) ??
                  AppPalette.danger
            : AppPalette.textPrimary;
        final List<Shadow> shadows = _isUrgent
            ? <Shadow>[
                Shadow(
                  color: AppPalette.danger.withValues(alpha: 0.75),
                  blurRadius: 18,
                ),
              ]
            : const <Shadow>[];

        return Transform.translate(
          offset: Offset(shakeX, 0),
          child: Transform.scale(
            scale: scale,
            child: Text(
              '0:${widget.seconds.toString().padLeft(2, '0')}',
              textAlign: TextAlign.center,
              style: baseStyle.copyWith(
                color: countdownColor,
                shadows: shadows,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.navy.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: AppPalette.cyanSoft),
        ),
      ),
    );
  }
}
