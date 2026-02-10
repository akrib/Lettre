extends CharacterBody2D


@export var gravity = 9.0
@export var flap_force: int = -6
@onready var sprite = $Sprite
@onready var display_size = get_viewport().get_visible_rect().size

var dead = false
var max_speed = 400
var rotation_speed = 2
var data = {
	"chamallow": 0,
	"current_chamallow": 0,
	"total_chamallow": 0,
	"max_dist": 0,
	"nb_run": 0,
	"total_dist" : 0, 
	"upgrade_list": [1,1,1,1,1,
					1,1,1,1,1,
					1,1,1,1,1,
					1,1,1,1,1,
					1,1,1,1,1,
					1,1,1,1,1,1]
}


func _ready():
	Global.player = self
	velocity = Vector2.ZERO
	

func _physics_process(delta):
	if dead:
		return
		
	velocity.y += gravity * delta
	
	if velocity.y > max_speed:
		velocity.y = max_speed
		
	if position.y > display_size.y + 128 || position.y < -128:
		death()
	
	move_and_collide(velocity * delta)
	rotate_bird()
	
func _input(event):
	if event.is_pressed():
		flap()
		
func flap():
	sprite.play("fly")
	$flap.stop()
	$flap.play()
	velocity.y = flap_force

func rotate_bird():
	# downwards  
	if velocity.y > 0 and rad_to_deg(rotation) < 90:
		sprite.play("fall")
		rotation += rotation_speed * deg_to_rad(0.01)
	# upwards 
	elif velocity.y < 0 and rad_to_deg(rotation) > -10:
		sprite.play("default")
		rotation -= (rotation_speed * deg_to_rad(1) * 0.2)


func death():
	#Global.score.append(current_score)
	dead = true
	$death.play()
	sprite.stop()
	gravity = 0
	velocity = Vector2.ZERO
	
func bounce():
	velocity.y = flap_force*8
	sprite.play("default")
	if velocity.y < 0 and rad_to_deg(rotation) > -20:
		rotation -= (rotation_speed * deg_to_rad(1) * 0.6)
