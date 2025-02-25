extends Control

@onready var back_button = $Back  # Ensure correct path
@onready var blip_hover: AudioStreamPlayer2D = $blipHover
@onready var click: AudioStreamPlayer2D = $Click

func _ready():
	_set_pivot_to_center()
	_connect_button()

func _set_pivot_to_center():
	back_button.pivot_offset = back_button.size / 2  # Ensure pivot is centered

func _connect_button():
	if not back_button.pressed.is_connected(_on_back_pressed):
		back_button.pressed.connect(_on_back_pressed)
	if not back_button.mouse_entered.is_connected(_on_button_hover):
		back_button.mouse_entered.connect(_on_button_hover)
	if not back_button.mouse_exited.is_connected(_on_button_exit):
		back_button.mouse_exited.connect(_on_button_exit)

func _on_button_hover(): # HoverState
	var tween = back_button.create_tween()
	tween.tween_property(back_button, "scale", Vector2(2.5, 2.5), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(back_button, "modulate", Color(1.5, 1.5, 1.5, 1), 0.1).set_trans(Tween.TRANS_SINE)  # Light glow
	back_button.pivot_offset = back_button.size / 2  # **Reapply pivot after scaling**
	if Global.sfx == true:
		blip_hover.play() # SoundEffect

func _on_button_exit(): # ExitState
	var tween = back_button.create_tween()
	tween.tween_property(back_button, "scale", Vector2(2, 2), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(back_button, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_SINE)  # Reset glow
	back_button.pivot_offset = back_button.size / 2  # **Ensure pivot stays centered**

func _on_back_pressed(): # PressedState
	if Global.sfx == true:
		click.play()
	var tween = back_button.create_tween()
	tween.tween_property(back_button, "scale", Vector2(1.9, 1.9), 0.05).set_trans(Tween.TRANS_QUAD)  # Snappy press effect
	tween.tween_property(back_button, "modulate", Color(0.8, 0.8, 0.8, 1), 0.05).set_trans(Tween.TRANS_QUAD)  # Slight darkening
	tween.tween_property(back_button, "scale", Vector2(2, 2), 0.1).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(back_button, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_QUAD)  # Reset color

	await get_tree().create_timer(0.15).timeout  # Small delay before scene change
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
