import 'package:flutter_test/flutter_test.dart';

import 'package:digital_pet/pet_game.dart';

void main() {
  group('PetGame - Graduate Architecture Tests', () {
    test('starts with correct default values', () {
      final game = PetGame();

      expect(game.happiness, 50);
      expect(game.hunger, 50);
      expect(game.energy, 100);
    });

    test('feed updates hunger and happiness', () {
      final game = PetGame();

      game.feed();

      expect(game.hunger, 40);
      expect(game.happiness, 60);
    });

    test('feed applies low-hunger happiness penalty', () {
      final game = PetGame(happiness: 50, hunger: 20);

      game.feed();

      expect(game.hunger, 10);
      expect(game.happiness, 30);
    });

    test('play updates happiness and hunger', () {
      final game = PetGame();

      game.play();

      expect(game.happiness, 65);
      expect(game.hunger, 55);
    });

    test('meters are clamped to valid bounds', () {
      final game = PetGame(happiness: 95, hunger: 5, energy: 10);

      game.play();
      expect(game.happiness, 100);

      game.feed();
      expect(game.hunger, 0);

      game.run();
      expect(game.energy, 10);

      game.sleep();
      expect(game.energy, 40);
    });

    test('run updates state when enough energy is available', () {
      final game = PetGame();

      expect(game.canRun, isTrue);

      game.run();

      expect(game.energy, 80);
      expect(game.happiness, 70);
      expect(game.hunger, 60);
    });

    test('run is blocked when energy is insufficient', () {
      final game = PetGame(energy: 10);

      expect(game.canRun, isFalse);

      game.run();

      expect(game.energy, 10);
      expect(game.happiness, 50);
      expect(game.hunger, 50);
    });

    test('walk updates state when enough energy is available', () {
      final game = PetGame();

      expect(game.canWalk, isTrue);

      game.walk();

      expect(game.energy, 90);
      expect(game.happiness, 60);
      expect(game.hunger, 55);
    });

    test('walk is blocked when energy is insufficient', () {
      final game = PetGame(energy: 5);

      expect(game.canWalk, isFalse);

      game.walk();

      expect(game.energy, 5);
      expect(game.happiness, 50);
      expect(game.hunger, 50);
    });

    test('sleep restores energy and clamps it at 100', () {
      final game = PetGame(happiness: 50, hunger: 50, energy: 80);

      game.sleep();

      expect(game.energy, 100);
      expect(game.happiness, 55);
      expect(game.hunger, 55);
    });

    test('hunger tick updates hunger and recovers energy', () {
      final game = PetGame(happiness: 50, hunger: 50, energy: 80);

      game.hungerTick();

      expect(game.hunger, 55);
      expect(game.energy, 85);
      expect(game.happiness, 50);
    });

    test('hunger overflow applies happiness penalty', () {
      final game = PetGame(happiness: 50, hunger: 100, energy: 100);

      game.hungerTick();

      expect(game.hunger, 100);
      expect(game.happiness, 30);
      expect(game.energy, 100);
    });

    test('loss condition is detected correctly', () {
      final game = PetGame(happiness: 10, hunger: 100);

      expect(game.isLoss, isTrue);
    });

    test('loss condition is false when happiness is above 10', () {
      final game = PetGame(happiness: 11, hunger: 100);

      expect(game.isLoss, isFalse);
    });

    test('win threshold requires happiness strictly greater than 80', () {
      final gameAtBoundary = PetGame(happiness: 80);

      final gameAboveBoundary = PetGame(happiness: 81);

      expect(gameAtBoundary.isHappyEnough, isFalse);
      expect(gameAboveBoundary.isHappyEnough, isTrue);
    });

    test('reset restores all starting meter values', () {
      final game = PetGame(happiness: 90, hunger: 80, energy: 20);

      game.reset();

      expect(game.happiness, 50);
      expect(game.hunger, 50);
      expect(game.energy, 100);
    });
  });
}
