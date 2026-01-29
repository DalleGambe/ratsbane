extends CharacterBody2D
class_name PinballAbility

@export var max_movement_speed: float = 400
@export var speed_cap: float = 600
@export var base_bounces: int = 10
@export var base_damage: int = 15
@export var damage_increase_per_kill: int = 10
@export var detection_range: float = 150 

@onready var hitbox_component: HitboxComponent = %HitBoxComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var enemy_detection_box: Area2D = %EnemyDetectionBox

var target_direction: Vector2 = Vector2.ZERO
var bounces_left: int
var is_active: bool = false
var glow_time := 0.0

func _ready() -> void:
	enemy_detection_box.area_entered.connect(on_enemy_hit)
	bounces_left = base_bounces
	is_active = true
	call_deferred("_force_initial_wall_check") # Handle collision if spawned inside a wall

func _process(delta: float) -> void:
	glow_time += delta
	if %Sprite2D.material:
		%Sprite2D.material.set_shader_parameter("time", glow_time)

func _physics_process(delta: float) -> void:
	if not is_active:
		return

	var actual_speed = min(max_movement_speed, speed_cap)
	var velocity = target_direction * actual_speed
	var collision = move_and_collide(velocity * delta)

	if collision:
		if bounces_left > 0:
			bounces_left -= 1
			target_direction = target_direction.bounce(collision.get_normal()).normalized()
		else:
			make_ball_disappear()

	# Smooth rotation
	var target_rotation = target_direction.angle() + deg_to_rad(45)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-4 * delta))

func _force_initial_wall_check() -> void:
	velocity = target_direction * 1.0
	var collision = move_and_collide(velocity * get_physics_process_delta_time())
	if collision:
		if bounces_left > 0:
			bounces_left -= 1
			target_direction = target_direction.bounce(collision.get_normal()).normalized()
		else:
			make_ball_disappear()

func on_enemy_hit(area: Area2D) -> void:
	#AudioManager.create_2d_audio_at_location(global_position, SoundEffectSettings.SOUND_EFFECT_TYPE.PINBALL_HIT);
	if area.owner and area.owner.is_in_group("enemy"):
		if bounces_left > 0:
			bounces_left -= 1
			hitbox_component.damage += damage_increase_per_kill
			target_direction = -target_direction.normalized()
		else:
			make_ball_disappear()

func set_movement_direction(destination: Vector2) -> void:
	target_direction = (destination - global_position).normalized()

func make_ball_disappear() -> void:
	is_active = false
	animation_player.play("disappear")

func get_base_damage() -> int:
	return base_damage
