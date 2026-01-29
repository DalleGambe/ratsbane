extends Node

var open_menu_list: Array[CanvasLayer] = []

func _add_menu_to_list(menu_to_add:CanvasLayer) -> void:
	if not open_menu_list.has(menu_to_add):
		open_menu_list.append(menu_to_add)
		_pause_game()

func _remove_menu_from_list(menu_to_remove:CanvasLayer) -> void:
	if open_menu_list.has(menu_to_remove) and open_menu_list.size() >= 0:
		var index_of_menu_to_remove = open_menu_list.find(menu_to_remove)
		open_menu_list.remove_at(index_of_menu_to_remove)
		if(open_menu_list.size() == 0):
			_unpause_game()

func clear_menu_list() -> void:
	open_menu_list.clear()
		
func _unpause_game() -> void:
	if open_menu_list.size() <= 0:
			get_tree().paused = false
			
func _pause_game() -> void:
	if open_menu_list.size() >= 0:
		# Pause the entire game except the trees that are always being processed
		get_tree().paused = true			
