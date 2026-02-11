extends Node2D
## Scène principale du jeu.
## Orchestre le joueur, la timeline, le popup et la musique.

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


func _ready() -> void:
	Global.is_paused = false
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
	# Quand l'avion plonge et touche la timeline
	player.dive_landed.connect(_on_player_dive_landed)
	player.returned_to_flight.connect(_on_player_returned)

	# Quand la zone de timeline change
	timeline.event_zone_entered.connect(_on_event_zone_entered)

	# Quand le popup se ferme
	popup.popup_closed.connect(_on_popup_closed)


# === Réactions aux signaux ===

func _on_event_zone_entered(event_index: int) -> void:
	_current_event_index = event_index


func _on_player_dive_landed() -> void:
	# Pause le défilement
	Global.is_paused = true
	timeline.pause()

	# Récupère l'événement actif
	var event_data: Dictionary = timeline.get_active_event()
	if event_data.is_empty():
		# Pas d'événement ici, on remonte directement
		_resume_after_popup()
		return

	# Marque comme vu
	var idx: int = timeline.get_active_event_index()
	Global.mark_event_seen(idx)

	if idx not in _events_visited:
		_events_visited.append(idx)

	# Affiche le popup
	popup.show_event(event_data)


func _on_popup_closed() -> void:
	_resume_after_popup()


func _resume_after_popup() -> void:
	# Vérifie si c'était le dernier événement
	if _events_visited.size() >= Global.timeline_events.size() and not _game_finished:
		_show_end_screen()
		return

	Global.is_paused = false
	timeline.resume()
	player.resume_flight()


func _on_player_returned() -> void:
	# L'avion est revenu en altitude, tout continue
	pass


# === Fin du jeu ===

func _show_end_screen() -> void:
	_game_finished = true

	if end_screen:
		end_screen.visible = true
		# Le end_screen gère son propre affichage du message final
		if end_screen.has_method("show_message"):
			end_screen.show_message(Global.timeline_end_message)

	# Fade out la musique
	var tween := create_tween()
	tween.tween_property(music, "volume_db", -80.0, 3.0)


# === Input global ===

func _input(event: InputEvent) -> void:
	if _game_finished:
		if event is InputEventScreenTouch or event is InputEventKey or event is InputEventMouseButton:
			if event.is_pressed():
				get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
