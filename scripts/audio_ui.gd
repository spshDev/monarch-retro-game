extends Control

@onready var blip_hover: AudioStreamPlayer2D = $"../BlipHover"
@onready var click: AudioStreamPlayer2D = $"../Click"

# BUTTONS
@onready var sfx: Button = $sfx
@onready var music: Button = $Music

# OFF STATES
const AUDIO_OFF = preload("res://assets/audioOff.png")
const MUSIC_OFF = preload("res://assets/musicOff.png")

# ON STATES
const AUDIO_ON = preload("res://assets/audioOn.png")
const MUSIC_ON = preload("res://assets/musicOn.png")

# Button animations
func _ready():
	_connect_buttons()
	_set_pivot_to_center()

func _connect_buttons():
	if sfx.pressed.is_connected(_on_sfx_pressed) == false:
		sfx.pressed.connect(_on_sfx_pressed)
	if music.pressed.is_connected(_on_music_pressed) == false:
		music.pressed.connect(_on_music_pressed)
	
	for button in [sfx, music]:
		if button.mouse_entered.is_connected(_on_button_hover.bind(button)) == false:
			button.mouse_entered.connect(_on_button_hover.bind(button))
		if button.mouse_exited.is_connected(_on_button_exit.bind(button)) == false:
			button.mouse_exited.connect(_on_button_exit.bind(button))

func _set_pivot_to_center():
	for button in [sfx, music]:
		button.pivot_offset = button.size / 2  # Set pivot to center

func _on_button_hover(button): # HoverState
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(0.7, 0.7), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(0.7, 0.7, 0.7, 1), 0.1).set_trans(Tween.TRANS_SINE) # Slight glow
	if Global.sfx == true:
		blip_hover.play() # Sound Effect

func _on_button_exit(button): # ExitState
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(0.5, 0.5), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_SINE)  # Reset glow

func _on_button_pressed(button, scene_path): # PressedState
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.05).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "modulate", Color(0.25, 0.25, 0.25, 1), 0.05).set_trans(Tween.TRANS_QUAD)  # Slight darkening effect
	tween.tween_property(button, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "modulate", Color(0, 0, 0, 1), 0.1).set_trans(Tween.TRANS_QUAD)  # Reset color

	await get_tree().create_timer(0.2).timeout  # Small delay before scene change
	get_tree().change_scene_to_file(scene_path)

# SFX
func _on_sfx_pressed() -> void:
	if Global.sfx == true:
		click.play()
		Global.sfx = false
	else:
		Global.sfx = true

# MUSIC
func _on_music_pressed() -> void:
	if Global.Music == true:
		click.play()
		Global.Music = false
	else:
		Global.Music = true

# Icon toggle
func _process(delta: float) -> void:
	if Global.Music == true:
		music.icon = MUSIC_ON
	else:
		music.icon = MUSIC_OFF
		
	if Global.sfx == true:
		sfx.icon = AUDIO_ON
	else:
		sfx.icon = AUDIO_OFF
		
		
		
