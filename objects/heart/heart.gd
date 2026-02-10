extends Node2D

@onready var player = get_tree().get_nodes_in_group("players")[0]
@onready var points = preload("res://objects/points/points.tscn")

var top_pos = 300
var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$heart_sprite.position.y += top_pos
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.dead:
		return
	position.x -= Global.heart_speed * delta


func crash(body):
	$heart_sprite.play("explode")
	if body.is_in_group("players"):
		body.bounce()
		

func remove():
	queue_free()


#func _on_points_body_entered(body):
	#if body.is_in_group("players"):
		#player.current_score += 100
		#var point = points.instantiate()
		#point.position = player.position
		#point.position.y -= 50
		#get_tree().current_scene.add_child(point)


func _on_heart_sprite_animation_finished():
	if $heart_sprite.current_animation == "explode":
		remove()
