# 🎮 Project Architecture: Lettre pour Bea

> **Generated:** 2026-02-11 07:04
> **Path:** `C:\Applications\godot\Lettre`
> **Generator:** godot_architecture_generator.py (using gdtoolkit 4.5.0)

---

## 1. Project Overview

| Property | Value |
|----------|-------|
| **Project Name** | Lettre pour Bea |
| **Engine Features** | 4.5, Mobile |
| **Main Scene** | `res://scenes/title.tscn` |
| **Scripts** | 9 |
| **Scenes** | 13 |
| **Resources (.tres)** | 2 |
| **Input Actions** | `flap` |

## 2. Directory Structure

```
.gitattributes
.gitignore
Tanks/
  food.png
  tank-tier_0.png
  tank-tier_0.tscn
  tank-tier_1.png
  tank-tier_1.tscn
  tank-tier_2.png
  tank-tier_2.tscn
  tank-tier_3.png
  tank-tier_3.tscn
  tier_1-pressed.png
  tier_1-thumb.png
  tier_2-pressed.png
  tier_2-thumb.png
  tier_3-pressed.png
  tier_3-thumb.png
UI/
  Shop/
    Assets/
      atlas_ship.png
      chair-pressed.png
      chair-thumb.png
      chair.png
      coral.png
      fruit_basket-pressed.png
      fruit_basket-thumb.png
      fruit_basket.png
      green_plant-pressed.png
      green_plant-thumb.png
      green_plant.png
      highlight.png
      hog_pet.png
      item_3-pressed.png
      item_3-thumb.png
      item_3.png
      item_4-pressed.png
      item_4-thumb.png
      item_4.png
      item_5-pressed.png
      item_5-thumb.png
      item_5.png
      item_6-pressed.png
      item_6-thumb.png
      item_6.png
      item_7-pressed.png
      item_7-thumb.png
      item_7.png
      kelp.png
      lamp-pressed.png
      lamp-thumb.png
      lamp.png
      orca_mug.png
      phantom_ghost.png
      samo_pet.png
      sand_castle-pressed.png
      sand_castle-thumb.png
      sand_castle.png
      sbr_saber.png
      scallop.png
      scuba_diver-pressed.png
      scuba_diver-thumb.png
      scuba_diver.png
      shell-pressed.png
      shell-thumb.png
      shell.png
      sol_beach_ball.png
      table-pressed.png
      table-thumb.png
      table.aseprite
      table.png
      tv.png
      tvs-pressed.png
      tvs-thumb.png
      umbrella-pressed.png
      umbrella.png
  buttons/
    Button_Blue.png
    Button_Blue_3Slides.png
    Button_Blue_3Slides_Pressed.png
    Button_Blue_9Slides.png
    Button_Blue_9Slides_Pressed.png
    Button_Blue_Pressed.png
    Button_Disable.png
    Button_Disable_3Slides.png
    Button_Disable_9Slides.png
    Button_Hover.png
    Button_Hover_3Slides.png
    Button_Hover_9Slides.png
    Button_Red.png
    Button_Red_3Slides.png
    Button_Red_3Slides_Pressed.png
    Button_Red_9Slides.png
    Button_Red_9Slides_Pressed.png
    Button_Red_Pressed.png
    button.tres
    exit.png
  game_over.png
  load_screen.png
  m5x7.ttf
  score.gd
  score.ogg
  score.tscn
  x.png
export_presets.cfg
fonts/
  Adventurer.ttf
  FreeMono.ttf
global.gd
icon.png
maps/
  backgrounds/
    SnowMountainsSky.png
    arcticmountains.png
    misty_snowhills_small.png
  map.gd
  map_01.tscn
  scroller.gdshader
  scroller.tres
music/
  airship_2.ogg
  arctic_breeze.ogg
  chipdisko.ogg
  jewels.ogg
objects/
  heart/
    heart.gd
    heart.png
    heart.tscn
  pipes/
    blue.png
    pipe.gd
    pipe.tscn
    window_1.png
    window_2.png
  player_fly_tux/
    darthit.wav
    flap.ogg
    plane.png
    player.gd
    player.tscn
    tux.png
  points/
    100.png
    points.gd
    points.tscn
project.godot
scenes/
  shop_layer.tscn
  title.gd
  title.png
  title.tscn
  title_menu.gd
  title_menu.tscn
```

## 3. Autoloads (Singletons)

| Name | Path | Type |
|------|------|------|
| **Global** | `res://global.gd` | Node |

