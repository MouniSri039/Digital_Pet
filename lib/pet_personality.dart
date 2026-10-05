import 'package:flutter/material.dart';

enum PetMood { unhappy, neutral, happy }

class PetPersonality {
  const PetPersonality._();

  static PetMood moodFor(int happiness) {
    if (happiness < 30) {
      return PetMood.unhappy;
    }

    if (happiness > 70) {
      return PetMood.happy;
    }

    return PetMood.neutral;
  }

  static String moodLabel(int happiness) {
    switch (moodFor(happiness)) {
      case PetMood.unhappy:
        return 'Unhappy';
      case PetMood.neutral:
        return 'Neutral';
      case PetMood.happy:
        return 'Happy';
    }
  }

  static Color moodColor(int happiness) {
    switch (moodFor(happiness)) {
      case PetMood.unhappy:
        return Colors.red;
      case PetMood.neutral:
        return Colors.amber;
      case PetMood.happy:
        return Colors.green;
    }
  }

  static double moodScale(int happiness) {
    switch (moodFor(happiness)) {
      case PetMood.unhappy:
        return 0.94;
      case PetMood.neutral:
        return 1.0;
      case PetMood.happy:
        return 1.06;
    }
  }

  static String message({
    required String petName,
    required int happiness,
    required int hunger,
    required bool gameOver,
    required bool hasWon,
  }) {
    if (gameOver) {
      return 'I need a rest.';
    }

    if (hasWon) {
      return 'Best day ever!';
    }

    if (hunger > 80) {
      return "I'm starving!";
    }

    if (happiness <= 30) {
      return 'Play with me?';
    }

    return "Hi, I'm $petName!";
  }
}
