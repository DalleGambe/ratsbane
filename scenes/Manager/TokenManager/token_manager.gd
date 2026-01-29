extends Node

@export var max_tokens: int = 3

# Keeps track of active tokens
var active_tokens: int = 0

# Called to spawn a token
func spawn_token(token_scene: PackedScene, position: Vector2) -> void:
	if active_tokens >= max_tokens:
		return  # Limit reached, do not spawn

	var token_instance = token_scene.instantiate() as Node2D
	var entities_group = get_tree().get_first_node_in_group("entities_group")
	entities_group.add_child(token_instance)
	token_instance.global_position = position

	# Increment active token count
	active_tokens += 1
	#print("Amount of tokens on screen: " + str(active_tokens))

	# Connect to the token's queue_free signal to decrement count
	token_instance.tree_exited.connect(_on_token_removed)

func _on_token_removed() -> void:
	# Decrement the active token count when a token is removed
	active_tokens = max(active_tokens - 1, 0)
