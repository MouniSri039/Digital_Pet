import 'dart:async';

import 'package:flutter/material.dart';

import 'pet_game.dart';
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
      home: const DigitalPetHome(),
    );
  }
}

class DigitalPetHome extends StatefulWidget {
  const DigitalPetHome({super.key});

  @override
  State<DigitalPetHome> createState() => _DigitalPetHomeState();
}

class _DigitalPetHomeState extends State<DigitalPetHome> {
  String _petName = 'My Pet';

  // Graduate architecture:
  // PetGame owns mutable game meters and game-rule transitions.
  // This widget owns rendering, timers, controllers, and visual feedback.
  final PetGame _petGame = PetGame();

  String _selectedActivity = 'None';

  bool _gameOver = false;
  bool _hasWon = false;

  Timer? _hungerTimer;
  Timer? _highMoodTimer;

  final TextEditingController _nameController = TextEditingController();

  // Team 2: Personality & Feedback
  double _actionScale = 1.0;
  String? _reaction;

  Timer? _reactionTimer;
  Timer? _bounceTimer;

  String get _moodLabel {
    return PetPersonality.moodLabel(_petGame.happiness);
  }

  Color get _moodColor {
    return PetPersonality.moodColor(_petGame.happiness);
  }

  double get _moodScale {
    return PetPersonality.moodScale(_petGame.happiness);
  }

  String get _petMessage {
    if (_gameOver) {
      return 'I need a rest.';
    }

    if (_hasWon) {
      return 'Best day ever!';
    }

    if (_petGame.energy < 20) {
      return 'So sleepy...';
    }

    return PetPersonality.message(
      petName: _petName,
      happiness: _petGame.happiness,
      hunger: _petGame.hunger,
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

  void _feedPet() {
    if (_gameOver || _hasWon) return;

    setState(() {
      _petGame.feed();
    });

    _showReaction('🍖');
    _bouncePet();

    _updateOutcome();

    _showMessage('You fed $_petName!');
  }

  void _playWithPet() {
    if (_gameOver || _hasWon) return;

    setState(() {
      _petGame.play();
    });

    _showReaction('🎾');
    _bouncePet();

    _updateOutcome();

    _showMessage('You played with $_petName!');
  }

  void _runActivity(String activity) {
    if (_gameOver || _hasWon) return;

    if (activity == 'Run') {
      if (!_petGame.canRun) {
        _showMessage('Not enough energy to run.');
        return;
      }

      setState(() {
        _selectedActivity = activity;
        _petGame.run();
      });

      _showReaction('🏃');
      _bouncePet();
    } else if (activity == 'Walk') {
      if (!_petGame.canWalk) {
        _showMessage('Not enough energy to walk.');
        return;
      }

      setState(() {
        _selectedActivity = activity;
        _petGame.walk();
      });

      _showReaction('🚶');
      _bouncePet();
    } else if (activity == 'Sleep') {
      setState(() {
        _selectedActivity = activity;
        _petGame.sleep();
      });

      _showReaction('💤');
    }

    _updateOutcome();

    _showMessage('$activity selected!');
  }

  void _resetPet() {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    _hungerTimer?.cancel();

    _reactionTimer?.cancel();
    _bounceTimer?.cancel();

    setState(() {
      _petName = 'My Pet';

      _petGame.reset();

      _selectedActivity = 'None';

      _gameOver = false;
      _hasWon = false;

      _reaction = null;
      _actionScale = 1.0;

      _nameController.clear();
    });

    _startHungerTimer();

    _showMessage('Pet reset!');
  }

  void _confirmName() {
    final enteredName = _nameController.text.trim();

    if (enteredName.isEmpty) {
      _showMessage('Please enter a pet name.');
      return;
    }

    setState(() {
      _petName = enteredName;
    });

    _nameController.clear();

    _showMessage('Pet named $_petName!');
  }

  void _updateOutcome() {
    if (_gameOver || _hasWon) return;

    if (_petGame.isLoss) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;

      _hungerTimer?.cancel();
      _hungerTimer = null;

      setState(() {
        _gameOver = true;
      });

      _showMessage('Game over! $_petName needs a restart.');
      return;
    }

    if (!_petGame.isHappyEnough) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    _highMoodTimer ??= Timer(const Duration(minutes: 3), () {
      _highMoodTimer = null;

      if (!mounted || _gameOver || !_petGame.isHappyEnough) {
        return;
      }

      setState(() {
        _hasWon = true;
      });

      _hungerTimer?.cancel();
      _hungerTimer = null;

      _showMessage('You won! $_petName stayed happy for 3 minutes.');
    });
  }

  void _startHungerTimer() {
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted || _gameOver || _hasWon) {
        timer.cancel();
        return;
      }

      setState(() {
        _petGame.hungerTick();
      });

      _updateOutcome();
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();

    _reactionTimer?.cancel();
    _bounceTimer?.cancel();

    _nameController.dispose();

    super.dispose();
  }

  Widget _buildMeter({
    required String label,
    required int value,
    required IconData icon,
    required bool reduceMotion,
  }) {
    Color meterColor;

    if (label == 'Happiness') {
      meterColor = _moodColor;
    } else if (label == 'Energy') {
      meterColor = Colors.blue;
    } else {
      meterColor = Colors.orange;
    }

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
                color: meterColor,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final careDisabled = _gameOver || _hasWon;

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

              const SizedBox(height: 16),

              Text(
                _hasWon
                    ? '🏆 You Won!'
                    : _gameOver
                    ? '💔 Game Over'
                    : _moodLabel,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _moodColor,
                ),
              ),

              const SizedBox(height: 20),

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
                value: _petGame.happiness,
                icon: Icons.favorite,
                reduceMotion: reduceMotion,
              ),

              const SizedBox(height: 24),

              _buildMeter(
                label: 'Hunger',
                value: _petGame.hunger,
                icon: Icons.restaurant,
                reduceMotion: reduceMotion,
              ),

              const SizedBox(height: 24),

              _buildMeter(
                label: 'Energy',
                value: _petGame.energy,
                icon: Icons.bolt,
                reduceMotion: reduceMotion,
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _nameController,
                enabled: !careDisabled,
                decoration: const InputDecoration(
                  labelText: 'Pet name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: careDisabled ? null : _confirmName,
                  child: const Text('Confirm Name'),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: careDisabled ? null : _feedPet,
                      icon: const Icon(Icons.restaurant),
                      label: const Text('Feed'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: careDisabled ? null : _playWithPet,
                      icon: const Icon(Icons.sports_tennis),
                      label: const Text('Play'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose an Activity',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: _selectedActivity == 'None'
                    ? null
                    : _selectedActivity,
                decoration: const InputDecoration(
                  labelText: 'Activity',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_run),
                ),
                items: const [
                  DropdownMenuItem(value: 'Run', child: Text('🏃 Run')),
                  DropdownMenuItem(value: 'Walk', child: Text('🚶 Walk')),
                  DropdownMenuItem(value: 'Sleep', child: Text('😴 Sleep')),
                ],
                onChanged: careDisabled
                    ? null
                    : (activity) {
                        if (activity != null) {
                          _runActivity(activity);
                        }
                      },
              ),

              const SizedBox(height: 12),

              if (_selectedActivity != 'None')
                Text(
                  'Current Activity: $_selectedActivity',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _resetPet,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ),

              const SizedBox(height: 20),

              if (_gameOver)
                const Text(
                  'Care actions are disabled. Press Reset to restart.',
                  textAlign: TextAlign.center,
                ),

              if (_hasWon)
                const Text(
                  'You kept your pet happy! Press Reset to play again.',
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
