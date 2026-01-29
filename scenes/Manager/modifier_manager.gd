extends Node

var can_player_heal_this_run:bool = true

func reset_modifier_values() -> void:
	can_player_heal_this_run = true

func execute_modifier(active_map_id:String, active_modifier_id:String) -> void:
		match active_map_id:
			# Any map
			_:
				match active_modifier_id:
					"one_shot":
						var player:Player = get_tree().get_first_node_in_group("player")
						if player == null:
							return
						player.health_component.current_health = 1
						player.health_component.max_health = 1
						player.update_health_bar_display()
						can_player_heal_this_run = false

func get_can_player_heal_this_run() -> bool:
	return can_player_heal_this_run
