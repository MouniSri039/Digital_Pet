import 'dart:async';

import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
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
  // -----------------------------
  // Team 1: Care Mechanics & State
  // -----------------------------

  String _petName = 'My Pet';

  int _happiness = 50;
  int _hunger = 50;

  bool _gameOver = false;
  bool _hasWon = false;

  Timer? _hungerTimer;
  Timer? _highMoodTimer;

  final TextEditingController _nameController = TextEditingController();

  int _clampMeter(int value) {
    return value.clamp(0, 100).toInt();
  }

  String get _moodLabel {
    if (_happiness > 70) {
      return 'Happy';
    } else if (_happiness >= 30) {
      return 'Neutral';
    } else {
      return 'Unhappy';
    }
  }

  void _feedPet() {
    if (_gameOver || _hasWon) return;

    final nextHunger = _clampMeter(_hunger - 10);
    final happinessChange = nextHunger < 30 ? -20 : 10;
    final nextHappiness =
        _clampMeter(_happiness + happinessChange);

    setState(() {
      _hunger = nextHunger;
      _happiness = nextHappiness;
    });

    _updateOutcome();

    _showMessage('You fed $_petName!');
  }

  void _playWithPet() {
    if (_gameOver || _hasWon) return;

    final nextHappiness = _clampMeter(_happiness + 15);
    final nextHunger = _clampMeter(_hunger + 5);

    setState(() {
      _happiness = nextHappiness;
      _hunger = nextHunger;
    });

    _updateOutcome();

    _showMessage('You played with $_petName!');
  }

  void _resetPet() {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    _hungerTimer?.cancel();

    setState(() {
      _petName = 'My Pet';
      _happiness = 50;
      _hunger = 50;
      _gameOver = false;
      _hasWon = false;
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

    // Loss condition:
    // hunger == 100 AND happiness <= 10
    if (_hunger == 100 && _happiness <= 10) {
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

    // Happiness must be strictly greater than 80.
    // Exactly 80 does NOT qualify.
    if (_happiness <= 80) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    // Start the three-minute win timer only once.
    _highMoodTimer ??= Timer(const Duration(minutes: 3), () {
      _highMoodTimer = null;

      if (!mounted || _gameOver || _happiness <= 80) {
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
    // Make sure exactly one hunger timer exists.
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (!mounted || _gameOver || _hasWon) {
          timer.cancel();
          return;
        }

        setState(() {
          if (_hunger + 5 > 100) {
            _hunger = 100;
            _happiness = _clampMeter(_happiness - 20);
          } else {
            _hunger += 5;
          }
        });

        _updateOutcome();
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
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
    _nameController.dispose();
    super.dispose();
  }

  Color get _moodColor {
    if (_happiness > 70) {
      return Colors.green;
    } else if (_happiness >= 30) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final careDisabled = _gameOver || _hasWon;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Text(
                _petName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 8),

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

              const SizedBox(height: 25),

              // Temporary pet visual.
              // Team 2 can replace/enhance this during integration.
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _moodColor.withValues(alpha: 0.25),
                  BlendMode.modulate,
                ),
                child: const Text(
                  '🐶',
                  style: TextStyle(fontSize: 110),
                ),
              ),

              const SizedBox(height: 25),

              _buildMeter(
                label: 'Happiness',
                value: _happiness,
                color: _moodColor,
              ),

              const SizedBox(height: 18),

              _buildMeter(
                label: 'Hunger',
                value: _hunger,
                color: Colors.orange,
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
                    child: ElevatedButton.icon(
                      onPressed: careDisabled ? null : _feedPet,
                      icon: const Icon(Icons.restaurant),
                      label: const Text('Feed'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: careDisabled ? null : _playWithPet,
                      icon: const Icon(Icons.sports_esports),
                      label: const Text('Play'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

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

  Widget _buildMeter({
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('$value / 100'),
          ],
        ),
        const SizedBox(height: 6),
        Semantics(
          label: '$label $value out of 100',
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}