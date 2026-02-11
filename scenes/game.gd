extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var timeline: Node2D = $Timeline
@onready var popup: CanvasLayer = $EventPopup
@onready var music: AudioStreamPlayer = $Music
@onready var end_screen: CanvasLayer = $EndScreen

var songs: Array[String] = [
	"res://music/airship_2.ogg",
	"res://music/arctic_breeze.ogg",
	"res://music/chipdisko.ogg",
	"res://music/jewels.ogg",
]

var _current_event_index := -1
var _events_visited: Array[int] = []
var _game_finished := false
var _allow_exit := false          # NOUVEAU : empêche la sortie immédiate
var _popup_open := false


func _ready() -> void:
	Global.is_paused = false
	Global.time_scale = 1.0
	Global.save_data["total_flights"] += 1
	_setup_music()
	_connect_signals()
	if end_screen:
		end_screen.visible = false


func _setup_music() -> void:
	songs.shuffle()
	var stream = load(songs[0])
	if stream:
		music.stream = stream
		music.volume_db = -10
		music.play()


func _connect_signals() -> void:
	player.dive_landed.connect(_on_player_dive_landed)
	player.returned_to_flight.connect(_on_player_returned)
	timeline.event_zone_entered.connect(_on_event_zone_entered)
	timeline.timeline_ended.connect(_on_timeline_ended)
	popup.popup_closed.connect(_on_popup_closed)


func _process(_delta: float) -> void:
	if _game_finished:
		return

	var is_flying: bool = (player.state == player.State.FLYING)
	Global.is_paused = not is_flying or _popup_open

	if Input.is_key_pressed(KEY_RIGHT) and is_flying:
		Global.time_scale = 5.0
	else:
		Global.time_scale = 1.0


func _on_event_zone_entered(event_index: int) -> void:
	_current_event_index = event_index


func _on_player_dive_landed() -> void:
	_popup_open = true

	var event_data: Dictionary = timeline.get_active_event()
	if event_data.is_empty():
		_popup_open = false
		player.resume_flight()
		return

	var idx: int = timeline.get_active_event_index()
	Global.mark_event_seen(idx)
	if idx not in _events_visited:
		_events_visited.append(idx)

	popup.show_event(event_data)


func _on_popup_closed() -> void:
	_popup_open = false
	_resume_after_popup()


func _resume_after_popup() -> void:
	player.resume_flight()


func _on_timeline_ended() -> void:
	if not _game_finished:
		_show_end_screen()


func _on_player_returned() -> void:
	pass


func _show_end_screen() -> void:
	_game_finished = true
	_allow_exit = false             # pas encore le droit de quitter
	Global.is_paused = true

	if end_screen:
		end_screen.visible = true
		if end_screen.has_method("show_message"):
			end_screen.show_message(Global.timeline_end_message)

	# Fade out musique
	var tween := create_tween()
	tween.tween_property(music, "volume_db", -80.0, 3.0)

	# Attend 3 secondes avant de permettre la sortie
	await get_tree().create_timer(3.0).timeout
	_allow_exit = true


func _input(event: InputEvent) -> void:
	if _game_finished and _allow_exit:
		if event is InputEventScreenTouch or event is InputEventKey or event is InputEventMouseButton:
			if event.is_pressed():
				get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
