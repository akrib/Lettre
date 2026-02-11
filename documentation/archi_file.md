# 🎮 Project Architecture: Lettre pour Bea

> **Generated:** 2026-02-11 08:19
> **Path:** `C:\Applications\godot\Lettre`
> **Generator:** godot_architecture_generator.py (using gdtoolkit 4.5.0)

---

## 1. Project Overview

| Property | Value |
|----------|-------|
| **Project Name** | Lettre pour Bea |
| **Engine Features** | 4.5, Mobile |
| **Main Scene** | `res://scenes/title_screen.tscn` |
| **Scripts** | 9 |
| **Scenes** | 7 |
| **Resources (.tres)** | 0 |
| **Input Actions** | `dive` |

## 2. Directory Structure

```
.gitattributes
.gitignore
README.md
data/
  Zone.sav
  timeline_data.json
global.gd
icon.png
maps/
  backgrounds/
    SnowMountainsSky.png
    arcticmountains.png
    misty_snowhills_small.png
  parallax_bg.gd
  scroller.gdshader
music/
  airship_2.ogg
  arctic_breeze.ogg
  chipdisko.ogg
  jewels.ogg
objects/
  player/
    player.gd
    player.tscn
  player_fly_tux/
    darthit.wav
    flap.ogg
    plane.png
    tux.png
  popup/
    event_popup.gd
    event_popup.tscn
  timeline/
    timeline.gd
    timeline.tscn
project.godot
scenes/
  end_screen.gd
  end_screen.tscn
  game.gd
  game.tscn
  title_screen.gd
  title_screen.tscn
```

## 3. Autoloads (Singletons)

| Name | Path | Type |
|------|------|------|
| **Global** | `res://global.gd` | Node |

## 5. Scene Map

### `objects\player\player.tscn`
- **Root:** Player (CharacterBody2D)

```
Player (CharacterBody2D)
  └─ CollisionShape2D (CollisionShape2D)
  └─ Sprite (AnimatedSprite2D)
  └─ FlapSound (AudioStreamPlayer2D)
  └─ DiveSound (AudioStreamPlayer2D)
```

### `objects\player_fly_tux\player.tscn`
- **Root:** player (CharacterBody2D)
- **Script:** `res://objects/player_fly_tux/player.gd`

```
player (CharacterBody2D)
  └─ CollisionShape2D (CollisionShape2D)
  └─ Sprite (AnimatedSprite2D)
  └─ flap (AudioStreamPlayer2D)
  └─ death (AudioStreamPlayer2D)
```

### `objects\popup\event_popup.tscn`
- **Root:** EventPopup (CanvasLayer)
- **Script:** `res://objects/popup/event_popup.gd`

```
EventPopup (CanvasLayer)
  └─ Panel (PanelContainer)
    └─ MarginContainer (MarginContainer)
      └─ VBoxContainer (VBoxContainer)
        └─ DateLabel (Label)
        └─ PhotosContainer (HBoxContainer)
        └─ DescriptionLabel (Label)
        └─ HintLabel (Label)
  └─ AnimationPlayer (AnimationPlayer)
```

### `objects\timeline\timeline.tscn`
- **Root:** Timeline (Node2D)
- **Script:** `res://objects/timeline/timeline.gd`

```
Timeline (Node2D)
  └─ Bar (ColorRect)
```

### `scenes\end_screen.tscn`
- **Root:** EndScreen (CanvasLayer)
- **Script:** `res://scenes/end_screen.gd`

```
EndScreen (CanvasLayer)
  └─ Panel (PanelContainer)
    └─ MarginContainer (MarginContainer)
      └─ VBoxContainer (VBoxContainer)
        └─ MessageLabel (Label)
  └─ AnimationPlayer (AnimationPlayer)
```

### `scenes\game.tscn`
- **Root:** Game (Node2D)
- **Script:** `res://scenes/game.gd`

```
Game (Node2D)
  └─ Background (ParallaxBackground)
    └─ SkyLayer (ParallaxLayer)
      └─ Sky (TextureRect)
    └─ MountainLayer (ParallaxLayer)
      └─ Mountains (TextureRect)
  └─ Player
  └─ Timeline
  └─ EventPopup
  └─ EndScreen
  └─ Music (AudioStreamPlayer)
```

**External Resources:**
- [PackedScene] `res://objects/player/player.tscn`
- [PackedScene] `res://objects/timeline/timeline.tscn`
- [PackedScene] `res://objects/popup/event_popup.tscn`
- [PackedScene] `res://scenes/end_screen.tscn`

### `scenes\title_screen.tscn`
- **Root:** TitleScreen (Control)
- **Script:** `res://scenes/title_screen.gd`

