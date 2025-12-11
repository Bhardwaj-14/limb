extends CharacterBody2D

@export var speed = 30.0
@onready var animated_sprite = $AnimatedSprite2D
var player: CharacterBody2D = null
var health = 80

func _ready():
	player = get_tree().get_root().get_node("1/Player")
	animated_sprite.play("idle")
	
func _physics_process(delta: float) -> void:
	if player:
		var direction = global_position.direction_to(player.global_position)
		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()
		
		if velocity.x < 0:
			animated_sprite.flip_h = true
		elif velocity.x > 0:
			animated_sprite.flip_h = false
		
func take_damage():
	health -= 20
	play_hurt()
	
	if health <= 0:
		queue_free()
		
func play_hurt():
	animated_sprite.play("damage")
	animated_sprite.play("idle")
