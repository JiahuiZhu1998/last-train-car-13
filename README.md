# Last Train: Car 13

A supernatural mystery RPG set aboard a night train.

You wake up on a train. You cannot remember where it is going.
The other passengers cannot remember either.
Everyone warns you not to enter Car 13.

**Target playtime:** 15–30 minutes  
**Genre:** 2D pixel-art turn-based RPG

---

## Godot Version

Built with **Godot 4.7.1** (stable).

> Note: The upstream reference project (GDQuest Open RPG) documents Godot 4.6.2.
> Only Godot 4.7.1 was available on the development machine. All project files
> target 4.7. Do not open this project in Godot 4.6.

---

## How to Open / Run

1. Install [Godot 4.7.1](https://godotengine.org/download/)
2. Open Godot, click **Import**, and select `project.godot` in this folder
3. Press **F5** or click **Run Project**

The game starts in the Passenger Car. Use **WASD** or arrow keys to move.
Press **E** or **Enter** to interact.

---

## Controls

| Key | Action |
|-----|--------|
| WASD / Arrow keys | Move |
| E / Enter | Interact / Advance dialogue |

---

## Development Status

**Day 1 vertical slice** — all core systems scaffolded.

- [x] Player movement and collision
- [x] NPC interaction and dialogue
- [x] Enemy encounter triggers
- [x] Turn-based combat (Attack / Guard / Inspect)
- [x] Scene transitions between all 4 train locations
- [x] Game state singleton
- [x] Ending scene
- [ ] Pixel-art sprites (placeholder geometry only)
- [ ] Sound and music
- [ ] Save/load
- [ ] Game-over screen
- [ ] Title screen

---

## Reference Attribution

Architecturally informed by the
[GDQuest Godot Open RPG demo](https://github.com/gdquest-demos/godot-open-rpg) (MIT).
No upstream source files were copied. See [CREDITS.md](CREDITS.md) for details.
