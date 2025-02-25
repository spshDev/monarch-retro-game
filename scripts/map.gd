extends Node2D

#=============================== VARIABLES =====================================

var renewTime = 2

# Sound Effects
@onready var blip_hover: AudioStreamPlayer2D = $blipHover
@onready var blip_buzzer: AudioStreamPlayer2D = $blipBuzzer
@onready var click: AudioStreamPlayer2D = $Click
@onready var screen_shake: AudioStreamPlayer2D = $screenShake


# Game States
var famine = false
var war = false
var revolt = false

# Scores
var food = 0
var army = 0
var religion = 0
@onready var score_timer: Timer = $ScoreTimer


# Clicker Mechanics References
@onready var food_score: Label = $SCORE/FOOD/FoodScore
@onready var army_score: Label = $SCORE/ARMY/ArmyScore
@onready var religion_score: Label = $SCORE/RELIGION/ReligionScore
@onready var score: Label = $Score
@onready var food_button = $SCORE/FOOD
@onready var army_button = $SCORE/ARMY
@onready var religion_button = $SCORE/RELIGION
# Constants for original scale (so scaling happens properly)
const ORIGINAL_SCALE = Vector2(3, 3)  # Since all buttons have scale 3x3
const HOVER_SCALE = Vector2(3.3, 3.3)  # Slightly larger on hover
const PRESS_SCALE = Vector2(2.9, 2.9)  # Slightly smaller on press

# Buttons
@onready var ration: Button = $ClickerMechanics/Ration
@onready var military: Button = $ClickerMechanics/Military
@onready var church: Button = $ClickerMechanics/Church

# Timers
@onready var church_timer: Timer = $ClickerMechanics/ChurchTimer
@onready var ration_timer: Timer = $ClickerMechanics/RationTimer
@onready var military_timer: Timer = $ClickerMechanics/MilitaryTimer

# HourGlasses
@onready var ration_wait: AnimatedSprite2D = $ClickerMechanics/RationWait
@onready var church_wait: AnimatedSprite2D = $ClickerMechanics/ChurchWait
@onready var military_wait: AnimatedSprite2D = $ClickerMechanics/MilitaryWait


# Circular Bars waittime until states
@onready var hunger_timer: Timer = $HungerTimer
@onready var defense_timer: Timer = $DefenseTimer
@onready var manipulation_timer: Timer = $ManipulationTimer
@onready var hunger_bar: TextureProgressBar = $TimeOuts/HungerBar
@onready var defense_bar: TextureProgressBar = $TimeOuts/DefenseBar
@onready var manipulation_bar: TextureProgressBar = $TimeOuts/ManipulationBar

# Lights
@onready var church_light = $ClickerMechanics/ChurchHover
@onready var mill_light = $ClickerMechanics/MillHover
@onready var army_light = $ClickerMechanics/ArmyHover

# GAME OVER MECHANICS
@onready var hunger_skull: Sprite2D = $TimeOuts/HungerBar/HungerSkull
@onready var war_skull: Sprite2D = $TimeOuts/DefenseBar/WarSkull
@onready var revolt_skull: Sprite2D = $TimeOuts/ManipulationBar/RevoltSkull

#============================== FUNCTIONS =====================================

# BUTTON ANIMATIONS
func _ready():
	_connect_buttons()
	_set_pivot_to_center()
	_hide_lights()
	default()


# DEFAULT VALUES 
func default():
	food = 0
	army = 0
	religion = 0
	SaveLoad.year = 1
	famine = false
	war = false
	revolt = false

