# 🎮 Project Architecture: Lettre pour Bea

> **Generated:** 2026-02-11 10:37
> **Path:** `C:\Applications\godot\Lettre`
> **Generator:** godot_architecture_generator.py (using gdtoolkit 4.5.0)

---

## 1. Project Overview

| Property | Value |
|----------|-------|
| **Project Name** | Lettre pour Bea |
| **Engine Features** | 4.5, Mobile |
| **Main Scene** | `res://scenes/title_screen.tscn` |
| **Scripts** | 10 |
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
  photos/
    1702679305337.jpg
    2023_06_17__1.png
    2023_07_02__1.jpg
    2023_07_12__1.jpg
    2023_07_18__1.jpg
    2023_08_09__1.jpg
    2023_08_09__2.jpg
    2023_08_20__1.jpg
    2024_07_14__1.png
    IMG-20230704-WA0033.jpg
    IMG-20230718-WA0002.jpg
    IMG-20230811-WA0002.jpg
    IMG-20231004-WA0003.jpg
    IMG-20231109-WA0003.jpg
    IMG_20230810_160621.jpg
    IMG_20230810_191730.jpg
    IMG_20230815_212814.jpg
    IMG_20230905_175457.jpg
    IMG_20230912_185111.jpg
    IMG_20230912_185111_1.jpg
    IMG_20230912_200208.jpg
    IMG_20230912_201440.jpg
    IMG_20230912_202251.jpg
    IMG_20230912_203101.jpg
    IMG_20240129_184507.jpg
    IMG_20240512_222214.jpg
    IMG_20240528_114928.jpg
    IMG_20240528_144919.jpg
    IMG_20240529_141442.jpg
    IMG_20240630_153417.jpg
    IMG_20240630_161352.jpg
    IMG_20240714_151225.jpg
    IMG_20240715_122906.jpg
    IMG_20240717_085829.jpg
    IMG_20240717_211433.jpg
    IMG_20240718_163947.jpg
    IMG_20240718_165241.jpg
    IMG_20240719_133805.jpg
    IMG_20240720_182629.jpg
    IMG_20240720_215030.jpg
    IMG_20240720_215033.jpg
    IMG_20240721_135636.jpg
    IMG_20240828_183503.jpg
    IMG_20240828_183611.jpg
    IMG_20240903_175730.jpg
    IMG_20240903_183323.jpg
    IMG_20240924_182420.jpg
    IMG_20240924_185841.jpg
    IMG_20241023_184515.jpg
    IMG_20241023_192750_1.jpg
    IMG_20241024_120839.jpg
    IMG_20241024_150107.jpg
    IMG_20241030_172824.jpg
    IMG_20241030_181851.jpg
    IMG_20241031_192128.jpg
    IMG_20241031_192618.jpg
    IMG_20241031_214253.jpg
    IMG_20241102_110314.jpg
    IMG_20241102_113649.jpg
    IMG_20241210_184651.jpg
    IMG_20241210_193915.jpg
    IMG_20250101_100613.jpg
    IMG_20250214_122721.jpg
    IMG_20250214_152317.jpg
    IMG_20250214_171304.jpg
    IMG_20250227_151700.jpg
    IMG_20250227_152530.jpg
    IMG_20250227_162457.jpg
    IMG_20250319_153231.jpg
    IMG_20250319_155949.jpg
    IMG_20250319_171712.jpg
  timeline_data.json
global.gd
icon.png
maps/
  backgrounds/
    SnowMountainsSky.png
    arcticmountains.png
    misty_snowhills_small.png
  map.gd
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

### `maps\map.gd`
**extends** `Node2D`

**Exports:**
- `hearts = preload "res://objects/heart/heart.tscn"`

**@onready Variables:**
- `display_size`

