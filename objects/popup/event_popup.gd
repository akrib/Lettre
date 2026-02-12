extends CanvasLayer
## Popup affichant les photos et le texte d'un événement de la timeline.
## S'ouvre quand l'avion touche la barre, se ferme au clic/touche.
## Maximum 3 photos visibles, centrées, avec particules sur les bords.

signal popup_closed

@onready var panel: PanelContainer = $Panel
@onready var photos_container: HBoxContainer = $Panel/MarginContainer/VBoxContainer/PhotosContainer
@onready var date_label: Label = $Panel/MarginContainer/VBoxContainer/DateLabel
@onready var description_label: Label = $Panel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var hint_label: Label = $Panel/MarginContainer/VBoxContainer/HintLabel
@onready var anim: AnimationPlayer = $AnimationPlayer

const MAX_VISIBLE_PHOTOS := 3
const PHOTO_W := 180.0
const PHOTO_H := 140.0

var _is_open := false
var _allow_close := false

# Teintes claires possibles pour les particules
var _sparkle_tints: Array[Color] = [
	Color(1.0, 0.7, 0.8, 1.0),    # rose
	Color(0.7, 0.9, 1.0, 1.0),    # bleu ciel
	Color(1.0, 0.95, 0.6, 1.0),   # jaune doux
	Color(0.75, 1.0, 0.8, 1.0),   # vert menthe
	Color(0.9, 0.75, 1.0, 1.0),   # lavande
	Color(1.0, 0.85, 0.65, 1.0),  # pêche
	Color(0.8, 0.9, 1.0, 1.0),    # bleu pastel
	Color(1.0, 0.8, 0.9, 1.0),    # rose pâle
]


func _ready() -> void:
	panel.visible = false
	layer = 10


func _unhandled_input(event: InputEvent) -> void:
	if not _is_open or not _allow_close:
		return

	if event is InputEventScreenTouch and event.pressed:
		close()
	elif event is InputEventKey and event.pressed:
		close()
	elif event is InputEventMouseButton and event.pressed:
		close()


# === Affichage ===

func show_event(event_data: Dictionary) -> void:
	_clear_photos()

	# Date et titre
	var date_text: String = event_data.get("date", "")
	var title_text: String = event_data.get("title", "")
	date_label.text = "%s — %s" % [date_text, title_text] if title_text else date_text

	# Description
	description_label.text = event_data.get("description", "")

	# Photos — maximum 3
	var photos: Array = event_data.get("photos", [])
	var visible_count := mini(photos.size(), MAX_VISIBLE_PHOTOS)
	for i in range(visible_count):
		_add_photo(photos[i])

	# Indication pour fermer
	hint_label.text = "Appuie pour continuer..."

	# Ouvrir avec animation
	panel.visible = true
	panel.modulate = Color(1, 1, 1, 0)
	_is_open = true
	_allow_close = false

	if anim:
		anim.play("show")
		await anim.animation_finished

	# Attendre que le layout soit résolu avant d'ajouter les particules
	await get_tree().process_frame
	await get_tree().process_frame
	_add_sparkles_to_all_photos()

	await get_tree().create_timer(0.4).timeout
	_allow_close = true


func close() -> void:
	if not _is_open:
		return

	_is_open = false
	_allow_close = false

	if anim:
		anim.play("hide")
		await anim.animation_finished

	panel.visible = false
	popup_closed.emit()


# === Gestion des photos ===

func _clear_photos() -> void:
	for child in photos_container.get_children():
		child.queue_free()


func _add_photo(path: String) -> void:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(PHOTO_W, PHOTO_H)
	wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	if not ResourceLoader.exists(path):
		push_warning("[Popup] Photo introuvable : %s" % path)
		var placeholder := ColorRect.new()
		placeholder.color = Color(0.3, 0.3, 0.3, 0.5)
		placeholder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		wrapper.add_child(placeholder)
		photos_container.add_child(wrapper)
		return

	var texture := load(path) as Texture2D
	if not texture:
		return

	var tex_rect := TextureRect.new()
	tex_rect.texture = texture
	tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrapper.add_child(tex_rect)

	photos_container.add_child(wrapper)


