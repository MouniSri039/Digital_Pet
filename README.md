# Digital Pet State Lab

A Flutter digital pet application developed for **In-Class Activity 07 – Digital Pet State Lab**.

The project was developed collaboratively using one shared GitHub repository with separate branches for team responsibilities and integration.

---

## Team Responsibilities

### Team 1 – Care Systems

Team 1 is responsible for the core care-system behavior, including:

- Feed, Play, and Reset actions
- Happiness and hunger state
- Bounded meter values
- Hunger progression
- Win-condition timing
- Game-over and win outcomes
- Care-system state tests

Branch:

`team-1/care-systems`

### Team 2 – Pet Personality

Team 2 is responsible for the pet's visual personality, interaction feedback, accessibility, and derived presentation behavior.

Implemented Team 2 features include:

- Derived pet mood based on happiness
- Derived pet speech based on game state
- Mood-based pet tint
- Mood-based pet scaling
- Animated happiness, hunger, and energy meters
- Feed and Play reaction feedback
- Pet bounce interaction animation
- Animated message transitions
- Reduced-motion support
- Semantic accessibility labels
- Transparent PNG pet asset
- `ColorFiltered` mood visualization
- Separated and independently testable personality logic

Branch:

`team-2/pet-personality`

---

## Graduate Pathway Features

The graduate pathway requires three advanced features in addition to the core Digital Pet behavior.

The combined project implements the following three advanced features:

### 1. Energy System

The pet includes an Energy meter with values constrained between `0` and `100`.

Energy affects whether certain activities can be performed.

Examples:

- Run costs 20 energy.
- Walk costs 10 energy.
- Sleep restores energy.
- Energy also recovers during periodic state updates.
- Energy is clamped so that it never goes below `0` or above `100`.

### 2. Activity Selection

The application provides an activity selector with:

- 🏃 Run
- 🚶 Walk
- 😴 Sleep

Each activity produces different state transitions.

| Activity | Energy | Happiness | Hunger |
| --- | ---: | ---: | ---: |
| Run | -20 | +20 | +10 |
| Walk | -10 | +10 | +5 |
| Sleep | +30 | +5 | +5 |

Run is blocked when the pet has less than 20 energy.

Walk is blocked when the pet has less than 10 energy.

All resulting meter values are clamped to the valid `0–100` range.

### 3. Visual Polish & Accessible Motion

The project implements multiple visual-feedback effects:

- Mood-based pet tint
- Mood-based pet scaling
- Animated meter transitions
- Feed reaction
- Play reaction
- Activity reaction feedback
- Pet bounce animation
- Animated pet messages
- Reduced-motion support

The visual-polish bundle counts as one advanced feature.

---

## Pet Mood Rules

The pet's mood is derived from its happiness value.

| Happiness | Mood |
| --- | --- |
| `< 30` | Unhappy |
| `30 – 70` | Neutral |
| `> 70` | Happy |

Boundary behavior is explicitly tested at:

- 29 → Unhappy
- 30 → Neutral
- 70 → Neutral
- 71 → Happy

The pet also changes size according to its mood:

- Unhappy → slightly smaller
- Neutral → normal size
- Happy → slightly larger

---

## Derived Pet Messages

Pet speech is derived from the current state rather than stored independently.

Examples include:

- Game over → `I need a rest.`
- Win → `Best day ever!`
- Low energy → `So sleepy...`
- Hunger above 80 → `I'm starving!`
- Happiness at or below 30 → `Play with me?`
- Normal state → greeting using the pet's name

---

## Core Care Behavior

### Feed

Feed decreases hunger by 10.

Normally, Feed increases happiness by 10. When feeding causes hunger to fall below 30, the low-hunger rule applies and happiness decreases by 20 instead.

All values remain within the `0–100` range.

### Play

Play:

- Increases happiness by 15
- Increases hunger by 5

Values are clamped to the valid meter range.

