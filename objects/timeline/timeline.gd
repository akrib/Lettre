extends Node2D
## Génère et fait défiler la timeline à partir des données JSON.
## La timeline est une barre horizontale en bas de l'écran avec des panneaux
## (comme des panneaux de signalisation) qui dépassent, montrant les dates.
## Entre deux panneaux, le texte de l'événement associé au panneau de gauche.

@export_group("Apparence")
@export var bar_height := 6.0                  ## Épaisseur de la barre
@export var bar_color := Color(1, 1, 1, 0.7)  ## Couleur de la barre
@export var bar_y := 570.0                     ## Position Y de la barre
@export var sign_post_height := 55.0           ## Hauteur du poteau du panneau
@export var sign_panel_color := Color(0.2, 0.15, 0.35, 0.9)
@export var sign_text_color := Color.WHITE
@export var event_text_color := Color(0.9, 0.9, 0.85, 0.8)

@export_group("Espacement")
@export var sign_spacing := 500.0              ## Distance entre deux panneaux
@export var start_offset := 600.0              ## Décalage initial (les panneaux arrivent par la droite)

# --- Signaux ---
signal event_zone_entered(event_index: int)    ## Le joueur est au-dessus d'une zone

# --- Données internes ---
var events: Array[Dictionary] = []
var sign_nodes: Array[Node2D] = []
var is_scrolling := true
var _active_event_index := -1

@onready var display_size := get_viewport().get_visible_rect().size


func _ready() -> void:
	events = Global.timeline_events
	_build_timeline()


func _process(delta: float) -> void:
	if not is_scrolling or Global.is_paused:
		return

	var speed := Global.scroll_speed * delta

	for sign_node in sign_nodes:
		sign_node.position.x -= speed

	_update_active_zone()


# === CONSTRUCTION DE LA TIMELINE ===

func _build_timeline() -> void:
	if events.is_empty():
		push_warning("[Timeline] Aucun événement à afficher.")
		return

	for i in events.size():
		var sign_node := _create_sign(events[i], i)
		sign_node.position.x = start_offset + (i * sign_spacing)
		sign_node.position.y = bar_y
		add_child(sign_node)
		sign_nodes.append(sign_node)

	# Panneau de fin
	var end_sign := _create_end_sign()
	end_sign.position.x = start_offset + (events.size() * sign_spacing)
	end_sign.position.y = bar_y
	add_child(end_sign)
	sign_nodes.append(end_sign)


func _create_sign(event: Dictionary, index: int) -> Node2D:
	var root := Node2D.new()
	root.name = "Sign_%d" % index
	root.set_meta("event_index", index)

	# --- Segment de barre horizontal ---
	var bar_segment := ColorRect.new()
	bar_segment.size = Vector2(sign_spacing, bar_height)
	bar_segment.position = Vector2(0, -bar_height / 2.0)
	bar_segment.color = bar_color
	root.add_child(bar_segment)

	# --- Poteau vertical ---
	var post := Line2D.new()
	post.add_point(Vector2(0, 0))
	post.add_point(Vector2(0, -sign_post_height))
	post.width = 3.0
	post.default_color = Color.WHITE
	root.add_child(post)

	# --- Panneau (fond) ---
	var panel_bg := ColorRect.new()
	var panel_width := 100.0
	var panel_h := 28.0
	panel_bg.size = Vector2(panel_width, panel_h)
	panel_bg.position = Vector2(-panel_width / 2.0, -sign_post_height - panel_h)
	panel_bg.color = sign_panel_color
	root.add_child(panel_bg)

	# --- Bordure du panneau ---
	var border := ReferenceRect.new()
	border.size = panel_bg.size
	border.position = panel_bg.position
	border.border_color = Color.WHITE
	border.border_width = 2.0
	border.editor_only = false
	root.add_child(border)

	# --- Date sur le panneau ---
	var date_label := Label.new()
	date_label.text = event.get("date", "???")
	date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	date_label.size = Vector2(panel_width - 8, panel_h)
	date_label.position = Vector2(-panel_width / 2.0 + 4, -sign_post_height - panel_h + 2)
	date_label.add_theme_font_size_override("font_size", 13)
	date_label.add_theme_color_override("font_color", sign_text_color)
	date_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	root.add_child(date_label)

	# --- Texte de l'événement sur la barre ---
	var title_label := Label.new()
	title_label.text = event.get("title", "")
	title_label.position = Vector2(15, -30)
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", event_text_color)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	title_label.size = Vector2(sign_spacing - 40, 25)
	root.add_child(title_label)

	# --- Zone de détection (Area2D pour savoir quel événement est actif) ---
	var area := Area2D.new()
	area.name = "TriggerZone"
	area.collision_layer = 2
	area.collision_mask = 1
	area.set_meta("event_index", index)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(sign_spacing * 0.9, 150.0)
	collision.shape = shape
	collision.position = Vector2(sign_spacing * 0.45, -75.0)
	area.add_child(collision)

	area.body_entered.connect(_on_trigger_zone_body_entered.bind(index))
	root.add_child(area)

	return root


func _create_end_sign() -> Node2D:
	var root := Node2D.new()
	root.name = "Sign_End"

	# Poteau
	var post := Line2D.new()
	post.add_point(Vector2(0, 0))
	post.add_point(Vector2(0, -sign_post_height))
	post.width = 3.0
	post.default_color = Color.GOLD
	root.add_child(post)

	# Panneau cœur
	var panel_bg := ColorRect.new()
	var pw := 50.0
	var ph := 28.0
	panel_bg.size = Vector2(pw, ph)
	panel_bg.position = Vector2(-pw / 2.0, -sign_post_height - ph)
	panel_bg.color = Color(0.7, 0.1, 0.2, 0.9)
	root.add_child(panel_bg)

	var heart_label := Label.new()
	heart_label.text = "♥"
	heart_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heart_label.size = Vector2(pw, ph)
	heart_label.position = panel_bg.position
	heart_label.add_theme_font_size_override("font_size", 18)
	heart_label.add_theme_color_override("font_color", Color.WHITE)
	heart_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	root.add_child(heart_label)

	return root


# === DÉTECTION DE ZONE ACTIVE ===

func _update_active_zone() -> void:
	# Le joueur est à une position X fixe, on cherche quel panneau est sous lui
	if not Global.player:
		return

	var player_x := Global.player.global_position.x

	for i in sign_nodes.size() - 1:  # -1 pour exclure le panneau de fin
		var sign_x := sign_nodes[i].global_position.x
		var next_x := sign_x + sign_spacing

		if player_x >= sign_x and player_x < next_x:
			if _active_event_index != i:
				_active_event_index = i
				event_zone_entered.emit(i)
			return

	_active_event_index = -1


func _on_trigger_zone_body_entered(body: Node2D, event_index: int) -> void:
	if body.is_in_group("players"):
		_active_event_index = event_index


# === API ===

func get_active_event_index() -> int:
	return _active_event_index


func get_active_event() -> Dictionary:
	if _active_event_index >= 0 and _active_event_index < events.size():
		return events[_active_event_index]
	return {}


func pause() -> void:
	is_scrolling = false


func resume() -> void:
	is_scrolling = true
