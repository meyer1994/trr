# trr

A small Terraria-like 2D game made with Godot 4.

## Inventory, equipment and effects

The player owns a 40-slot inventory, an `ItemContainer` of `ItemStack`s, the copies of items it carries. The first inventory row is the hotbar; `Esc` or `I` shows the other three rows, and the player holds one of those slots (keys `1`–`0`). Wearing an equippable (right mouse button on the held slot) moves its stack from the inventory into `Equipment`, and whatever it replaces takes its inventory slot. Clicking a worn piece in the equipment panel moves it back to the first free inventory slot.

Effects are built around two contracts. GDScript has no interfaces, so they are duck-typed methods:

- **Effect source**: anything with `get_effects() -> Array[Effect]`. Item stacks are sources today; buffs or ammo can be added later without touching the targets.
- **Effect target**: anything with `base_stats() -> Dictionary`. A target resolves its final `Stats` with `effects.resolve(target, base_stats())`.

```mermaid
classDiagram
    class EffectSource {
        <<interface>>
        get_effects() Array~Effect~
    }
    class EffectTarget {
        <<interface>>
        base_stats() Dictionary
    }
    class Effect {
        target: Target
        stat: Stat
        mode: Mode
        value
        is_valid() bool
    }
    class EffectSet {
        from_sources(sources)$
        add(effect)
        resolve(target, base) Stats
    }
    class Stats {
        value(stat) float
    }
    class Item {
        display_name
        icon_color
        icon_size
        effects: Array~Effect~
        base_stats() Dictionary
    }
    class Weapon {
        automatic
        fire_interval
        damage
        splash_radius
        projectile_speed
        projectile_gravity
        projectile_drag
    }
    class Equippable {
        kind: Kind
        defense
    }
    class ItemStack {
        item: Item
        count
    }
    class ItemContainer {
        slots: Array~ItemStack~
        add(stack) bool
        take(index) ItemStack
        put(index, stack)
        move_to(index, other)
        changed()
    }
    class Equipment {
        slots: Array~ItemStack~
        equip(stack) ItemStack
        unequip(index) ItemStack
        changed()
    }
    class Player {
        held_index
        effects: EffectSet
        stats: Stats
        held_stats: Stats
        hold(index)
        wear(index)
        take_off(index)
        base_stats() Dictionary
        stats_changed()
        held_changed()
    }
    class Projectile {
        stats: Stats
    }

    EffectSource <|.. ItemStack
    EffectTarget <|.. Player
    EffectTarget <|.. Item
    Item <|-- Weapon
    Item <|-- Equippable
    Weapon <|-- Pistol
    Weapon <|-- Rifle
    Weapon <|-- Launcher
    Item o-- Effect : effects
    ItemStack --> Item
    ItemContainer o-- ItemStack : carries
    Equipment o-- ItemStack : wears
    EffectSet o-- Effect : grouped by target
    EffectSet ..> Stats : resolves
    Player *-- ItemContainer : inventory
    Player *-- Equipment
    Player ..> Projectile : fires with held_stats
```

```mermaid
flowchart LR
    Worn["Worn stacks"] -->|"always"| Pool["Player EffectSet"]
    Held["Held stack, unless wearable"] -->|"only while held"| Pool
    Pool -->|"resolve WORN, per piece"| WornStats["Worn defense"]
    WornStats -->|"summed into base"| PlayerStats
    Pool -->|"resolve PLAYER"| PlayerStats["Player stats"]
    Pool -->|"resolve HELD"| HeldStats["Held weapon stats"]
    HeldStats -->|"given to each shot"| Shot["Projectile"]
```

- **Items** are Resources (`.tres`) shared by every copy: weapons live in `items/`, equipment in `equipment/`. Anything that differs per copy belongs on `ItemStack`.
- **Equippable** items declare a `kind` (`HEAD`, `BODY`, `LEGS`, `ACCESSORY`) and a base `defense`, and `Equipment` only puts them in a matching slot.
- **Effects** change one `Stat` by a `FLAT` amount or a `PERCENT` of the base, on one `Target`:

  | Target | Applies to | Stats |
  |---|---|---|
  | `PLAYER` | The player | `SPEED` (walking), `DEFENSE` |
  | `WORN` | Each worn piece | `DEFENSE` |
  | `HELD` | The held item and the shots it fires | `FIRE_RATE`, `SPEED` (projectile), `DAMAGE`, `SPLASH_RADIUS`, `GRAVITY` |

- **Resolving**: final values are `(base + flat) * (1 + percent)`. The player resolves each worn piece's defense first, sums it into its own base, then resolves its `PLAYER` stats and the held weapon's `HELD` stats. Each projectile keeps the held stats from the moment it was fired.
- **Validation**: an effect whose stat isn't listed for its target is ignored with a warning, once per effect. A valid effect whose target lacks the stat right now (a damage bonus while holding boots) is skipped silently.
- **When**: the player rebuilds its `EffectSet` whenever the inventory, equipment or held slot changes. Equipment effects apply only while worn, never while merely held; other items' effects apply only while held.

## Chests

Chests are placed while the world streams in, so the same seed always gives the same chests with the same loot.

```mermaid
flowchart LR
    Load["Map.chunk_loaded"] --> Pick["seed + chunk: maybe a chest on a free floor cell"]
    Pick --> Band{"Depth band"}
    Band -->|"above the surface"| Surface["loot/surface.tres"]
    Band -->|"below the surface"| Caves["loot/caves.tres"]
    Band -->|"on a floating island"| Islands["loot/islands.tres"]
    Surface & Caves & Islands -->|"first open: roll with seed + cell"| Contents["ItemContainer (20 slots)"]
    Contents -->|"kept while the chunk is unloaded"| Contents
```

- **Placement**: `Chests` listens to the map's chunk signals. Each chunk has a 30% chance of a chest on an empty generated cell with solid ground under it. The block under a chest is protected from damage.
- **Loot**: a `LootTable` lists weighted `LootEntry`s and how many items to roll. Contents are rolled the first time a chest is opened and remembered from then on, like dug blocks.
- **Using a chest**: right-click a chest within reach (5 tiles) to open it; right-clicking anywhere else still wears the held item. The inventory grid and the chest's slots appear under the hotbar. Clicking an inventory or hotbar slot stores that stack in the chest; clicking a chest slot takes it. A chest closes when right-clicked again, when the inventory is closed, or when you walk away.
