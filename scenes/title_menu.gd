extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#if Global.scores.size() > 0 :
		#Global.save_score()
		#Global.scores.sort();
		#Global.scores.reverse()
		#$high_scores.text = "High Scores"
		#
		#var i = 0
		#for s in Global.scores:
			#i += 1
			#if i > 8:
				#break
			#if s != 0:
				#$high_scores.text += "\n" + str(s)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func _input(event):
	if event.is_pressed():
		$AnimationPlayer.play("start_game")
		
func start_game():
	get_tree().change_scene_to_file("res://maps/map_01.tscn")
