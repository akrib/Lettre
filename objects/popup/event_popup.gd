extends CanvasLayer
## Popup affichant les photos et le texte d'un événement de la timeline.
## S'ouvre quand l'avion touche la barre, se ferme au clic/touche.

signal popup_closed

@onready var panel: PanelContainer = $Panel
@onready var photos_container: HBoxContainer = $Panel/MarginContainer/VBoxContainer/PhotosContainer
@onready var date_label: Label = $Panel/MarginContainer/VBoxContainer/DateLabel
@onready var description_label: Label = $Panel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var hint_label: Label = $Panel/MarginContainer/VBoxContainer/HintLabel
@onready var anim: AnimationPlayer = $AnimationPlayer

var _is_open := false
var _allow_close := false


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

	# Photos
	var photos: Array = event_data.get("photos", [])
	for photo_path in photos:
		_add_photo(photo_path)

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

	# Petit délai avant de pouvoir fermer (évite la fermeture accidentelle)
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
	if not ResourceLoader.exists(path):
		push_warning("[Popup] Photo introuvable : %s" % path)
		var placeholder := ColorRect.new()
		placeholder.color = Color(0.3, 0.3, 0.3, 0.5)
		placeholder.custom_minimum_size = Vector2(180, 140)
		photos_container.add_child(placeholder)
		return

	var texture := load(path) as Texture2D
	if not texture:
		return

	var tex_rect := TextureRect.new()
	tex_rect.texture = texture
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.custom_minimum_size = Vector2(220, 180)
	tex_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	photos_container.add_child(tex_rect)
