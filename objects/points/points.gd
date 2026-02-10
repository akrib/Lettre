extends Sprite2D

var speed = 150
var growth = .1
var life = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector2(.2,.2)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life += delta
	if life > 1:
		queue_free()
	scale += Vector2(growth*delta,growth*delta)
	position.y -= speed * delta
