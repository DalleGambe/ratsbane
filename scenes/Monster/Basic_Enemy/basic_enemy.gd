extends CharacterBody2D
class_name BasicEnemy

var being_knocked_back:bool;
var knockback_duration_timer:int
var knockback_direction:Vector2
var knockback_velocity = 0

func apply_knockback(direction: Vector2, strength: float):
	being_knocked_back = true
	knockback_direction = direction
	knockback_velocity = direction * strength
	knockback_duration_timer = 0.2

func _get_direction_to_player() -> Vector2:
	var player_node = get_tree().get_first_node_in_group("player") as Node2D
	if(player_node != null):
		return (player_node.global_position - global_position).normalized()
	return Vector2.ZERO