### Periodic State Update

A periodic timer updates the pet every 30 seconds.

The periodic update:

- Increases hunger by 5
- Restores energy by 5
- Applies the hunger-overflow happiness penalty when required

The timer is owned by the pet screen and is canceled during widget disposal.

### Reset

Reset restores the initial game state:

- Happiness → 50
- Hunger → 50
- Energy → 100
- Activity → None
- Game-over state → false
- Win state → false

---

## Win and Loss Conditions

### Loss Condition

The game enters the loss state when:

```text
Hunger == 100
AND
Happiness <= 10
```

### Win Condition

Happiness must be strictly greater than `80`.

The pet must remain above this threshold for three minutes to satisfy the win condition.

Exactly `80` happiness does not qualify.

---

## Interaction Feedback

The pet provides immediate visual feedback when the user interacts with it.

- Feed displays a temporary food reaction.
- Play displays a temporary play reaction.
- Run and Walk display activity reactions.
- Sleep displays a sleep reaction.
- Feed, Play, Run, and Walk can trigger pet movement feedback.
- Meter values animate when state changes.
- Mood transitions update the pet's tint and size.

Animations respect the device's reduced-motion preference.

---

## Accessibility

The interface includes accessibility support through Flutter semantics.

Examples include:

- Pet mood semantic description
- Happiness meter value description
- Hunger meter value description
- Energy meter value description
- Text labels in addition to visual mood feedback
- Reduced-motion support

Mood is therefore not communicated by color alone.

---

## Graduate Architecture

### PetGame Model

Game rules are separated from Flutter widget rendering through the `PetGame` model in:

```text
lib/pet_game.dart
```

`PetGame` owns:

- Happiness state
- Hunger state
- Energy state
- Meter clamping
- Feed state transitions
- Play state transitions
- Run rules
- Walk rules
- Sleep rules
- Periodic hunger/energy state transitions
- Reset behavior
- Win-threshold evaluation
- Loss-condition evaluation

The Flutter UI in `main.dart` owns:

- Widget rendering
- `setState()` calls
- User interaction
- Timer creation and lifecycle
- `mounted` checks
- Pet naming
- SnackBar feedback
- Visual reactions
- Animation behavior

This creates a clear ownership boundary between the application's game rules and its Flutter presentation layer.

---

## Architecture Design Decision and Trade-Off

We chose to keep timer creation and lifecycle management in the `StatefulWidget` while moving the game-state changes caused by each timer tick into `PetGame`.

This design keeps Flutter-specific lifecycle responsibilities such as `initState()`, `dispose()`, and `mounted` checks in the UI layer. At the same time, the actual meter transition rules remain independent of Flutter and can be unit tested directly.

The trade-off is that `main.dart` still coordinates when the game rules are executed, so the model and UI are not completely independent. For a small single-screen application, this keeps the architecture simple while providing clearer separation of responsibilities and significantly better testability.

---

## Automated Testing

The project includes automated tests for both UI behavior and independent game logic.

Testing covers:

- Initial state
- Feed transitions
- Play transitions
- Run transitions
- Walk transitions
- Sleep transitions
- Energy requirements
- Meter clamping
- Hunger progression
- Energy recovery
- Low-hunger behavior
- Hunger-overflow penalty
- Win threshold
- Loss condition
- Reset behavior
- Pet naming
- Mood boundaries
- Personality messages
- Accessibility semantics
- Widget interaction

The `PetGame` model is tested independently in:

```text
test/pet_game_test.dart
```

Personality behavior is tested in:

```text
test/pet_personality_test.dart
```

Widget and integration behavior is covered by the remaining Flutter widget test files.

### Latest Verification

```bash
flutter analyze
flutter test
```

Latest results:

```text
flutter analyze
No issues found!

flutter test
All tests passed!
```

---

## Project Structure

