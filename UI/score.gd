extends Label

@onready var player = get_tree().get_nodes_in_group("players")[0]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass


func update_score():
	if player.data["chamallow"] < player.data["current_chamallow"]:
		player.data["chamallow"] += 10
		#$sound.play(0)
		
	text = "Chamallow : " + str(round(player.data["chamallow"]))
