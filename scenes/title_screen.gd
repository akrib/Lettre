extends Control
## Écran titre — affiche le nom du jeu et attend un appui pour lancer.

@onready var title_label: Label = $TitleLabel
@onready var subtitle_label: Label = $SubtitleLabel
@onready var prompt_label: Label = $PromptLabel
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var music: AudioStreamPlayer = $Music

var _can_start := false


func _ready() -> void:
	title_label.text = Global.timeline_title
	subtitle_label.text = Global.timeline_subtitle
	prompt_label.modulate = Color(1, 1, 1, 0)

	if anim:
		anim.play("intro")
		await anim.animation_finished

	_can_start = true
	_blink_prompt()


func _input(event: InputEvent) -> void:
	if not _can_start:
		return

	if event.is_pressed():
		_can_start = false
		_start_game()


func _start_game() -> void:
	if anim:
		anim.play("fade_out")
		await anim.animation_finished

	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _blink_prompt() -> void:
	while _can_start:
		var tween := create_tween()
		tween.tween_property(prompt_label, "modulate:a", 1.0, 0.6)
		tween.tween_property(prompt_label, "modulate:a", 0.3, 0.6)
		await tween.finished
