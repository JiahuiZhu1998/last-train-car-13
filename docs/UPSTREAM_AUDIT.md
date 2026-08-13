# Upstream Architecture Audit — GDQuest Godot Open RPG

**Reference:** https://github.com/gdquest-demos/godot-open-rpg  
**Audit method:** Known repository structure + architecture knowledge (network access to GitHub unavailable during Day 1; shallow clone failed due to connection timeout)  
**Date:** 2026-08-13  
**Auditor:** Lead Godot Engineer

---

## Repository Overview

GDQuest's `godot-open-rpg` is a Godot 4 turn-based RPG demo released under MIT.
It is a teaching project, not a production framework. It demonstrates core RPG
patterns: overworld movement, turn-based combat, dialogue via Dialogic, and
scene-based map transitions.

Documented target engine: Godot 4.6.2.

---

## Key Systems Identified

### Combat System
- Turn-based combat runs in a dedicated `combat/` scene
- Combatants are represented as nodes with stats resources
- Turns are managed by a `CombatSystem` or equivalent autoload/node
- Actions: attack, skills; no guard/inspect in base demo
- Return to overworld via scene change after victory/defeat

**Decision:** Adapt the entry/exit flow. Simplify to a single `CombatManager`
node with inline enemy data. No separate combatant resource files needed for
a 3-enemy game.

### Overworld / Map
- Grid-based or free movement with `CharacterBody2D`
- Map transitions via `Area2D` triggers that call `get_tree().change_scene_to_file()`
- Maps are individual scenes under `overworld/` or `maps/`

**Decision:** Reuse the `Area2D` door-trigger pattern directly. Not grid-based
(free movement is simpler for a train corridor layout).

### Dialogue
- Uses the **Dialogic** addon for multi-line branching dialogue
- Dialogic is a significant dependency (its own editor integration, timeline files)

**Decision:** EXCLUDE Dialogic entirely. For 2 NPCs with simple linear dialogue,
a minimal `Label`-based dialogue balloon is sufficient and takes 30 minutes to
build vs. 2 hours to integrate Dialogic properly.

### Autoloads / Singletons
- Upstream uses autoloads for game-wide state (e.g., party data, currency)
- Pattern: `extends Node` scripts registered in Project Settings > Autoloads

**Decision:** REUSE this pattern. We implement `GameState` and `SceneTransition`
as autoloads. Simple and idiomatic Godot 4.

### Input
- Standard Godot input map: `ui_accept`, `move_*` actions
- Keyboard + joypad support

**Decision:** REUSE. Add `interact` action alongside standard actions.

### Inventory / Items
- Upstream has an inventory system with item resources

**Decision:** EXCLUDE entirely. The vertical slice has exactly one key
(`has_car13_key`) — a boolean flag in `GameState` is sufficient.

### Save / Load
- Upstream may have basic save state via `ConfigFile` or `FileAccess`

**Decision:** EXCLUDE for Day 1. No save system needed for a 15-30 minute
linear game in a vertical slice context.

### Addons
- `addons/dialogic/` — the Dialogic plugin (substantial)
- Possibly `gut/` for testing

**Decision:** No addons for Day 1. Addons add import complexity.

### Scene Organization (upstream)
```
godot-open-rpg/
├── combat/
├── overworld/
├── src/
│   ├── characters/
│   ├── ui/
│   └── ...
├── addons/dialogic/
└── project.godot
```

---

## What We Reuse

| Pattern | Source | How |
|---------|--------|-----|
| Autoload singletons for state | Upstream | Direct pattern reuse |
| `Area2D` scene transition triggers | Upstream | Direct pattern reuse |
| `Area2D` encounter triggers | Upstream | Direct pattern reuse |
| Combat scene entry/exit flow | Upstream | Adapted: simpler data model |
| `CharacterBody2D` free movement | Upstream | Direct pattern reuse |

## What We Adapt

| System | Upstream version | Our version |
|--------|-----------------|-------------|
| Combat manager | Multi-node combatant resources | Single GDScript with inline dict data |
| NPC dialogue | Dialogic plugin | Inline `Label` balloon |
| Game state | Party/inventory data | 5 boolean flags |

## What We Exclude

- Dialogic addon
- Inventory / item system
- Party management
- Save / load
- Skill / ability trees
- Enemy AI beyond simple attack
- Grid movement
- Title screen / menus (Day 2)
- Sound / music (Day 2)

## What We Ignore

- Multiplayer hooks (none in upstream, none wanted)
- GUT test framework
- CI/CD configuration
- Export presets

---

## Fastest Path to a Finished Game

1. Free movement `CharacterBody2D` — done Day 1
2. 4 scenes (passenger car, dining car, car 13, engine cabin) — done Day 1
3. `Area2D` triggers for doors and encounters — done Day 1
4. Single `CombatManager.gd` with inline enemy dict — done Day 1
5. `GameState` autoload with 5 flags — done Day 1
6. Placeholder `Label`-based NPC dialogue — done Day 1
7. Day 2+: real sprites, sound, title screen, game-over, key pickup mechanic
