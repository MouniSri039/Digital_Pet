# Digital Pet State Lab

A Flutter digital pet application developed for **In-Class Activity 07 – Digital Pet State Lab**.

The project is developed collaboratively using one shared GitHub repository with separate branches for each team's responsibilities.

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
- Animated happiness and hunger meters
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

## Derived Pet Messages

Pet speech is derived from the current state rather than stored independently.

Examples include:

- Game over → `I need a rest.`
- Win → `Best day ever!`
- Hunger above 80 → `I'm starving!`
- Happiness at or below 30 → `Play with me?`
- Normal state → greeting using the pet's name

## Interaction Feedback

The pet provides immediate visual feedback when the user interacts with it.

- Feed displays a temporary food reaction.
- Play displays a temporary play reaction.
- Feed and Play trigger a short pet bounce.
- Happiness and hunger meters animate when their values change.
- Mood transitions update the pet's tint and size.

Animations respect the device's reduced-motion preference.

## Accessibility

The Team 2 interface includes accessibility support through Flutter semantics.

Examples include:

- Pet mood semantic description
- Happiness meter value description
- Hunger meter value description
- Reduced-motion support
- Text labels in addition to visual mood feedback

Mood is therefore not communicated by color alone.

## Project Structure

```text
lib/
├── main.dart
└── pet_personality.dart

test/
├── pet_personality_test.dart
└── widget_test.dart

assets/
└── images/
    └── pet.png