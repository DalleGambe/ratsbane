extends Node
class_name TileMapManager

func get_tile_layer_for_map(map_id: String) -> TileMapLayer:
	#print(map_id)
	# Get Resource path using id
	var resource_path = "res://scenes/Maps/" + map_id + ".tscn"
	print("Loading resource from: " + resource_path)

	# Get the file at this resource path
	var scene = load(resource_path)

	# If the file is null
	if scene == null:
		print("FILE IS NULL!")
		# Return null
		return null

	# Instantiate the scene to access its children
	var instance = scene.instantiate()
	if instance == null:
		print("FAILED TO INSTANCE SCENE!")
		return null
			
	if instance is TileMapLayer:
		return instance

	# If no TileMapLayer is found, return null
	print("No TileMapLayer found in scene!")
	return null