## 5. Scene Map

### `Tanks\tank-tier_0.tscn`
- **Root:** Node2D (Node2D)

```
Node2D (Node2D)
  └─ Tank-tier0 (Sprite2D)
  └─ TankBorder (StaticBody2D)
    └─ CollisionPolygon2D (CollisionPolygon2D)
  └─ Sprite2D (Sprite2D)
  └─ AnimationPlayer (AnimationPlayer)
```

**External Resources:**
- [Texture2D] `res://Tanks/tank-tier_0.png`
- [Texture2D] `res://Tanks/food.png`

### `Tanks\tank-tier_1.tscn`
- **Root:** Tank-tier1 (Node2D)

```
Tank-tier1 (Node2D)
  └─ Tank-tier1 (Sprite2D)
  └─ StaticBody2D (StaticBody2D)
    └─ CollisionPolygon2D (CollisionPolygon2D)
  └─ Sprite2D (Sprite2D)
  └─ AnimationPlayer (AnimationPlayer)
```

**External Resources:**
- [Texture2D] `res://Tanks/tank-tier_1.png`
- [Texture2D] `res://Tanks/food.png`

### `Tanks\tank-tier_2.tscn`
- **Root:** Node2D (Node2D)

```
Node2D (Node2D)
  └─ Tank-tier2 (Sprite2D)
  └─ StaticBody2D (StaticBody2D)
    └─ CollisionPolygon2D (CollisionPolygon2D)
  └─ Sprite2D (Sprite2D)
  └─ AnimationPlayer (AnimationPlayer)
```

**External Resources:**
- [Texture2D] `res://Tanks/tank-tier_2.png`
- [Texture2D] `res://Tanks/food.png`

### `Tanks\tank-tier_3.tscn`
- **Root:** Node2D (Node2D)

```
Node2D (Node2D)
  └─ StaticBody2D (StaticBody2D)
    └─ CollisionPolygon2D (CollisionPolygon2D)
  └─ Tank-tier3 (Sprite2D)
  └─ Sprite2D (Sprite2D)
  └─ AnimationPlayer (AnimationPlayer)
```

**External Resources:**
- [Texture2D] `res://Tanks/tank-tier_3.png`
- [Texture2D] `res://Tanks/food.png`

### `UI\score.tscn`
- **Root:** score (Label)
- **Script:** `res://UI/score.gd`

```
score (Label)
  └─ Timer (Timer)
  └─ sound (AudioStreamPlayer)
```

**Signal Connections:**
- `Timer`.timeout → `.`.update_score()

### `maps\map_01.tscn`
- **Root:** map (Node2D)
- **Script:** `res://maps/map.gd`

```
map (Node2D)
  └─ background (TextureRect)
  └─ background2 (TextureRect)
  └─ background3 (TextureRect)
  └─ score
  └─ score2
    └─ Label (Label)
  └─ player
  └─ pipe
    └─ Sprite2D (Sprite2D)
  └─ Heart
  └─ PipeTimer (Timer)
  └─ music (AudioStreamPlayer)
  └─ AnimationPlayer (AnimationPlayer)
  └─ MagasinButton (Button)
  └─ black (ColorRect)
  └─ Game Over (TextureRect)
  └─ exit (Button)
  └─ ShopLayer
```

**Signal Connections:**
- `PipeTimer`.timeout → `.`.create_pipe()
- `MagasinButton`.pressed → `.`._on_magasin_button_pressed()
- `exit`.pressed → `.`._on_exit_pressed()

### `objects\heart\heart.tscn`
- **Root:** Heart (Node2D)
- **Script:** `res://objects/heart/heart.gd`

```
Heart (Node2D)
  └─ heart_sprite (AnimatedSprite2D)
    └─ Area2D (Area2D)
      └─ CollisionShape2D (CollisionShape2D)
  └─ points (Area2D)
    └─ CollisionShape2D (CollisionShape2D)
  └─ DeathTimer (Timer)
```

**Signal Connections:**
- `heart_sprite`.animation_finished → `.`._on_heart_sprite_animation_finished()
- `heart_sprite/Area2D`.body_entered → `.`.crash()

### `objects\pipes\pipe.tscn`
- **Root:** pipe (Node2D)
- **Script:** `res://objects/pipes/pipe.gd`

