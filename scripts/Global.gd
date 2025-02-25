extends Node

var Music = true
var sfx = true

func _ready() -> void:
	Music = true
	sfx = true

func _process(delta: float) -> void:
	if Music == true:
		Bgm.volume_db = -5
	else:
		Bgm.volume_db = -80