func _process(delta: float) -> void:
	# PROGRESSIVE DIFFICULTY
	if SaveLoad.year % 50 == 0:
		ration_timer.wait_time += 0.5 * delta
		church_timer.wait_time += 0.5 * delta
		military_timer.wait_time += 0.5 * delta

			
	# Counter
	if food<10:
		food_score.text = "0"+str(food)
	else:
		food_score.text = str(food)
	if religion<10:
		religion_score.text = "0"+str(religion)
	else:
		religion_score.text = str(religion)
	if army<10:
		army_score.text = "0"+str(army)
	else:
		army_score.text = str(army)
	
	
	# Countdowns
	if hunger_timer.time_left != hunger_timer.wait_time:
		var percentage = (hunger_timer.time_left/hunger_timer.wait_time)*100
		hunger_bar.value = percentage
		
	if defense_timer.time_left != defense_timer.wait_time:
		var percentage = (defense_timer.time_left/defense_timer.wait_time)*100
		defense_bar.value = percentage
	
	if manipulation_timer.time_left != manipulation_timer.wait_time:
		var percentage = (manipulation_timer.time_left/manipulation_timer.wait_time)*100
		manipulation_bar.value = percentage
		
	
func _connect_buttons():
	# Food, Army, and Religion buttons (Scaling + Glow + Click effect)
	if food_button.pressed.is_connected(_on_food_pressed) == false:
		food_button.pressed.connect(_on_food_pressed)
	if army_button.pressed.is_connected(_on_army_pressed) == false:
		army_button.pressed.connect(_on_army_pressed)
	if religion_button.pressed.is_connected(_on_religion_pressed) == false:
		religion_button.pressed.connect(_on_religion_pressed)

	for button in [food_button, army_button, religion_button]:
		if button.mouse_entered.is_connected(_on_button_hover) == false:
			button.mouse_entered.connect(func(): _on_button_hover(button))
		if button.mouse_exited.is_connected(_on_button_exit) == false:
			button.mouse_exited.connect(func(): _on_button_exit(button))
		if button.pressed.is_connected(_on_button_pressed) == false:
			button.pressed.connect(func(): _on_button_pressed(button))

	# Clicker buttons (Only Light Effect, No Scaling or Glow)
	var button_light_map = {
		ration: mill_light,
		military: army_light,
		church: church_light
	}

	for button in button_light_map.keys():
		var light = button_light_map[button]
		if button.mouse_entered.is_connected(_on_light_hover) == false:
			button.mouse_entered.connect(func(): _on_light_hover(light))
		if button.mouse_exited.is_connected(_on_light_exit) == false:
			button.mouse_exited.connect(func(): _on_light_exit(light))

func _set_pivot_to_center():
	for button in [food_button, army_button, religion_button]:  
		var old_position = button.position
		button.pivot_offset = button.size / 2
		button.position = old_position + (button.size / 2) * (button.scale - Vector2(1, 1))

func _hide_lights():
	church_light.visible = false
	mill_light.visible = false
	army_light.visible = false

# Hover effects for normal buttons (Food, Army, Religion)
func _on_button_hover(button):
	var tween = button.create_tween()
	tween.tween_property(button, "scale", HOVER_SCALE, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1.4, 1.4, 1.4, 1), 0.1).set_trans(Tween.TRANS_SINE)
	if Global.sfx == true:
		blip_hover.play()

func _on_button_exit(button):
	var tween = button.create_tween()
	tween.tween_property(button, "scale", ORIGINAL_SCALE, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_SINE)

# Click effect for normal buttons (Food, Army, Religion)
func _on_button_pressed(button):
	var tween = button.create_tween()
	tween.tween_property(button, "scale", PRESS_SCALE, 0.05).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "modulate", Color(0.8, 0.8, 0.8, 1), 0.05).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "scale", ORIGINAL_SCALE, 0.1).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "modulate", Color(1, 1, 1, 1), 0.1).set_trans(Tween.TRANS_QUAD)

# Light effect for clicker buttons
func _on_light_hover(light):
	if Global.sfx == true:
		blip_hover.play()
	light.visible = true

func _on_light_exit(light):
	light.visible = false

# SCORE COUNTER
func _on_score_timer_timeout() -> void:
	SaveLoad.year += 1
	score.text = "YEAR "+str(SaveLoad.year)

