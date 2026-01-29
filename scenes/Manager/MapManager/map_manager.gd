extends Node

# The Maps in the map pool, their data is fetched from the save file
@export var maps: Array[Map]

# Map used when player presses play or quick play
@export var active_map:Map

var maps_by_number_id: Dictionary = {}

func _ready() -> void:
	for map in get_maps():
		maps_by_number_id[map.number_id] = map
	# Update the maps in the list to the stats from the meta progression
	# code
	# if there is a last played map and it is still unlocked
		#  Set the active map to the last one played
		# code
	# else
		# Set it to the first map in the list (the_courtyard)
		#active_map = maps[0]
	active_map = maps[0]
	
# Return all maps
func get_maps() -> Array[Map]:
	return maps

func get_active_map() -> Map:
	return active_map

func get_map_id_through_number_id(number_id: int) -> String:
	if maps_by_number_id.has(number_id):
		return maps_by_number_id[number_id].id
	return "" 


# Set the new active map 
func set_active_map(new_active_map:Map) -> void:
	# Set the new active map to the current active map
	active_map = new_active_map
	
	# Write the modifier changes away to the safe file
	for modifier:Modifier in active_map.modifiers:
		if(modifier.is_unlocked == true):		
			# Get the data saved
			var modifier_data:Dictionary = MetaProgression.get_saved_modifier_data(modifier.id, active_map)
			
			# Modify the modifier to use it
			modifier.is_active = modifier_data["is_active"]

# Update the stats of the map for example after a run ends
func update_active_map_stats() -> void:
	pass

# Get the stats saved in the safe file from a map so that the settings from last time are present
func get_map_stats(map_id:String) -> void:
	pass
