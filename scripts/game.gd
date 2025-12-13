extends Node2D

@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var path_follow = %PathFollow2D  
@onready var timer_label = $Player/Camera2D/TimerLabel

const FIRST_MENU_ACTIVATION_TIME = 60.0
const SECOND_MENU_ACTIVATION_TIME = 120.0

var menu1_instance: CanvasLayer
var menu2_instance: CanvasLayer
var menu1_active := false
var menu2_active := false
var menu1_timer: Timer
var menu2_timer: Timer
var spawn_timer: Timer
var elapsed_time := 0.0
var total_game_time := 0.0

var spawn_slime := true
var spawn_bat := false
var spawn_rat := false

const SPAWN_START = 3.0
const SPAWN_MIN = 0.5
const SPAWN_ACCEL_DURATION = 120.0

const GAME_DURATION = 180.0

func spawn_mob():
	const slime = preload("res://scenes/slime.tscn") 
	const bat = preload("res://scenes/bat.tscn")
	const rat = preload("res://scenes/rat.tscn")

	var available_mobs := []
	if spawn_slime:
		available_mobs.append(slime)
	if spawn_bat:
		available_mobs.append(bat)
	if spawn_rat:
		available_mobs.append(rat)

	if available_mobs.size() == 0:
		return

	var mob_scene = available_mobs[randi() % available_mobs.size()]
	var mob = mob_scene.instantiate()

	path_follow.progress_ratio = randf()
	mob.global_position = path_follow.global_position
	add_child(mob)


func _on_spawn_timer_timeout() -> void:
	if not menu1_active and not menu2_active:
		spawn_mob()


func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = SPAWN_START
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

	menu1_timer = Timer.new()
	menu1_timer.wait_time = FIRST_MENU_ACTIVATION_TIME
	menu1_timer.one_shot = true
	add_child(menu1_timer)
	menu1_timer.timeout.connect(show_menu1)
	menu1_timer.start()

	menu2_timer = Timer.new()
	menu2_timer.wait_time = SECOND_MENU_ACTIVATION_TIME
	menu2_timer.one_shot = true
	add_child(menu2_timer)
	menu2_timer.timeout.connect(show_menu2)
	menu2_timer.start()


func _process(delta: float) -> void:
	elapsed_time += delta
	total_game_time += delta

	var t = clamp(elapsed_time / SPAWN_ACCEL_DURATION, 0.0, 1.0)
	spawn_timer.wait_time = SPAWN_START + t * (SPAWN_MIN - SPAWN_START)

	if total_game_time >= GAME_DURATION and not has_node("GameOverPanel"):
		end_game(true)


func end_game(won: bool):
	get_tree().paused = true

	var game_over_layer = CanvasLayer.new()
	game_over_layer.name = "GameOverPanel"
	game_over_layer.layer = 30
	add_child(game_over_layer)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(400, 200)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -200
	panel.offset_top = -100
	game_over_layer.add_child(panel)

	var label = Label.new()
	if won:
		label.text = "GAME WON"
		label.add_theme_color_override("font_color", Color(0, 1, 0))
	else:
		label.text = "GAME OVER"
		label.add_theme_color_override("font_color", Color(1, 0, 0))

	label.add_theme_font_size_override("font_size", 48)
	label.anchor_left = 0.5
	label.anchor_top = 0.5
	label.anchor_right = 0.5
	label.anchor_bottom = 0.5
	label.offset_left = -150
	label.offset_top = -24
	panel.add_child(label)


func show_menu1():
	if menu1_active:
		return
	menu1_active = true

	menu1_instance = CanvasLayer.new()
	add_child(menu1_instance)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(400, 200)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -200
	panel.offset_top = -100
	menu1_instance.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_bottom = 0.5
	vbox.offset_left = -150
	vbox.offset_top = -50
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(vbox)

	var button1 = Button.new()
	button1.text = "Sacrifice Leg → -30% Move Speed"
	button1.custom_minimum_size = Vector2(300, 40)
	button1.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button1.pressed.connect(func(): _on_choice_menu1("leg"))
	vbox.add_child(button1)

	var button2 = Button.new()
	button2.text = "Sacrifice Arm → -30% Attack Damage"
	button2.custom_minimum_size = Vector2(300, 40)
	button2.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button2.pressed.connect(func(): _on_choice_menu1("arm"))
	vbox.add_child(button2)

	spawn_rat = true


func _on_choice_menu1(choice: String):
	if choice == "leg":
		player.apply_speed_penalty(0.3)
	elif choice == "arm":
		player.apply_damage_penalty(0.3)

	menu1_instance.queue_free()
	menu1_active = false


func show_menu2():
	if menu2_active:
		return
	menu2_active = true

	menu2_instance = CanvasLayer.new()
	add_child(menu2_instance)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(400, 200)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -200
	panel.offset_top = -100
	menu2_instance.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_bottom = 0.5
	vbox.offset_left = -150
	vbox.offset_top = -50
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(vbox)

	var button1 = Button.new()
	button1.text = "Sacrifice Brain → Get Stunned"
	button1.custom_minimum_size = Vector2(300, 40)
	button1.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button1.pressed.connect(func(): _on_choice_menu2("brain"))
	vbox.add_child(button1)

	var button2 = Button.new()
	button2.text = "Sacrifice Eye → -30% Vision Range"
	button2.custom_minimum_size = Vector2(300, 40)
	button2.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button2.pressed.connect(func(): _on_choice_menu2("eye"))
	vbox.add_child(button2)

	spawn_bat = true

func _on_choice_menu2(choice: String):
	if choice == "brain":
		player.apply_stun(3.0)
	elif choice == "eye":
		var current_zoom = camera.zoom.x
		var zoom_factor = current_zoom / 0.7
		timer_label.position = Vector2(-380, -220) / camera.zoom
		camera.zoom = Vector2(zoom_factor, zoom_factor)

	menu2_instance.queue_free()
	menu2_active = false