## Ajoute les particules APRÈS que le layout soit résolu,
## pour que la position globale soit correcte.
func _add_sparkles_to_all_photos() -> void:
	for child in photos_container.get_children():
		if child is Control:
			var tint: Color = _sparkle_tints[randi() % _sparkle_tints.size()]
			var particles := _create_edge_sparkles(child, tint)
			child.add_child(particles)


## Crée des particules qui émettent uniquement sur le bord de la photo.
## Utilise EMISSION_SHAPE_POINTS avec des points le long du périmètre.
func _create_edge_sparkles(target: Control, tint: Color) -> CPUParticles2D:
	var p := CPUParticles2D.new()

	p.emitting = true
	p.amount = 24
	p.lifetime = 1.8
	p.local_coords = true
	p.z_index = 5

	# Centré dans le wrapper
	var w := target.size.x if target.size.x > 0 else PHOTO_W
	var h := target.size.y if target.size.y > 0 else PHOTO_H
	p.position = Vector2(w * 0.5, h * 0.5)

	# ── Émission sur le périmètre via des points ──
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINTS
	var edge_points := PackedVector2Array()
	var edge_normals := PackedVector2Array()

	var hw := w * 0.5
	var hh := h * 0.5
	var steps := 28  # points répartis sur le bord

	# Bord haut
	for i in range(steps):
		var t := float(i) / float(steps)
		edge_points.append(Vector2(lerp(-hw, hw, t), -hh))
		edge_normals.append(Vector2(0, -1))
	# Bord bas
	for i in range(steps):
		var t := float(i) / float(steps)
		edge_points.append(Vector2(lerp(-hw, hw, t), hh))
		edge_normals.append(Vector2(0, 1))
	# Bord gauche
	for i in range(int(steps * 0.6)):
		var t := float(i) / float(int(steps * 0.6))
		edge_points.append(Vector2(-hw, lerp(-hh, hh, t)))
		edge_normals.append(Vector2(-1, 0))
	# Bord droit
	for i in range(int(steps * 0.6)):
		var t := float(i) / float(int(steps * 0.6))
		edge_points.append(Vector2(hw, lerp(-hh, hh, t)))
		edge_normals.append(Vector2(1, 0))

	p.emission_points = edge_points
	p.emission_normals = edge_normals

	# Les particules partent vers l'extérieur (suivent la normale)
	p.direction = Vector2(0, -1)
	p.spread = 45.0
	p.initial_velocity_min = 6.0
	p.initial_velocity_max = 18.0
	p.gravity = Vector2(0, -3)

	# Taille petite, scintillante
	p.scale_amount_min = 1.5
	p.scale_amount_max = 3.5

	# Courbe de taille : pétillement (apparaît/disparaît)
	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.0))
	scale_curve.add_point(Vector2(0.1, 1.0))
	scale_curve.add_point(Vector2(0.4, 0.5))
	scale_curve.add_point(Vector2(0.7, 1.0))
	scale_curve.add_point(Vector2(1.0, 0.0))
	p.scale_amount_curve = scale_curve

	# Couleur : teinte claire → transparent
	var gradient := Gradient.new()
	var start_col := tint
	start_col.a = 0.0
	var mid_col := tint
	mid_col.a = 0.85
	var end_col := tint
	end_col.a = 0.0
	gradient.offsets = PackedFloat32Array([0.0, 0.15, 0.85, 1.0])
	gradient.colors = PackedColorArray([start_col, mid_col, mid_col, end_col])
	p.color_ramp = gradient

	# Texture ronde lumineuse
	var tex := GradientTexture2D.new()
	var circle_grad := Gradient.new()
	circle_grad.set_color(0, Color.WHITE)
	circle_grad.set_color(1, Color.TRANSPARENT)
	tex.gradient = circle_grad
	tex.width = 12
	tex.height = 12
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	p.texture = tex

	return p