```
TitleScreen (Control)
  └─ Background (TextureRect)
  └─ TitleLabel (Label)
  └─ SubtitleLabel (Label)
  └─ PromptLabel (Label)
  └─ CopyrightLabel (Label)
  └─ AnimationPlayer (AnimationPlayer)
  └─ Music (AudioStreamPlayer)
```


## 6. Scripts Detail

### `global.gd`
**extends** `Node`

**Constants:**
- `TIMELINE_PATH` = "res://data/timeline_data.json"
- `SAVE_PATH` = "user://save.json"

**Variables:**
- `timeline_title: ""`
- `timeline_subtitle: ""`
- `timeline_end_message: ""`
- `timeline_events: Array[Dictionary]`
- `save_data: "events_seen"`
- `player: CharacterBody2D = null`
- `scroll_speed: 120.0`
- `is_paused: false`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `void` | override/private |
| `_load_timeline` | `()` | `void` | override/private |
| `save_game` | `()` | `void` |  |
| `_load_save` | `()` | `void` | override/private |
| `mark_event_seen` | `(index: int)` | `void` |  |

### `maps\parallax_bg.gd`
**extends** `ParallaxBackground`

**Exports:**
- `auto_scroll: true`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_process` | `(delta: float)` | `void` | override/private |

### `objects\player\player.gd`
**extends** `CharacterBody2D`

**Enums:**
- `State` { FLYING, LOOPING, DIVING, GROUNDED, RISING }

**Signals:**
- `dive_landed()`
- `returned_to_flight()`

**Exports:**
- `flight_altitude: 180.0`
- `bob_amplitude: 12.0`
- `bob_frequency: 2.5`
- `loop_duration: 0.5`
- `dive_speed: 500.0`
- `rise_speed: 200.0`
- `timeline_y: 560.0`

**@onready Variables:**
- `sprite: AnimatedSprite2D`
- `flap_sound: AudioStreamPlayer2D`
- `dive_sound: AudioStreamPlayer2D`

**Variables:**
- `state: State`
- `time_alive: 0.0`
- `loop_timer: 0.0`
- `loop_start_rotation: 0.0`
- `_can_dive: true`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `void` | override/private |
| `_physics_process` | `(delta: float)` | `void` | override/private |
| `_unhandled_input` | `(event: InputEvent)` | `void` | override/private |
| `_fly` | `(_delta: float)` | `void` | override/private |
| `_start_loop` | `()` | `void` | override/private |
| `_loop` | `(delta: float)` | `void` | override/private |
| `_dive` | `(_delta: float)` | `void` | override/private |
| `_land` | `()` | `void` | override/private |
| `_rise` | `(_delta: float)` | `void` | override/private |
| `resume_flight` | `()` | `void` |  |
| `is_flying` | `()` | `—` |  |

### `objects\player_fly_tux\player.gd`
**extends** `CharacterBody2D`

**Exports:**
- `gravity = 9.0`
- `flap_force: int = -6`

**@onready Variables:**
- `sprite`
- `display_size`

**Variables:**
- `dead = false`
- `max_speed = 400`
- `rotation_speed = 2`
- `data = "chamallow" 0 "current_chamallow" 0 "total_chamallow" 0 "max_dist" 0 "nb_run" 0 "total_dist" 0 "upgrade_list" 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `—` | override/private |
| `_physics_process` | `(delta)` | `—` | override/private |
| `_input` | `(event)` | `—` | override/private |
| `flap` | `()` | `—` |  |
| `rotate_bird` | `()` | `—` |  |
| `death` | `()` | `—` |  |
| `bounce` | `()` | `—` |  |

### `objects\popup\event_popup.gd`
**extends** `CanvasLayer`

**Signals:**
- `popup_closed()`

**@onready Variables:**
- `panel: PanelContainer`
- `photos_container: HBoxContainer`
- `date_label: Label`
- `description_label: Label`
- `hint_label: Label`
- `anim: AnimationPlayer`

**Variables:**
- `_is_open: false`
- `_allow_close: false`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `void` | override/private |
| `_unhandled_input` | `(event: InputEvent)` | `void` | override/private |
| `show_event` | `(event_data: Dictionary)` | `void` |  |
| `close` | `()` | `void` |  |
| `_clear_photos` | `()` | `void` | override/private |
| `_add_photo` | `(path: String)` | `void` | override/private |

### `objects\timeline\timeline.gd`
**extends** `Node2D`

**Signals:**
- `event_zone_entered(event_index: int)`

**Exports:**
- `bar_height: 6.0`
- `bar_color: Color`
- `bar_y: 570.0`
- `sign_post_height: 55.0`
- `sign_panel_color: Color`
- `sign_text_color: Color`
- `event_text_color: Color`
- `sign_spacing: 500.0`
- `start_offset: 600.0`

