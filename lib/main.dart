import 'dart:async';

import 'package:flutter/material.dart';

import 'pet_personality.dart';

void main() {
  runApp(const DigitalPetApp());
}

class DigitalPetApp extends StatelessWidget {
  const DigitalPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Pet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const PetPersonalityScreen(),
    );
  }
}

class PetPersonalityScreen extends StatefulWidget {
  const PetPersonalityScreen({super.key});

  @override
  State<PetPersonalityScreen> createState() => _PetPersonalityScreenState();
}

class _PetPersonalityScreenState extends State<PetPersonalityScreen> {
  // Temporary demonstration state for Team 2.
  // Team 1 will provide the final shared care-system state after integration.
  String _petName = 'Pip';
  int _happiness = 50;
  int _hunger = 50;

  bool _gameOver = false;
  bool _hasWon = false;

  double _actionScale = 1.0;
  String? _reaction;

  Timer? _reactionTimer;
  Timer? _bounceTimer;

  String get _moodLabel {
    return PetPersonality.moodLabel(_happiness);
  }

  Color get _moodColor {
    return PetPersonality.moodColor(_happiness);
  }

  double get _moodScale {
    return PetPersonality.moodScale(_happiness);
  }

  String get _petMessage {
    return PetPersonality.message(
      petName: _petName,
      happiness: _happiness,
      hunger: _hunger,
      gameOver: _gameOver,
      hasWon: _hasWon,
    );
  }

  void _showReaction(String reaction) {
    _reactionTimer?.cancel();

    setState(() {
      _reaction = reaction;
    });

    _reactionTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _reaction = null;
      });
    });
  }

  void _bouncePet() {
    _bounceTimer?.cancel();

    setState(() {
      _actionScale = 1.08;
    });

    _bounceTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _actionScale = 1.0;
      });
    });
  }

  void _demoFeed() {
    setState(() {
      _hunger = (_hunger - 10).clamp(0, 100);
    });

    _showReaction('🍖');
    _bouncePet();
  }

  void _demoPlay() {
    setState(() {
      _happiness = (_happiness + 10).clamp(0, 100);
    });

    _showReaction('🎾');
    _bouncePet();
  }

  void _demoReset() {
    _reactionTimer?.cancel();
    _bounceTimer?.cancel();

    setState(() {
      _petName = 'Pip';
      _happiness = 50;
      _hunger = 50;
      _gameOver = false;
      _hasWon = false;
      _reaction = null;
      _actionScale = 1.0;
    });
  }

  @override
  void dispose() {
    _reactionTimer?.cancel();
    _bounceTimer?.cancel();
    super.dispose();
  }

  Widget _buildMeter({
    required String label,
    required int value,
    required IconData icon,
    required bool reduceMotion,
  }) {
    return Semantics(
      label: '$label $value out of 100',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                '$label: $value',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value / 100),
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, animatedValue, child) {
              return LinearProgressIndicator(
                value: animatedValue,
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    final double finalPetScale = reduceMotion
        ? _moodScale
        : _moodScale * _actionScale;

    return Scaffold(
      appBar: AppBar(title: const Text('Digital Pet'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                _petName,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                child: Text(
                  _petMessage,
                  key: ValueKey(_petMessage),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 28),

              // Licensed transparent PNG pet asset.
              SizedBox(
                height: 210,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedScale(
                      scale: finalPetScale,
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      curve: Curves.easeOutBack,
                      child: Semantics(
                        label: '$_petName is currently $_moodLabel',
                        image: true,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            _moodColor,
                            BlendMode.modulate,
                          ),
                          child: Image.asset(
                            'assets/images/pet.png',
                            width: 165,
                            height: 165,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      ),
                    ),
                    if (_reaction != null)
                      Positioned(
                        top: 5,
                        right: 60,
                        child: AnimatedOpacity(
                          opacity: _reaction == null ? 0 : 1,
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 200),
                          child: Text(
                            _reaction!,
                            style: const TextStyle(fontSize: 38),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _moodColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mood, color: _moodColor),
                    const SizedBox(width: 8),
                    Text(
                      'Mood: $_moodLabel',
                      style: TextStyle(
                        color: _moodColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildMeter(
                label: 'Happiness',
                value: _happiness,
                icon: Icons.favorite,
                reduceMotion: reduceMotion,
              ),
              const SizedBox(height: 24),
              _buildMeter(
                label: 'Hunger',
                value: _hunger,
                icon: Icons.restaurant,
                reduceMotion: reduceMotion,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _gameOver || _hasWon ? null : _demoFeed,
                      icon: const Icon(Icons.restaurant),
                      label: const Text('Feed'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _gameOver || _hasWon ? null : _demoPlay,
                      icon: const Icon(Icons.sports_tennis),
                      label: const Text('Play'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _demoReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Demo'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Team 2 • Pet Personality',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
