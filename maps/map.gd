extends Node2D

@export var hearts = preload("res://objects/heart/heart.tscn")

@onready var display_size = get_viewport().get_visible_rect().size
var game_over = false
var allow_restart = false
var game_started = false   # le jeu attend la fin du looping d'entrée

var songs = [
	"res://music/airship_2.ogg",
	"res://music/arctic_breeze.ogg",
	"res://music/chipdisko.ogg",
	"res://music/jewels.ogg"
]

func _ready():
	$ShopLayer/Panel.hide()
	$black.visible = false
	$player.data = Global.save_data
	randomize()
	songs.shuffle()
	$music.stream = load(songs[0])
	$music.play()
	$music.volume_db = -10
	Global.pipe_speed = 200.0
	Global.game_time = 0.0
	Global.save_data["nb_run"] += 1
	
	# --- Looping d'entrée ---
	$PipeTimer.stop()                           # on attend la fin du loop
	$player.loop_finished.connect(_on_entry_loop_done, CONNECT_ONE_SHOT)
	$player.start_entry_loop($player.position)  # la position du .tscn est la cible
	
	# Connecter le bouton X du shop pour le fermer
	var close_btn = $ShopLayer/Panel/PetShop/HBoxContainer/TextureButton
	if not close_btn.pressed.is_connected(_on_shop_close_pressed):
		close_btn.pressed.connect(_on_shop_close_pressed)

func _on_entry_loop_done():
	game_started = true
	$PipeTimer.start()

func _process(delta):
	if not game_started:
		return
	Global.game_time += delta
	player_dead(delta)

func player_dead(delta):
	if !$player.dead:
		$MagasinButton.hide()
		$player.data["current_chamallow"] += (Global.heart_speed * delta) / 100
		return
	
	if !game_over:
		Global.save_data = $player.data
		Global.save_score()
		game_over = true
		$black.visible = true
		$AnimationPlayer.play("death")
		$MagasinButton.show()

func enable_restart():
	allow_restart = true

func create_pipe():
	var heart = hearts.instantiate()
	heart.position.x = display_size.x + 128
	heart.position.y += randi_range(-200, 200)
	heart.top_pos += Global.game_time
	if $PipeTimer.wait_time > 1.5:
		$PipeTimer.wait_time -= .1
	get_tree().current_scene.add_child(heart)

func _input(event):
	if event is InputEventScreenTouch:
		$exit.visible = true
	if allow_restart:
		if event is InputEventScreenTouch || event is InputEventKey || event is InputEventMouseButton:
			get_tree().change_scene_to_file("res://scenes/title_menu.tscn")

func _on_exit_pressed():
	get_tree().quit()

func _on_store_button_pressed():
	if $ShopLayer/Panel.visible:
		$ShopLayer/Panel.hide()

func _on_magasin_button_pressed():
	$ShopLayer/Panel.show()
	$ShopLayer/Panel/PetShop/GridContainer.get_child(0).grab_focus()

func _on_shop_close_pressed():
	$ShopLayer/Panel.hide()
