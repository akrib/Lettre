extends Node2D
## Petit avion tirant une banderole avec un message.
## Traverse l'écran de droite à gauche à une vitesse variable.
## L'avion est devant (à gauche), la bannière traîne derrière (à droite).

signal exited_screen

@export var speed: float = 80.0

var _message: String = ""
var _airplane_sprite: Sprite2D
var _rope_line: Line2D
var _banner_bg: ColorRect
var _banner_label: Label
var _moving := true
var _total_width := 0.0

# Spritesheet : 6 colonnes × 4 lignes, 100×64 px
const SHEET_COLS := 6
const SHEET_ROWS := 4
const SHEET_W := 100.0
const SHEET_H := 64.0
const FRAME_W := SHEET_W / SHEET_COLS   # ≈16.67
const FRAME_H := SHEET_H / SHEET_ROWS   # =16

var _bob_time := 0.0
var _base_y := 0.0


func setup(msg: String, fly_speed: float, y_pos: float) -> void:
	_message = msg
	speed = fly_speed
	_base_y = y_pos


func _ready() -> void:
	var col := randi() % SHEET_COLS
	var row := randi() % SHEET_ROWS

	_build_airplane(col, row)
	_build_banner()
	_build_rope()

	if _base_y > 0:
		position.y = _base_y


func _process(delta: float) -> void:
	if not _moving:
		return

	# ── Accélère avec le time_scale global ──
	var effective_speed := speed * Global.time_scale

	# Déplacement vers la gauche
	position.x -= effective_speed * delta

	# Léger balancement vertical
	_bob_time += delta
	var bob := sin(_bob_time * 1.8) * 3.0
	_airplane_sprite.position.y = bob

	# Vérifier sortie d'écran (tout le contenu est sorti à gauche)
	if position.x < -(_total_width + 100):
		exited_screen.emit()
		queue_free()


## Avion à x=0, flippé pour regarder vers la gauche
func _build_airplane(col: int, row: int) -> void:
	_airplane_sprite = Sprite2D.new()

	var sheet_tex := load("res://data/assets/airplanes.png") as Texture2D
	if not sheet_tex:
		push_warning("[BannerPlane] airplanes.png introuvable")
		return

	var atlas := AtlasTexture.new()
	atlas.atlas = sheet_tex
	atlas.region = Rect2(
		col * FRAME_W,
		row * FRAME_H,
		FRAME_W,
		FRAME_H
	)

	_airplane_sprite.texture = atlas
	_airplane_sprite.scale = Vector2(3.0, 3.0)
	_airplane_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Les sprites du spritesheet pointent vers la droite → on flip
	#_airplane_sprite.flip_h = true
	add_child(_airplane_sprite)


## Bannière derrière l'avion (à droite, x positif)
func _build_banner() -> void:
	var font := ThemeDB.fallback_font
	var font_size := 14
	var text_size := font.get_string_size(_message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var banner_w := text_size.x + 30.0
	var banner_h := 26.0

	# Position : après l'avion + un espace pour la corde
	var banner_x := 40.0
	var banner_y := -banner_h * 0.5

	# Fond de la bannière
	_banner_bg = ColorRect.new()
	_banner_bg.size = Vector2(banner_w, banner_h)
	_banner_bg.position = Vector2(banner_x, banner_y)
	_banner_bg.color = Color(1.0, 0.97, 0.88, 0.92)
	add_child(_banner_bg)

	# Bordure fine
	var border_top := ColorRect.new()
	border_top.size = Vector2(banner_w, 1.5)
	border_top.position = Vector2(banner_x, banner_y)
	border_top.color = Color(0.7, 0.6, 0.5, 0.6)
	add_child(border_top)

	var border_bot := ColorRect.new()
	border_bot.size = Vector2(banner_w, 1.5)
	border_bot.position = Vector2(banner_x, banner_y + banner_h - 1.5)
	border_bot.color = Color(0.7, 0.6, 0.5, 0.6)
	add_child(border_bot)

	# Texte du message
	_banner_label = Label.new()
	_banner_label.text = _message
	_banner_label.position = Vector2(banner_x + 10, banner_y + 1)
	_banner_label.size = Vector2(banner_w - 20, banner_h - 2)
	_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_banner_label.add_theme_font_size_override("font_size", font_size)
	_banner_label.add_theme_color_override("font_color", Color(0.15, 0.1, 0.05))
	_banner_label.add_theme_color_override("font_shadow_color", Color(1, 1, 1, 0.3))
	_banner_label.add_theme_constant_override("shadow_offset_x", 1)
	_banner_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(_banner_label)

	# Largeur totale pour le check de sortie
	_total_width = banner_x + banner_w


## Corde entre l'arrière de l'avion et le début de la bannière
func _build_rope() -> void:
	_rope_line = Line2D.new()
	_rope_line.width = 1.5
	_rope_line.default_color = Color(0.55, 0.45, 0.35, 0.7)
	# De la queue de l'avion (côté droit puisqu'il est flippé) à la bannière
	_rope_line.add_point(Vector2(22, 2))     # queue de l'avion
	_rope_line.add_point(Vector2(40, 0))     # début bannière
	add_child(_rope_line)
