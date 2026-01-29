extends Node

@export_range(0,1) var drop_percent:float = .5
@export var health_component:Node
@export var token_scene:PackedScene


func _ready() -> void:
	(health_component as HealthComponent).health_owner_died.connect(on_health_owner_died)

func on_health_owner_died() -> void:
	#var amount_of_tokens_on_screen = get_tree().get_node_count_in_group("tokens")
	#print("Amount of tokens on screen: " + str(amount_of_tokens_on_screen))
	if(randf() > drop_percent):
		return
		
	if token_scene == null:
		return
		
	#if the owner is not a 2D Node
	if not owner is Node2D:
		return
			
	var token_spawn_position = (owner as Node2D).global_position
	#var token_instance = token_scene.instantiate() as Node2D
	## Get the entities group
	#var entities_group = get_tree().get_first_node_in_group("entities_group")
	## Add the vial to the entities group
	#entities_group.add_child(token_instance)
	## Set the global position in the scene to the spawn position of the vial
	#token_instance.global_position = token_spawn_position
	
	TokenManager.spawn_token(token_scene, token_spawn_position)
