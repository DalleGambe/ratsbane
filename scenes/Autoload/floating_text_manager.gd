extends Node

# Main script (where floating texts are spawned)
var damage_number_text_pool = []
var near_miss_text_pool = []
var damage_number_pool_size = 100 
var near_miss_pool_size = 20 
var damage_number_floating_text_scene = preload("res://scenes/Ui/damage_number_floating_text.tscn")
var floating_near_miss_text_scene = preload("res://scenes/Ui/near_miss_floating_text.tscn")

func _ready():
	# Initialize the object pool
	for i in range(damage_number_pool_size):
		var damage_number_floating_text = damage_number_floating_text_scene.instantiate() as Node2D
		damage_number_floating_text.hide()  # Hide instead of queue_free to keep it around
		damage_number_text_pool.append(damage_number_floating_text)
		
	for near_miss_text in range(near_miss_pool_size):
		var floating_text = floating_near_miss_text_scene.instantiate() as Node2D
		floating_text.hide()  # Hide instead of queue_free to keep it around
		near_miss_text_pool.append(floating_text)

# Get a floating text from the pool or create a new one if the pool is empty
func get_floating_text(name_pool:String) -> Node2D:
	var text_pool = damage_number_text_pool if name_pool == "damage_number" else near_miss_text_pool
	if text_pool.size() > 0:
		return text_pool.pop_back()
	else:
		return (damage_number_floating_text_scene.instantiate() if name_pool == "damage_number" else floating_near_miss_text_scene.instantiate()) as Node2D 

# Return the floating text to the pool
func return_floating_text(floating_text: Node2D, name_pool:String):
	floating_text.hide()  # Hide the object to simulate removal
	var text_pool = damage_number_text_pool if name_pool == "damage_number" else near_miss_text_pool
	text_pool.append(floating_text)		
	get_tree().get_first_node_in_group("foreground").remove_child(floating_text)  
