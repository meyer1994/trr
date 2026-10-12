# trr

A small Terraria-like 2D game made with Godot 4.

## Items, equipment and effects

Effects are built around two contracts. GDScript has no interfaces, so they are duck-typed methods:

- **Effect source**: anything with `get_effects() -> Array[Effect]`. Items are sources today; buffs or ammo can be added later without touching the targets.
- **Effect target**: anything with a `TARGET_SCOPE` constant and `base_stats() -> Dictionary`. A target resolves its own final `Stats` with `effects.resolve(TARGET_SCOPE, base_stats())`.

```mermaid
classDiagram
    class EffectSource {
        <<interface>>
        get_effects() Array~Effect~
    }
    class EffectTarget {
        <<interface>>
        TARGET_SCOPE
        base_stats() Dictionary
    }
    class Effect {
        scope: Scope
        stat: Stat
        mode: Mode
        value
    }
    class EffectSet {
        from_sources(sources)$
        add(effect)
        resolve(scope, base) Stats
    }
    class Stats {
        value(stat) float
    }
    class Item {
        display_name
        icon_color
        icon_size
        effects: Array~Effect~
    }
    class Weapon {
        automatic
        fire_interval
        damage
        splash_radius
        projectile_speed
        projectile_gravity
    }
    class Equippable {
        kind: Kind
    }
    class Hotbar {
        selected_item
        selection_changed()
    }
    class Equipment {
        slots: Array~Equippable~
        equip(item)
        unequip(index)
        changed()
    }
    class Player {
        effects: EffectSet
        stats: Stats
        weapon_stats: Stats
        stats_changed()
    }
    class Projectile {
        effects: EffectSet
        stats: Stats
    }

    EffectSource <|.. Item
    EffectTarget <|.. Player
    EffectTarget <|.. Weapon
    EffectTarget <|.. Projectile
    Item <|-- Weapon
    Item <|-- Equippable
    Weapon <|-- Pistol
    Weapon <|-- Rifle
    Weapon <|-- Launcher
    Item o-- Effect : effects
    Hotbar o-- Item : holds
    Equipment o-- Equippable : wears
    EffectSet o-- Effect : grouped by scope
    EffectSet ..> Stats : resolves
    Player --> Hotbar : held item
    Player --> Equipment : worn items
    Player ..> Projectile : fires with its EffectSet
```

```mermaid
flowchart LR
    Worn["Worn equipment"] -->|"always"| Pool["Player EffectSet"]
    Held["Held item"] -->|"only while held"| Pool
    Pool -->|"resolve PLAYER"| PlayerStats["Player stats"]
    Pool -->|"resolve WEAPON"| WeaponStats["Held weapon stats"]
    Pool -->|"copied into each shot"| Shot["Projectile resolves PROJECTILE stats"]
```

- **Items** are Resources (`.tres`): weapons live in `items/`, equipment in `equipment/`.
- **Equippable** items declare a `kind` (`HEAD`, `BODY`, `LEGS`, `ACCESSORY`), and `Equipment` only puts them in a matching slot.
- **Effects** change one `Stat` by a `FLAT` amount or a `PERCENT` of the base, on one `Scope`. Each target declares which stats it has:

  | Scope | Target | Stats |
  |---|---|---|
  | `PLAYER` | The player | `SPEED` (walking), `DEFENSE` |
  | `WEAPON` | The held weapon | `FIRE_RATE` |
  | `PROJECTILE` | Each shot fired | `SPEED`, `DAMAGE`, `SPLASH_RADIUS`, `GRAVITY` |

- **Resolving**: final values are `(base + flat) * (1 + percent)`. An effect on a stat its target doesn't have is skipped with a warning.
- **The player** rebuilds its `EffectSet` whenever equipment or the hotbar selection changes, then resolves its own stats and the held weapon's. Each projectile gets the set that was active when it was fired and resolves its own stats. Equipment effects apply all the time; a weapon's own effects apply only while it is held.