**@onready Variables:**
- `display_size: get_viewport`

**Variables:**
- `events: Array[Dictionary]`
- `sign_nodes: Array[Node2D]`
- `is_scrolling: true`
- `_active_event_index: -1`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `void` | override/private |
| `_process` | `(delta: float)` | `void` | override/private |
| `_build_timeline` | `()` | `void` | override/private |
| `_create_sign` | `(event: Dictionary, index: int)` | `—` | override/private |
| `_create_end_sign` | `()` | `—` | override/private |
| `_update_active_zone` | `()` | `void` | override/private |
| `_on_trigger_zone_body_entered` | `(body: Node2D, event_index: int)` | `void` | override/private |
| `get_active_event_index` | `()` | `—` |  |
| `get_active_event` | `()` | `—` |  |
| `pause` | `()` | `void` |  |
| `resume` | `()` | `void` |  |

### `scenes\end_screen.gd`
**extends** `CanvasLayer`

**@onready Variables:**
- `message_label: Label`
- `anim: AnimationPlayer`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `void` | override/private |
| `show_message` | `(text: String)` | `void` |  |

### `scenes\game.gd`
**extends** `Node2D`

**@onready Variables:**
- `player: CharacterBody2D`
- `timeline: Node2D`
- `popup: CanvasLayer`
- `music: AudioStreamPlayer`
- `end_screen: CanvasLayer`

**Variables:**
- `songs: Array[String] = "res://music/airship_2.ogg" "res://music/arctic_breeze.ogg" "res://music/chipdisko.ogg" "res://music/jewels.ogg"`
- `_current_event_index: -1`
- `_events_visited: Array[int]`
- `_game_finished: false`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `void` | override/private |
| `_setup_music` | `()` | `void` | override/private |
| `_connect_signals` | `()` | `void` | override/private |
| `_on_event_zone_entered` | `(event_index: int)` | `void` | override/private |
| `_on_player_dive_landed` | `()` | `void` | override/private |
| `_on_popup_closed` | `()` | `void` | override/private |
| `_resume_after_popup` | `()` | `void` | override/private |
| `_on_player_returned` | `()` | `void` | override/private |
| `_show_end_screen` | `()` | `void` | override/private |
| `_input` | `(event: InputEvent)` | `void` | override/private |

### `scenes\title_screen.gd`
**extends** `Control`

**@onready Variables:**
- `title_label: Label`
- `subtitle_label: Label`
- `prompt_label: Label`
- `anim: AnimationPlayer`
- `music: AudioStreamPlayer`

**Variables:**
- `_can_start: false`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `void` | override/private |
| `_input` | `(event: InputEvent)` | `void` | override/private |
| `_start_game` | `()` | `void` | override/private |
| `_blink_prompt` | `()` | `void` | override/private |


## 7. Global Signal Map

| Signal | Defined In | Arguments | Connected In |
|--------|-----------|-----------|-------------|
| `dive_landed` | `objects\player\player.gd` | `()` | — |
| `event_zone_entered` | `objects\timeline\timeline.gd` | `(event_index: int)` | — |
| `popup_closed` | `objects\popup\event_popup.gd` | `()` | — |
| `returned_to_flight` | `objects\player\player.gd` | `()` | — |

## 9. Asset Summary

**Audio** (6 files):
- `music\airship_2.ogg`
- `music\arctic_breeze.ogg`
- `music\chipdisko.ogg`
- `music\jewels.ogg`
- `objects\player_fly_tux\darthit.wav`
- `objects\player_fly_tux\flap.ogg`

**Data** (1 files):
- `data\timeline_data.json`

**Images** (6 files):
- `icon.png`
- `maps\backgrounds\SnowMountainsSky.png`
- `maps\backgrounds\arcticmountains.png`
- `maps\backgrounds\misty_snowhills_small.png`
- `objects\player_fly_tux\plane.png`
- `objects\player_fly_tux\tux.png`

**Shaders** (1 files):
- `maps\scroller.gdshader`

**Other** (6 files):
- `.gitattributes`
- `.gitignore`
- `data\Zone.sav`
- `maps\Zone.sav`
- `objects\Zone.sav`
- `scenes\Zone.sav`

## 10. Dependency Graph

```
(script) --preloads/extends--> (dependency)

```

---

## Stats Summary

| Metric | Count |
|--------|-------|
| Scripts | 9 |
| Scenes | 7 |
| Resources | 0 |
| Registered Classes | 0 |
| Total Functions | 57 |
| Total Signals | 4 |
| Total Exports | 19 |
| Autoloads | 1 |