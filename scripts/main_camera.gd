extends Camera2D

@export var decay : float = 0.8
@export var max_offset : Vector2 = Vector2(100, 75)
@export var max_roll : float = 0.1
@export var follow_node : Node2D


var trauma : float = 0.0
var trauma_power : float = 1.5

func _ready() -> void:
	randomize()

func shake():
	anchor_mode = ANCHOR_MODE_FIXED_TOP_LEFT
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)
	
func _process(delta: float) -> void:
	if follow_node:
		global_position = follow_node.position
		
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
