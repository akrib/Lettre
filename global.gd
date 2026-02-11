extends Node

# ── Ancien système (chamallow / save) ──
var heart_speed := 800.0
var pipe_speed := 200.0
var game_time := 0.0
var chamallow := 0
var save_file := "user://scores.save"
var save_data: Dictionary = {}
var default_save_data: Dictionary = {
	"chamallow": 0,
	"current_chamallow": 0,
	"total_chamallow": 0,
	"max_dist": 0,
	"nb_run": 0,
	"total_dist": 0,
	"total_flights": 0,
	"upgrade_list": [
		1,1,1,1,1,
		1,1,1,1,1,
		1,1,1,1,1,
		1,1,1,1,1,
		1,1,1,1,1,
		1,1,1,1,1,1
	]
}

# ── Timeline ──
var player: CharacterBody2D = null
var is_paused := false
var scroll_speed := 80.0
var time_scale := 1.0
var _seen_events: Array[int] = []

var timeline_title: String = ""
var timeline_subtitle: String = ""
var timeline_end_message: String = ""
var timeline_events: Array = []

const TIMELINE_JSON_PATH := "res://data/timeline_data.json"


func _ready() -> void:
	load_score()
	_load_timeline()


func _process(_delta: float) -> void:
	pass


# ── Chargement du JSON timeline ──
func _load_timeline() -> void:
	if not FileAccess.file_exists(TIMELINE_JSON_PATH):
		push_error("Timeline JSON introuvable : " + TIMELINE_JSON_PATH)
		return

	var file := FileAccess.open(TIMELINE_JSON_PATH, FileAccess.READ)
	if not file:
		push_error("Impossible d'ouvrir : " + TIMELINE_JSON_PATH)
		return

	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error("Erreur JSON ligne %d : %s" % [json.get_error_line(), json.get_error_message()])
		return

	var data: Dictionary = json.data
	timeline_title = data.get("title", "Sans titre")
	timeline_subtitle = data.get("subtitle", "")
	timeline_end_message = data.get("end_message", "Fin.")
	timeline_events = data.get("events", [])

	print("Timeline chargée : ", timeline_events.size(), " événements")


# ── Save / Load ──
func save_score() -> void:
	var file := FileAccess.open(save_file, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()


func first_save() -> void:
	save_data = default_save_data.duplicate(true)
	save_score()


func load_score() -> void:
	if FileAccess.file_exists(save_file):
		var file := FileAccess.open(save_file, FileAccess.READ)
		if file:
			save_data = file.get_var()
			file.close()
	else:
		first_save()

	for key in default_save_data:
		if key not in save_data:
			save_data[key] = default_save_data[key]


# ── Events vus ──
func mark_event_seen(idx: int) -> void:
	if idx not in _seen_events:
		_seen_events.append(idx)


func is_event_seen(idx: int) -> bool:
	return idx in _seen_events