```
pipe (Node2D)
  └─ top (Sprite2D)
    └─ Area2D (Area2D)
      └─ CollisionShape2D (CollisionShape2D)
  └─ bottom (Sprite2D)
    └─ Area2D (Area2D)
      └─ CollisionShape2D (CollisionShape2D)
  └─ points (Area2D)
    └─ CollisionShape2D (CollisionShape2D)
  └─ DeathTimer (Timer)
  └─ windows_2 (Sprite2D)
  └─ windows_1 (Sprite2D)
```

**Signal Connections:**
- `top/Area2D`.body_entered → `.`.crash()
- `bottom/Area2D`.body_entered → `.`.crash()
- `points`.body_entered → `.`._on_points_body_entered()
- `DeathTimer`.timeout → `.`.remove()

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

### `objects\points\points.tscn`
- **Root:** points (Sprite2D)
- **Script:** `res://objects/points/points.gd`

```
points (Sprite2D)
```

### `scenes\shop_layer.tscn`
- **Root:** ShopLayer (CanvasLayer)

```
ShopLayer (CanvasLayer)
  └─ Panel (Panel)
    └─ PetShop (GridContainer)
      └─ HBoxContainer (HBoxContainer)
        └─ Label (Label)
        └─ TextureButton (TextureButton)
      └─ GridContainer (GridContainer)
        └─ Item0 (TextureButton)
        └─ Item1 (TextureButton)
        └─ Item2 (TextureButton)
        └─ Item3 (TextureButton)
        └─ Item4 (TextureButton)
        └─ Item5 (TextureButton)
        └─ Item6 (TextureButton)
        └─ Item7 (TextureButton)
      └─ HSplitContainer2 (HSplitContainer)
        └─ Label (Label)
      └─ GridContainer2 (GridContainer)
        └─ Item0 (TextureButton)
        └─ Item1 (TextureButton)
        └─ Item2 (TextureButton)
      └─ GridContainer3 (GridContainer)
        └─ PriceLabel (Label)
        └─ PriceLabel2 (Label)
        └─ BuyButton (Button)
```

### `scenes\title.tscn`
- **Root:** title (Control)
- **Script:** `res://scenes/title.gd`

```
title (Control)
  └─ Label (Label)
  └─ AnimationPlayer (AnimationPlayer)
```

### `scenes\title_menu.tscn`
- **Root:** Title Menu (Control)
- **Script:** `res://scenes/title_menu.gd`

```
Title Menu (Control)
  └─ background (Sprite2D)
  └─ background2 (Sprite2D)
  └─ Title (Label)
  └─ message (Label)
  └─ high_scores (Label)
  └─ AnimationPlayer (AnimationPlayer)
  └─ music (AudioStreamPlayer)
  └─ player (AnimatedSprite2D)
  └─ CreditsTimer (Timer)
```

**Signal Connections:**
- `CreditsTimer`.timeout → `.`._on_credits_timer_timeout()


## 6. Scripts Detail

### `UI\score.gd`
**extends** `Label`

**@onready Variables:**
- `player`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `—` | override/private |
| `update_score` | `()` | `—` |  |

### `global.gd`
**extends** `Node`

**Variables:**
- `heart_speed = 800.0`
- `pipe_speed = 200.0`
- `player`
- `game_time = 0.0`
- `chamallow = 0`
- `default_save_data = "chamallow" 0 "current_chamallow" 0 "total_chamallow" 0 "max_dist" 0 "nb_run" 0 "total_dist" 0 "upgrade_list" 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1`
- `save_data`
- `save_file = "user://scores.save"`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `—` | override/private |
| `_process` | `(delta)` | `—` | override/private |
| `save_score` | `()` | `—` |  |
| `first_save` | `()` | `—` |  |
| `load_score` | `()` | `—` |  |

### `maps\map.gd`
**extends** `Node2D`

**Exports:**
- `hearts = preload "res://objects/heart/heart.tscn"`

**@onready Variables:**
- `display_size`

**Variables:**
- `game_over = false`
- `allow_restart = false`
- `songs = "res://music/airship_2.ogg" "res://music/arctic_breeze.ogg" "res://music/chipdisko.ogg" "res://music/jewels.ogg"`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `—` | override/private |
| `_process` | `(delta)` | `—` | override/private |
| `player_dead` | `(delta)` | `—` |  |
| `enable_restart` | `()` | `—` |  |
| `create_pipe` | `()` | `—` |  |
| `_input` | `(event)` | `—` | override/private |
| `_on_exit_pressed` | `()` | `—` | override/private |
| `_on_store_button_pressed` | `()` | `—` | override/private |
| `_on_magasin_button_pressed` | `()` | `—` | override/private |

