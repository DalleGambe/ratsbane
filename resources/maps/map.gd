extends Resource
class_name Map

@export var id:String
@export var number_id:int
@export var title:String
@export var description:String
@export var music_track_name:String
@export var base_volume_of_track:int
@export var thumbnail:Texture2D
@export var time_before_door_opens:float = 301
@export var times_played:int = 0
@export var amount_of_wins:int = 0
@export var amount_of_losses:int = 0
@export var best_highscore:float
@export var best_time_in_seconds:int
@export var last_score:float
@export var last_time_in_seconds:int
@export var available_game_modes: Array[GameMode]
@export var selected_game_mode:GameMode
# Used to fetch the map layout since a TileMapLayer cannot be used in a resource class
@export var tile_map_layer_name:String
@export var modifiers:Array[Modifier]
@export var map_objects:Array[MapObject]
@export var is_unlocked:bool = false

func get_active_modifiers() -> Array[String]:
	# Defining an array for the active modifiers
	var active_modifiers:Array[String]
	
	# If there are any modifiers in the modifiers list
	if(modifiers.size() > 0):
		for modifier:Modifier in modifiers:
			# if the modifier isn't active or not unlocked, continue the for loop and ignore this one
			if modifier.is_active == false or modifier.is_unlocked == false:
				continue
			# Else add it to the active modifier list	
			else:	
				active_modifiers.append(modifier.id)
	return active_modifiers		
