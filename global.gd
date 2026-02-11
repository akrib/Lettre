extends Node
## Autoload singleton — charge les données de la timeline depuis le JSON
## et gère la sauvegarde de progression.

const TIMELINE_PATH := "res://data/timeline_data.json"
const SAVE_PATH := "user://save.json"

# Données de la timeline chargées depuis le JSON
var timeline_title := ""
var timeline_subtitle := ""
var timeline_end_message := ""
var timeline_events: Array[Dictionary] = []

# Données de sauvegarde
var save_data := {
	"events_seen": [],     # indices des événements déjà vus
	"total_flights": 0,
}

# Référence globale au joueur (assignée par le player lui-même)
var player: CharacterBody2D = null

# Vitesse de défilement du monde
var scroll_speed := 120.0
var is_paused := false


func _ready() -> void:
	_load_timeline()
	_load_save()


# --- Chargement du JSON ---

func _load_timeline() -> void:
	if not FileAccess.file_exists(TIMELINE_PATH):
		push_error("Fichier timeline introuvable : %s" % TIMELINE_PATH)
		return

	var file := FileAccess.open(TIMELINE_PATH, FileAccess.READ)
	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	file.close()

	if error != OK:
		push_error("Erreur JSON ligne %d : %s" % [json.get_error_line(), json.get_error_message()])
		return

	var data: Dictionary = json.data
	timeline_title = data.get("title", "Lettre à Béa")
	timeline_subtitle = data.get("subtitle", "")
	timeline_end_message = data.get("end_message", "")

	timeline_events.clear()
	for event in data.get("events", []):
		timeline_events.append(event as Dictionary)

	print("[Global] %d événements chargés." % timeline_events.size())


# --- Sauvegarde / Chargement ---

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()


func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
		save_data.merge(json.data, true)
	file.close()


func mark_event_seen(index: int) -> void:
	if index not in save_data["events_seen"]:
		save_data["events_seen"].append(index)
		save_game()
