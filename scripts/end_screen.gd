extends Control

@onready var replay_button: Button = $ReplayButton
@onready var menu_button: Button = $MenuButton
@onready var exit_button: Button = $ExitButton
@onready var click: AudioStreamPlayer2D = $Click
@onready var blip_hover: AudioStreamPlayer2D = $blipHover


func _ready():
	_connect_buttons()
	_set_pivot_to_center()

func _connect_buttons():
	if replay_button.pressed.is_connected(_on_replay_button_pressed) == false:
		replay_button.pressed.connect(_on_replay_button_pressed)
	if menu_button.pressed.is_connected(_on_menu_button_pressed) == false:
		menu_button.pressed.connect(_on_menu_button_pressed)
	if exit_button.pressed.is_connected(_on_exit_button_pressed) == false:
		exit_button.pressed.connect(_on_exit_button_pressed)
	
	for button in [replay_button, menu_button, exit_button]:
		if button.mouse_entered.is_connected(_on_button_hover.bind(button)) == false:
			button.mouse_entered.connect(_on_button_hover.bind(button))
		if button.mouse_exited.is_connected(_on_button_exit.bind(button)) == false:
			button.mouse_exited.connect(_on_button_exit.bind(button))


func _set_pivot_to_center():
	for button in [replay_button, menu_button, exit_button]:
		button.pivot_offset = button.size / 2  # Set pivot to center

func _on_button_hover(button): # HoverState
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(1.3, 1.3), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(0.25, 0.25, 0.25, 1), 0.1).set_trans(Tween.TRANS_SINE) # Slight glow
	blip_hover.play() # Sound Effect

func _on_button_exit(button): # ExitState
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(0, 0, 0, 1), 0.1).set_trans(Tween.TRANS_SINE)  # Reset glow

func _on_button_pressed(button, scene_path): # PressedState
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.05).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "modulate", Color(0.25, 0.25, 0.25, 1), 0.05).set_trans(Tween.TRANS_QUAD)  # Slight darkening effect
	tween.tween_property(button, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "modulate", Color(0, 0, 0, 1), 0.1).set_trans(Tween.TRANS_QUAD)  # Reset color

	await get_tree().create_timer(0.2).timeout  # Small delay before scene change
	get_tree().change_scene_to_file(scene_path)


func _on_replay_button_pressed() -> void:
	click.play()
	_on_button_pressed(replay_button, "res://scenes/map.tscn")


func _on_menu_button_pressed() -> void:
	click.play()
	_on_button_pressed(menu_button, "res://scenes/main_menu.tscn")


func _on_exit_button_pressed() -> void:
	click.play()
	_on_button_pressed(exit_button, "")  # No scene, so just quit
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()


# SCORES AND HISCORE
func _process(_delta: float) -> void:
	$CurrentScore.text = "SCORE: " + str(SaveLoad.year) + "YRS"
	$Highscore.text = "BEST: " + str(SaveLoad.hiscore) + "YRS"
	
