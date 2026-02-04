extends CharacterBody2D
class_name BasicEnemy

var being_knocked_back:bool;
var knockback_duration_timer:float
var knockback_direction:Vector2
var knockback_velocity = 0
var is_in_miss_box:IsInMissBox.IsInMissBoxStatus = IsInMissBox.IsInMissBoxStatus.OUTSIDE

func apply_knockback(direction: Vector2, strength: float):
	being_knocked_back = true
	knockback_direction = direction
	knockback_velocity = direction * strength
	knockback_duration_timer = 0.2

func set_missbox_status(new_is_in_miss_box_status:IsInMissBox.IsInMissBoxStatus) -> void:
	is_in_miss_box = new_is_in_miss_box_status

func on_player_hit() -> void:
	set_missbox_status(IsInMissBox.IsInMissBoxStatus.HIT)

func _get_direction_to_player() -> Vector2:
	var player_node = get_tree().get_first_node_in_group("player") as Node2D
	if(player_node != null):
		return (player_node.global_position - global_position).normalized()
	return Vector2.ZERO
		
