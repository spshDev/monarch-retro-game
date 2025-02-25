extends Area2D

@export var target_node: NodePath  # The node to apply the effect on
@export var glow_color: Color = Color(1.4, 1.4, 1.4, 1)  # Slight glow effect
@export var grow_scale: float = 1.15  # Scale multiplier on hover
@export var hover_duration: float = 0.15  # Tween duration
@onready var blip_hover: AudioStreamPlayer2D = $"../../blipHover"

var original_color: Color
var original_scale: Vector2
var target: Node

func _ready():
	if target_node:
		target = get_node(target_node)
		original_color = target.modulate
		original_scale = target.scale
	
	connect("mouse_entered", Callable(self, "_on_hover"))
	connect("mouse_exited", Callable(self, "_on_exit"))

func _on_hover(): # HoverState
	if not target: return
	var tween = get_tree().create_tween()
	tween.tween_property(target, "modulate", glow_color, hover_duration).set_trans(Tween.TRANS_SINE) # Glow
	tween.tween_property(target, "scale", original_scale * grow_scale, hover_duration).set_trans(Tween.TRANS_SINE) # Scale
	blip_hover.play() # SoundEffect

func _on_exit(): # ExitState
	if not target: return
	var tween = get_tree().create_tween()
	tween.tween_property(target, "modulate", original_color, hover_duration).set_trans(Tween.TRANS_SINE) # Glow
	tween.tween_property(target, "scale", original_scale, hover_duration).set_trans(Tween.TRANS_SINE) # Scale