**Dependencies (preload/load):**
- `res://objects/heart/heart.tscn`

### `objects\heart\heart.gd`
**extends** `Node2D`

**@onready Variables:**
- `player`
- `points`

**Variables:**
- `top_pos = 300`
- `active = false`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `—` | override/private |
| `_process` | `(delta)` | `—` | override/private |
| `crash` | `(body)` | `—` |  |
| `remove` | `()` | `—` |  |
| `_on_heart_sprite_animation_finished` | `()` | `—` | override/private |

**Dependencies (preload/load):**
- `res://objects/points/points.tscn`

### `objects\pipes\pipe.gd`
**extends** `Node2D`

**@onready Variables:**
- `player`
- `points`

**Variables:**
- `top_pos = 0`
- `active = false`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `—` | override/private |
| `_process` | `(delta)` | `—` | override/private |
| `crash` | `(body)` | `—` |  |
| `remove` | `()` | `—` |  |
| `_on_points_body_entered` | `(body)` | `—` | override/private |

**Dependencies (preload/load):**
- `res://objects/points/points.tscn`

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

### `objects\points\points.gd`
**extends** `Sprite2D`

**Variables:**
- `speed = 150`
- `growth = .1`
- `life = 0`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `—` | override/private |
| `_process` | `(delta)` | `—` | override/private |

### `scenes\title.gd`
**extends** `Control`

**Variables:**
- `next_scene = "res://scenes/title_menu.tscn"`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `—` | override/private |
| `next` | `()` | `—` |  |

### `scenes\title_menu.gd`
**extends** `Control`

**Functions:**
| Function | Arguments | Returns | Notes |
|----------|-----------|---------|-------|
| `_ready` | `()` | `—` | override/private |
| `_input` | `(event)` | `—` | override/private |
| `start_game` | `()` | `—` |  |


## 8. Resources (.tres)

| File | Type | Script |
|------|------|--------|
| `UI\buttons\button.tres` | Theme | — |
| `maps\scroller.tres` | ShaderMaterial | — |

## 9. Asset Summary

**Audio** (7 files):
- `UI\score.ogg`
- `music\airship_2.ogg`
- `music\arctic_breeze.ogg`
- `music\chipdisko.ogg`
- `music\jewels.ogg`
- `objects\player_fly_tux\darthit.wav`
- `objects\player_fly_tux\flap.ogg`

**Data** (1 files):
- `export_presets.cfg`

**Fonts** (3 files):
- `UI\m5x7.ttf`
- `fonts\Adventurer.ttf`
- `fonts\FreeMono.ttf`

**Images** (100 files):
- `Tanks\food.png`
- `Tanks\tank-tier_0.png`
- `Tanks\tank-tier_1.png`
- `Tanks\tank-tier_2.png`
- `Tanks\tank-tier_3.png`
- `Tanks\tier_1-pressed.png`
- `Tanks\tier_1-thumb.png`
- `Tanks\tier_2-pressed.png`
- `Tanks\tier_2-thumb.png`
- `Tanks\tier_3-pressed.png`
- `Tanks\tier_3-thumb.png`
- `UI\Shop\Assets\atlas_ship.png`
- `UI\Shop\Assets\chair-pressed.png`
- `UI\Shop\Assets\chair-thumb.png`
- `UI\Shop\Assets\chair.png`
- `UI\Shop\Assets\coral.png`
- `UI\Shop\Assets\fruit_basket-pressed.png`
- `UI\Shop\Assets\fruit_basket-thumb.png`
- `UI\Shop\Assets\fruit_basket.png`
- `UI\Shop\Assets\green_plant-pressed.png`
- ... and 80 more

**Shaders** (1 files):
- `maps\scroller.gdshader`

**Other** (3 files):
- `.gitattributes`
- `.gitignore`
- `UI\Shop\Assets\table.aseprite`

## 10. Dependency Graph

```
(script) --preloads/extends--> (dependency)

  maps\map.gd
    └─→ loads res://objects/heart/heart.tscn
  objects\heart\heart.gd
    └─→ loads res://objects/points/points.tscn
  objects\pipes\pipe.gd
    └─→ loads res://objects/points/points.tscn
```

---

## Stats Summary

| Metric | Count |
|--------|-------|
| Scripts | 9 |
| Scenes | 13 |
| Resources | 2 |
| Registered Classes | 0 |
| Total Functions | 40 |
| Total Signals | 0 |
| Total Exports | 3 |
| Autoloads | 1 |