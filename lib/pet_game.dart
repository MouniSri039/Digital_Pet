class PetGame {
  int happiness;
  int hunger;
  int energy;

  PetGame({this.happiness = 50, this.hunger = 50, this.energy = 100});

  int clampMeter(int value) {
    return value.clamp(0, 100).toInt();
  }

  void feed() {
    hunger = clampMeter(hunger - 10);

    final happinessChange = hunger < 30 ? -20 : 10;
    happiness = clampMeter(happiness + happinessChange);
  }

  void play() {
    happiness = clampMeter(happiness + 15);
    hunger = clampMeter(hunger + 5);
  }

  bool get canRun => energy >= 20;

  bool get canWalk => energy >= 10;

  void run() {
    if (!canRun) return;

    energy = clampMeter(energy - 20);
    happiness = clampMeter(happiness + 20);
    hunger = clampMeter(hunger + 10);
  }

  void walk() {
    if (!canWalk) return;

    energy = clampMeter(energy - 10);
    happiness = clampMeter(happiness + 10);
    hunger = clampMeter(hunger + 5);
  }

  void sleep() {
    energy = clampMeter(energy + 30);
    happiness = clampMeter(happiness + 5);
    hunger = clampMeter(hunger + 5);
  }

  void hungerTick() {
    if (hunger + 5 > 100) {
      hunger = 100;
      happiness = clampMeter(happiness - 20);
    } else {
      hunger += 5;
    }

    energy = clampMeter(energy + 5);
  }

  void reset() {
    happiness = 50;
    hunger = 50;
    energy = 100;
  }

  bool get isLoss => hunger == 100 && happiness <= 10;

  bool get isHappyEnough => happiness > 80;
}
