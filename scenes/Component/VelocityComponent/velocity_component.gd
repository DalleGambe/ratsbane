extends Node
class_name VelocityComponent
@export var max_speed: int = 75
@export var acceleration: float = 5

var velocity = Vector2.ZERO

func accelerate_to_player() -> void:
	var owner_node2d = owner as Node2D
	var player = get_tree().get_first_node_in_group("player")
	
	if owner_node2d == null or player == null:
		return

	var direction = (player.global_position - owner_node2d.global_position).normalized()
	accelerate_in_direction(direction)

func accelerate_away_from_player() -> void:
	var owner_node2d = owner as Node2D
	var player = get_tree().get_first_node_in_group("player")
	
	if owner_node2d == null or player == null:
		return

	var direction = (player.global_position - owner_node2d.global_position).normalized()
	accelerate_in_direction(-direction)

func accelerate_in_direction(direction:Vector2, temp_max_speed:int = 0) -> void:
	# Final velocity to be at
	var desired_velocity = direction * (max_speed if temp_max_speed == 0 else temp_max_speed)
	# Every frame get closer to the desired velocity in speed every frame
	# Smoothing value = -acceleration
	velocity = velocity.lerp(desired_velocity, 1 - exp(-acceleration * get_process_delta_time()))
	
func decelerate() -> void:
	accelerate_in_direction(Vector2.ZERO)
	
func move(character_body:CharacterBody2D) -> void:
	character_body.velocity = velocity
	character_body.move_and_slide()
	velocity = character_body.velocity
