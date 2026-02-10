extends Node

var heart_speed = 800.0
var pipe_speed = 200.0
var player 
var game_time = 0.0
#var scores = []
var chamallow = 0
var default_save_data = {
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
var save_data = {}


var save_file = "user://scores.save"

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	#save_score(default_save_data)
	load_score()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	heart_speed += delta
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

func save_score():
	var cfgFile = FileAccess.open(save_file,FileAccess.WRITE)
	cfgFile.store_line(JSON.stringify(save_data))
	cfgFile.close()

func first_save():
	var cfgFile = FileAccess.open(save_file,FileAccess.WRITE)
	cfgFile.store_line(JSON.stringify(default_save_data))
	cfgFile.close()

func load_score():
	if !FileAccess.file_exists(save_file):
		first_save()
		return
	var cfgFile = FileAccess.open(save_file,FileAccess.READ)
	var data = JSON.parse_string(cfgFile.get_as_text())
	save_data = data
	print("load save data",save_data)
	#save_data["chamallow"] = int(data["chamallow"])
	#save_data["max_dist"] = int(data["max_dist"])
	#save_data["item_01_available"] = data["item_01_available"]
	#save_data["item_02_available"] = data["item_02_available"]
	#save_data["item_03_available"] = data["item_03_available"] 
	#save_data["item_04_available"] = data["item_04_available"] 
	#save_data["item_05_available"] = data["item_05_available"]
	#save_data["item_06_available"] = data["item_06_available"]
	#save_data["item_07_available"] = data["item_07_available"]
	#save_data["item_08_available"] = data["item_08_available"]
	#save_data["item_09_available"] = data["item_09_available"]
	#save_data["item_10_available"] = data["item_10_available"]
	#save_data["item_11_available"] = data["item_11_available"]
	#save_data["item_12_available"] = data["item_11_available"]
	#save_data["item_13_available"] = data["item_13_available"]
	#save_data["item_14_available"] = data["item_14_available"]
	#save_data["item_15_available"] = data["item_15_available"]
	#save_data["item_16_available"] = data["item_16_available"]
	#save_data["item_17_available"] = data["item_17_available"]
	#save_data["item_18_available"] = data["item_18_available"]
	#save_data["item_19_available"] = data["item_19_available"]
	#save_data["item_20_available"] = data["item_20_available"]
	#return save_data