**Variables:**
- `game_over = false`
- `allow_restart = false`
- `game_started = false`
- `songs = "res://music/airship_2.ogg" "res://music/arctic_breeze.ogg" "res://music/chipdisko.ogg" "res://music/jewels.ogg"`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `—` | override/private |
| `_on_entry_loop_done` | `()` | `—` | override/private |
| `_process` | `(delta)` | `—` | override/private |
| `player_dead` | `(delta)` | `—` |  |
| `enable_restart` | `()` | `—` |  |
| `create_pipe` | `()` | `—` |  |
| `_input` | `(event)` | `—` | override/private |
| `_on_exit_pressed` | `()` | `—` | override/private |
| `_on_store_button_pressed` | `()` | `—` | override/private |
| `_on_magasin_button_pressed` | `()` | `—` | override/private |
| `_on_shop_close_pressed` | `()` | `—` | override/private |

**Dependencies (preload/load):**
- `res://objects/heart/heart.tscn`

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
- `State` { FLYING, DIVE_LOOP, DIVING_DOWN, HIDDEN, RISING, RISE_LOOP }

**Signals:**
- `dive_landed()`
- `returned_to_flight()`

**Exports:**
- `loop_radius: float = 120.0`
- `loop_speed: float = 3.5`
- `dive_speed: float = 700.0`
- `rise_speed: float = 700.0`
- `bob_amplitude: float = 6.0`
- `bob_frequency: float = 2.0`

**@onready Variables:**
- `sprite: AnimatedSprite2D`

**Variables:**
- `state: State = State.FLYING`
- `_loop_center: Vector2`
- `_loop_angle: float`
- `_loop_swept: float`
- `_flight_y: float`
- `_flight_x: float`
- `_bob_time: float = 0.0`
- `_rise_target: Vector2`
- `_trail: CPUParticles2D`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `void` | override/private |
| `_physics_process` | `(delta: float)` | `void` | override/private |
| `_process_flying` | `(delta: float)` | `void` | override/private |
| `_input` | `(event: InputEvent)` | `void` | override/private |
| `start_dive` | `()` | `void` |  |
| `_process_dive_loop` | `(delta: float)` | `void` | override/private |
| `_process_diving_down` | `(delta: float)` | `void` | override/private |
| `resume_flight` | `()` | `void` |  |
| `_process_rising` | `(delta: float)` | `void` | override/private |
| `_start_rise_loop` | `()` | `void` | override/private |
| `_process_rise_loop` | `(delta: float)` | `void` | override/private |
| `_create_trail` | `()` | `void` | override/private |

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

**Images** (77 files):
- `data\photos\1702679305337.jpg`
- `data\photos\2023_06_17__1.png`
- `data\photos\2023_07_02__1.jpg`
- `data\photos\2023_07_12__1.jpg`
- `data\photos\2023_07_18__1.jpg`
- `data\photos\2023_08_09__1.jpg`
- `data\photos\2023_08_09__2.jpg`
- `data\photos\2023_08_20__1.jpg`
- `data\photos\2024_07_14__1.png`
- `data\photos\IMG-20230704-WA0033.jpg`
- `data\photos\IMG-20230718-WA0002.jpg`
- `data\photos\IMG-20230811-WA0002.jpg`
- `data\photos\IMG-20231004-WA0003.jpg`
- `data\photos\IMG-20231109-WA0003.jpg`
- `data\photos\IMG_20230810_160621.jpg`
- `data\photos\IMG_20230810_191730.jpg`
- `data\photos\IMG_20230815_212814.jpg`
- `data\photos\IMG_20230905_175457.jpg`
- `data\photos\IMG_20230912_185111.jpg`
- `data\photos\IMG_20230912_185111_1.jpg`
- ... and 57 more

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

  maps\map.gd
    └─→ loads res://objects/heart/heart.tscn
```

---

## Stats Summary

| Metric | Count |
|--------|-------|
| Scripts | 10 |
| Scenes | 7 |
| Resources | 0 |
| Registered Classes | 0 |
| Total Functions | 69 |
| Total Signals | 4 |
| Total Exports | 19 |
| Autoloads | 1 |