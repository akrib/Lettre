extends Node
## Spawne des avions-banderoles un par un avec des intervalles aléatoires.
## Charge les messages depuis un fichier JSON.

@export var messages_path: String = "res://data/banner_messages.json"
@export var min_interval: float = 8.0     # délai min entre deux avions
@export var max_interval: float = 18.0    # délai max
@export var min_speed: float = 60.0       # vitesse min
@export var max_speed: float = 120.0      # vitesse max
@export var min_y: float = 40.0           # hauteur min (haut de l'écran)
@export var max_y: float = 340.0          # hauteur max (2/3 supérieur)

const BannerPlaneScene := preload("res://objects/banner_plane/banner_plane.tscn")

var _messages: Array = []
var _message_index: int = 0
var _current_plane: Node2D = null
var _timer: Timer


func _ready() -> void:
	_load_messages()
	_messages.shuffle()

	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_spawn_plane)
	add_child(_timer)

	# Premier spawn après un court délai
	_timer.start(randf_range(3.0, 6.0))


func _load_messages() -> void:
	if not FileAccess.file_exists(messages_path):
		push_warning("[BannerSpawner] Fichier introuvable : %s" % messages_path)
		_messages = [
			"Bon voyage !",
			"Profite du ciel !",
			"L'aventure continue...",
		]
		return

	var file := FileAccess.open(messages_path, FileAccess.READ)
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_warning("[BannerSpawner] Erreur JSON : %s" % json.get_error_message())
		return

	var data = json.data
	if data is Dictionary and data.has("messages"):
		_messages = data["messages"]
	elif data is Array:
		_messages = data
	else:
		push_warning("[BannerSpawner] Format JSON inattendu")


func _spawn_plane() -> void:
	if Global.is_paused:
		# Réessayer plus tard si le jeu est en pause
		_timer.start(2.0)
		return

	if _messages.is_empty():
		return

	# Prendre le prochain message (boucle circulaire)
	var msg: String = _messages[_message_index % _messages.size()]
	_message_index += 1
	if _message_index >= _messages.size():
		_messages.shuffle()
		_message_index = 0

	# Paramètres aléatoires
	var spd := randf_range(min_speed, max_speed)
	var y_pos := randf_range(min_y, max_y)

	# Créer l'avion
	var plane := BannerPlaneScene.instantiate()
	plane.setup(msg, spd, y_pos)
	plane.position.x = get_viewport().get_visible_rect().size.x + 300
	plane.exited_screen.connect(_on_plane_exited)

	_current_plane = plane
	get_parent().add_child(plane)


func _on_plane_exited() -> void:
	_current_plane = null
	# Planifier le prochain avion
	_timer.start(randf_range(min_interval, max_interval))