```text
lib/
├── main.dart
├── pet_game.dart
└── pet_personality.dart

test/
├── digital_pet_test.dart
├── pet_game_test.dart
├── pet_personality_test.dart
└── widget_test.dart

assets/
└── images/
    └── pet.png
```

---

## Setup and Run

Clone the repository:

```bash
git clone https://github.com/MouniSri039/Digital_Pet.git
cd Digital_Pet
```

Install dependencies:

```bash
flutter pub get
```

Check the project:

```bash
flutter analyze
```

Run all automated tests:

```bash
flutter test
```

Run the application:

```bash
flutter run
```

---

## Build Release APK

Build the Android release APK with:

```bash
flutter build apk --release
```

The generated APK can be found at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For the course submission, the final shared APK should be renamed according to the required format:

```text
DigitalPet_TeamName.apk
```

The release APK should be installed and launched successfully before submission.

---

## Feature-to-Outcome Rubric Map

| Requirement / Outcome | Implementation Evidence |
| --- | --- |
| Stateful pet care | Feed, Play, Reset, happiness, hunger, and periodic updates |
| Bounded state | `PetGame` clamps meter values to `0–100` |
| Mood behavior | `PetPersonality` derives mood from happiness |
| Visual feedback | Tint, scaling, reactions, animated meters, and messages |
| Accessibility | Semantic meter/pet labels and reduced-motion support |
| Energy System | Energy meter, activity costs, recovery, and clamping |
| Activity Selection | Run, Walk, and Sleep activity selector |
| Graduate architecture | Game rules separated into `PetGame` |
| State-transition testing | `pet_game_test.dart` and widget tests |
| Win behavior | Happiness above 80 maintained for three minutes |
| Loss behavior | Hunger 100 and happiness at or below 10 |
| Reset behavior | Restores initial game state |
| Lifecycle safety | Timers canceled in `dispose()` and guarded by `mounted` |
| Team collaboration | Separate team branches, integration, commits, and pull requests |

---

## Screenshots

Add final screenshots of the combined application here before submission.

Recommended evidence:

1. Initial Digital Pet screen
2. Happy mood state
3. Energy meter and activity selector
4. Run or Walk activity
5. Sleep activity
6. Low-energy or activity-blocked state
7. Test output showing all automated tests passing

---

## Pull Requests and Issues

Add the final GitHub issue and pull-request links used for team collaboration and graduate review evidence here.

### Pull Requests

- Team 1 Care Systems: `[add PR link]`
- Team 2 Pet Personality: `[add PR link]`
- Team 1 + Team 2 Integration: `https://github.com/MouniSri039/Digital_Pet/pull/3`
- Graduate Energy / Activity / Architecture: `[add PR link]`

### Graduate Review Evidence

- Reviewed teammate PR: `[add reviewed PR link]`

---

## Asset License

The pet image is stored at:

```text
assets/images/pet.png
```

Source:

```text
Twitter Twemoji / jdecked Twemoji project
```

The asset is based on the Twemoji cat image.

License:

```text
CC-BY 4.0
```

The asset is used for educational purposes in this course project.

---

## Repository Hygiene

The repository contains:

- Flutter source code
- Required project configuration
- Automated tests
- Necessary image assets
- README documentation

Generated build folders and local development artifacts should not be committed.

The release APK is submitted separately through iCollege unless otherwise requested by the instructor.

---

## Submission

Each student must individually submit the complete required package to the labeled iCollege folder.

Required files:

1. `github_link.txt`
   - Contains the URL of the single combined GitHub repository.

2. `DigitalPet_TeamName.apk`
   - Shared final release APK.
   - Built after all team work is merged.
   - Installed and launched before submission.

3. `YourName_CriticalThinking.docx`
   - Individual reflection.
   - Contains the student's name and ID.
   - Contains answers to all 10 required reflection questions.

Before submission, each student should verify that all three files appear in iCollege, the GitHub repository is accessible to the instructor, and the submitted APK launches successfully.