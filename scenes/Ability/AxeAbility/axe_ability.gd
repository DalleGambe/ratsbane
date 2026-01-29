extends Node2D
class_name AxeAbility

@onready var hitbox_component = %HitBoxComponent

var base_rotation:Vector2 = Vector2.RIGHT
var MAX_RADIUS:float = 100
var axe_target_speed = 2.0
var axe_starting_speed = 0.0
var axe_swing_speed = 1
var animation_duration:float = 3
var glow_time = 0.0

func _ready() -> void:
	base_rotation = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var tween = create_tween()
	tween.tween_method(tween_method, axe_starting_speed, axe_target_speed, animation_duration)
	# Remove the axe after the tween method is done
	tween.tween_callback(disappear_axe)
	
func _process(delta: float) -> void:
	glow_time += delta
	%Sprite2D.material.set_shader_parameter("time", glow_time)	

func disappear_axe() -> void:
	%AnimationPlayer.play("disappear")

func tween_method(rotations:float) -> void:
	var rotation_percentage = (rotations/2)
	var current_rotation_radius = rotation_percentage * MAX_RADIUS
	# TAU = 2 times pie
	var current_rotation_direction = base_rotation.rotated(rotations * (TAU * axe_swing_speed))
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	# Rotates around the players global position, this line makes the axe move
	global_position = player.global_position + (current_rotation_direction * current_rotation_radius)
