import 'package:flutter_test/flutter_test.dart';

import 'package:digital_pet/pet_personality.dart';

void main() {
  group('Pet Personality mood boundaries', () {
    test('29 happiness is Unhappy', () {
      expect(PetPersonality.moodFor(29), PetMood.unhappy);

      expect(PetPersonality.moodLabel(29), 'Unhappy');
    });

    test('30 happiness is Neutral', () {
      expect(PetPersonality.moodFor(30), PetMood.neutral);

      expect(PetPersonality.moodLabel(30), 'Neutral');
    });

    test('70 happiness is Neutral', () {
      expect(PetPersonality.moodFor(70), PetMood.neutral);

      expect(PetPersonality.moodLabel(70), 'Neutral');
    });

    test('71 happiness is Happy', () {
      expect(PetPersonality.moodFor(71), PetMood.happy);

      expect(PetPersonality.moodLabel(71), 'Happy');
    });
  });

  group('Pet Personality derived messages', () {
    test('game over message has highest priority', () {
      expect(
        PetPersonality.message(
          petName: 'Pip',
          happiness: 90,
          hunger: 90,
          gameOver: true,
          hasWon: false,
        ),
        'I need a rest.',
      );
    });

    test('win message is shown when the pet has won', () {
      expect(
        PetPersonality.message(
          petName: 'Pip',
          happiness: 90,
          hunger: 20,
          gameOver: false,
          hasWon: true,
        ),
        'Best day ever!',
      );
    });

    test('high hunger produces starving message', () {
      expect(
        PetPersonality.message(
          petName: 'Pip',
          happiness: 50,
          hunger: 81,
          gameOver: false,
          hasWon: false,
        ),
        "I'm starving!",
      );
    });

    test('low happiness asks the user to play', () {
      expect(
        PetPersonality.message(
          petName: 'Pip',
          happiness: 30,
          hunger: 50,
          gameOver: false,
          hasWon: false,
        ),
        'Play with me?',
      );
    });

    test('normal state greets the user with the pet name', () {
      expect(
        PetPersonality.message(
          petName: 'Pip',
          happiness: 50,
          hunger: 50,
          gameOver: false,
          hasWon: false,
        ),
        "Hi, I'm Pip!",
      );
    });
  });

  group('Pet Personality visual feedback', () {
    test('unhappy pet is smaller than neutral pet', () {
      expect(
        PetPersonality.moodScale(29),
        lessThan(PetPersonality.moodScale(30)),
      );
    });

    test('happy pet is larger than neutral pet', () {
      expect(
        PetPersonality.moodScale(71),
        greaterThan(PetPersonality.moodScale(70)),
      );
    });
  });
}
