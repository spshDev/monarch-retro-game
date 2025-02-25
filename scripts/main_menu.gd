extends Control

@onready var play_button = $UI/Buttons/Play
@onready var tutorial_button = $UI/Buttons/Tutorial
@onready var quit_button = $UI/Buttons/Quit
@onready var blip_hover: AudioStreamPlayer2D = $BlipHover
@onready var click: AudioStreamPlayer2D = $Click

func _ready():
	_connect_buttons()
	_set_pivot_to_center()

func _connect_buttons():
	if play_button.pressed.is_connected(_on_play_pressed) == false:
		play_button.pressed.connect(_on_play_pressed)
	if tutorial_button.pressed.is_connected(_on_tutorial_pressed) == false:
		tutorial_button.pressed.connect(_on_tutorial_pressed)
	if quit_button.pressed.is_connected(_on_quit_pressed) == false:
		quit_button.pressed.connect(_on_quit_pressed)
	
	for button in [play_button, tutorial_button, quit_button]:
		if button.mouse_entered.is_connected(_on_button_hover.bind(button)) == false:
			button.mouse_entered.connect(_on_button_hover.bind(button))
		if button.mouse_exited.is_connected(_on_button_exit.bind(button)) == false:
			button.mouse_exited.connect(_on_button_exit.bind(button))


func _set_pivot_to_center():
	for button in [play_button, tutorial_button, quit_button]:
		button.pivot_offset = button.size / 2  # Set pivot to center

func _on_button_hover(button): # HoverState
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1.4, 1.4, 1.4, 1), 0.1).set_trans(Tween.TRANS_SINE) # Slight glow
	button.add_theme_color_override("font_color", Color(1, 1, 0.8))  # Light yellowish glow
	if Global.sfx == true:
		blip_hover.play() # Sound Effect

func _on_button_exit(button): # ExitState
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_SINE)  # Reset glow
	button.add_theme_color_override("font_color", Color(1, 1, 1))  # Reset text color to white

func _on_button_pressed(button, scene_path): # PressedState
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.05).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "modulate", Color(0.8, 0.8, 0.8, 1), 0.05).set_trans(Tween.TRANS_QUAD)  # Slight darkening effect
	tween.tween_property(button, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_QUAD)  # Reset color

	await get_tree().create_timer(0.15).timeout  # Small delay before scene change
	get_tree().change_scene_to_file(scene_path)

func _on_play_pressed():
	if Global.sfx == true:
		click.play()
	_on_button_pressed(play_button, "res://scenes/map.tscn")
	
func _on_tutorial_pressed():
	if Global.sfx == true:
		click.play()
	_on_button_pressed(tutorial_button, "res://scenes/tutorial.tscn")
	

func _on_quit_pressed():
	if Global.sfx == true:
		click.play()
	_on_button_pressed(quit_button, "")  # No scene, so just quit
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()
	
