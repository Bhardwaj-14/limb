extends CharacterBody2D

@onready var AnimatedSprite2d = $AnimatedSprite2D
const BASE_SPEED = 100
@export var health: int = 100
signal health_depleted

var current_speed: float = BASE_SPEED
var attack_damage: float = 12

var stunned: bool = false
var stun_timer: Timer

func _ready():
	stun_timer = Timer.new()
	stun_timer.one_shot = true
	stun_timer.timeout.connect(_on_stun_end)
	add_child(stun_timer)

func _physics_process(delta: float) -> void:
	if stunned:
		AnimatedSprite2d.play("idle")
		return

	var direction = Input.get_vector("left", "right", "up", "down")
	if direction.length() > 0:
		direction = direction.normalized()
		
	velocity = direction * current_speed
	move_and_slide()
	
	if direction.length() > 0:
		if direction.x < 0:
			AnimatedSprite2d.flip_h = true
		elif direction.x > 0:
			AnimatedSprite2d.flip_h = false
		AnimatedSprite2d.play("run")
	else:
		AnimatedSprite2d.play("idle")
	
	const DAMAGE_RATE = 5	
	var overlapping_mobs = $Hitbox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		if health <= 0:
			health_depleted.emit()
		$HealthBar.value = health


func apply_speed_penalty(percent: float) -> void:
	current_speed *= (1.0 - percent)
	print("Player speed reduced to:", current_speed)

func apply_damage_penalty(percent: float) -> void:
	attack_damage *= (1.0 - percent)
	print("Player attack damage reduced to:", attack_damage)

func apply_stun(duration: float) -> void:
	stunned = true
	stun_timer.wait_time = duration
	stun_timer.start()
	print("Player stunned for", duration, "seconds")

func _on_stun_end() -> void:
	stunned = false
	print("Player is no longer stunned")
