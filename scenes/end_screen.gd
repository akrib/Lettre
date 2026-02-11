extends CanvasLayer
## Écran de fin — affiche le message final d'amour quand toute la timeline
## a été parcourue.

@onready var message_label: Label = $Panel/MarginContainer/VBoxContainer/MessageLabel
@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	layer = 20


func show_message(text: String) -> void:
	message_label.text = text

	if anim:
		anim.play("fade_in")
