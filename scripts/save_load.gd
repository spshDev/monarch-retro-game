extends Node

# SAVE PATH
const SAVEFILE = "user://savefile.save"

var year = 1
var hiscore = 1

func _ready() -> void:
	load_score()

# SAVE AND LOAD DATA
func save_score():
	var file = FileAccess.open(SAVEFILE, FileAccess.WRITE_READ)
	file.store_32(hiscore)
	
func load_score():
	var file = FileAccess.open(SAVEFILE, FileAccess.READ)
	if FileAccess.file_exists(SAVEFILE):
		hiscore = file.get_32()
