# Game Scope — Last Train: Car 13

**Locked scope for the one-week vertical slice.**  
Do not add features outside this document without explicit scope change.

---

## Title
Last Train: Car 13

## Genre
2D pixel-art supernatural mystery RPG — exploration, dialogue, turn-based combat.

## Target Playtime
15–30 minutes (single playthrough).

## Endings
**One ending only.** No branching.

---

## Playable Locations

| Scene | File | Status |
|-------|------|--------|
| Passenger Car | `scenes/train/passenger_car.tscn` | Day 1 ✓ |
| Dining Car | `scenes/train/dining_car.tscn` | Day 1 ✓ |
| Car 13 | `scenes/train/car_13.tscn` | Day 1 ✓ |
| Engine / Driver Cabin | `scenes/ending/engine_cabin.tscn` | Day 1 ✓ |

---

## Enemies

| ID | Name | Notes |
|----|------|-------|
| `shadow_passenger` | Shadow Passenger | Standard encounter, Passenger Car |
| `crawling_thing` | Crawling Thing | Standard encounter, Dining Car |
| `the_conductor` | The Conductor | Final boss, Car 13 |

---

## Combat Actions

- **Attack** — deal damage
- **Guard** — halve incoming damage this turn
- **Inspect** — reveal lore text about the enemy

No other combat actions are in scope.

---

## NPCs

- **Passenger** (Passenger Car) — warns about Car 13
- **Diner Guest** (Dining Car) — hints at the accident

Approximately 2 NPCs. No more are needed.

---

## Key Items / State Flags

| Flag | Meaning |
|------|---------|
| `has_car13_key` | Player obtained the key to Car 13 |
| `found_accident_clue` | Player found the accident evidence |
| `car13_unlocked` | Car 13 door is open |
| `conductor_defeated` | Boss fight completed |
| `ending_unlocked` | Engine cabin is accessible |

---

## Core Progression

```
Wake up in Passenger Car
→ Explore, interact with NPC
→ (Obtain key from Passenger Car — Day 2)
→ Enter Dining Car
→ Combat encounter: Crawling Thing
→ Find accident clue
→ Enter Car 13 (requires key)
→ Boss fight: The Conductor
→ Enter Engine Cabin
→ Ending
```

---

## Out of Scope (Hard Lock)

- Multiple endings
- Branching dialogue
- Crafting
- Skill trees
- Party system
- Inventory beyond one key
- Procedural generation
- Multiplayer
- Open world
- Save / load (Day 2 or later)
- Title screen (Day 2)
- Game-over screen (Day 2)
- Sound / music (Day 2)
- Real pixel-art sprites (Day 2+)
- Quest system of any kind
- Relationship system
- Sanity system
- Level-up system
