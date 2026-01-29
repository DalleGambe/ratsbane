extends CharacterBody2D
class_name BasicBoss

@export var boss_name:String = "Knightley" 
@export var boss_title:String = "The Chef"
@export var flavour_text:String = "He likes spicy chicken." 
@export var min_health:int = 2000 
@export var max_health:int = 3000 
@export var default_movement_speed:float = 57
@export var default_acceleration:float = 5
@export var current_move:String = ""
@export var move_pool:Array[String] = []

func _get_direction_to_player() -> Vector2:
	var player_node = get_tree().get_first_node_in_group("player") as Node2D
	if(player_node != null):
		return (player_node.global_position - global_position).normalized()
	return Vector2.ZERO
