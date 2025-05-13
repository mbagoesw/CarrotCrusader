extends Node

var player_name: String = ""  # Default name
var tutorial_seen = false  # Default is false

func set_player_name(name: String):
	player_name = name

func save_tutorial():
	var file = FileAccess.open("user://tutorial_data.cfg", FileAccess.WRITE)
	file.store_var(tutorial_seen)
	file.close()

func load_tutorial():
	if FileAccess.file_exists("user://tutorial_data.cfg"):
		var file = FileAccess.open("user://tutorial_data.cfg", FileAccess.READ)
		tutorial_seen = file.get_var()
		file.close()