# CLICKER MECHANICS
func _on_ration_pressed() -> void:
	if famine == false:
		if Global.sfx == true:
			click.play()
		ration_timer.start()
	
		# PLAY ANIMATION
		ration_wait.visible = true
		ration_wait.play()
	
		ration.disabled = true
	else:
		blip_buzzer.play()	
	
func _on_military_pressed() -> void:
	if war == false:
		if Global.sfx == true:
			click.play()
		military_timer.start()
	
		# PLAY ANIMATION
		military_wait.visible = true
		military_wait.play()
	
		military.disabled = true
	else:
		blip_buzzer.play()

	
func _on_church_pressed() -> void:
	if revolt == false:
		if Global.sfx == true:
			click.play()
		church_timer.start()
	
		# PLAY ANIMATION
		church_wait.visible = true
		church_wait.play()
	
		church.disabled = true
		
	else:
		blip_buzzer.play()
	
func _on_church_timer_timeout() -> void:
	if revolt == false:
		religion += 1
		
		# STOP ANIMATION
		church_wait.visible = false
		church_wait.stop()
	
		church.disabled = false
	
	else:
		blip_buzzer.play()		


func _on_ration_timer_timeout() -> void:
	if famine == false:
		food += 1
	
		# STOP ANIMATION
		ration_wait.visible = false
		ration_wait.stop()
	
	
		ration.disabled = false
		
	else:
		blip_buzzer.play()

func _on_military_timer_timeout() -> void:
	if war == false:
		army += 1
		
		# STOP ANIMATION
		military_wait.visible = false
		military_wait.stop()
	
		military.disabled = false
		
		
# RENEW MECHANICS
func _on_food_pressed():
	_on_button_pressed(food_button)  # Apply animation
	if hunger_bar.value != 0:
		if food > 0:
			hunger_timer.start(hunger_timer.time_left + renewTime)
			food -= 1
			if Global.sfx == true:
				click.play()

		else:
			blip_buzzer.play() # NONE
	else:
		blip_buzzer.play() # FAMINE CAME ALREADY

func _on_army_pressed():
	_on_button_pressed(army_button)  # Apply animation
	if defense_bar.value != 0:
		if army > 0:
			defense_timer.start(defense_timer.time_left + renewTime)
			army -= 1
			if Global.sfx == true:
				click.play()

		else:
			blip_buzzer.play() # NONE
	else:
		blip_buzzer.play() # WAR CAME ALREADY

func _on_religion_pressed():
	_on_button_pressed(religion_button)  # Apply animation
	if manipulation_bar.value != 0:
		if religion > 0:
			manipulation_timer.start(manipulation_timer.time_left + renewTime)
			religion -= 1
			if Global.sfx == true:
				click.play()

		else:
			blip_buzzer.play() # NONE
	else:
		blip_buzzer.play() # REVOLT CAME ALREADY


# ====================== ENDING MECHANICS ======================================
# FAMINE
func _on_hunger_timer_timeout() -> void:
	famine = true
	ration.disabled = false
	ration_wait.stop()
	ration_wait.visible = false
	hunger_skull.visible = true
	
	MainCamera.add_trauma(4)
	apply_disaster_effects()

# WAR
func _on_defense_timer_timeout() -> void:
	war = true
	military.disabled = false
	military_wait.stop()
	military_wait.visible = false
	war_skull.visible = true
	
	MainCamera.add_trauma(4)
	apply_disaster_effects()

# REVOLT
func _on_manipulation_timer_timeout() -> void:
	revolt = true
	church.disabled = false
	church_wait.stop()
	church_wait.visible = false
	revolt_skull.visible = true
	
	MainCamera.add_trauma(4)
	apply_disaster_effects()

# Apply visual effects when a disaster occurs
func apply_disaster_effects():
	if Global.sfx == true:
		screen_shake.play() # SCREEN SHAKE SOUND
	if famine and war and revolt:
		game_over()

# GAME OVER FUNCTION
func game_over():
	score_timer.stop()
	
	if SaveLoad.year > SaveLoad.hiscore:
		SaveLoad.hiscore = SaveLoad.year
	SaveLoad.save_score()

	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
	
	
