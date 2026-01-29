extends Node

# Main script (where floating texts are spawned)
var floating_text_pool = []
var pool_size = 100  # Number of objects in the pool (adjust based on need)
var floating_text_scene = preload("res://scenes/Ui/floating_text.tscn")

func _ready():
	# Initialize the object pool
	for i in range(pool_size):
		var floating_text = floating_text_scene.instantiate() as Node2D
		floating_text.hide()  # Hide instead of queue_free to keep it around
		floating_text_pool.append(floating_text)

# Get a floating text from the pool or create a new one if the pool is empty
func get_floating_text() -> Node2D:
	if floating_text_pool.size() > 0:
		return floating_text_pool.pop_back()
	else:
		return floating_text_scene.instantiate() as Node2D  # Fallback (less optimal)

# Return the floating text to the pool
func return_floating_text(floating_text: Node2D):
	floating_text.hide()  # Hide the object to simulate removal
	floating_text_pool.append(floating_text)
	get_tree().get_first_node_in_group("foreground").remove_child(floating_text)  # Remove from the scene
