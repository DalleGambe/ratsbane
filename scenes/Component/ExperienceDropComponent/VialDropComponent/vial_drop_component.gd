extends Node

@export_range(0,1) var drop_percent:float = .5
@export var health_component:Node
@export var vial_scene:PackedScene

func _ready() -> void:
	(health_component as HealthComponent).health_owner_died.connect(on_health_owner_died)

func on_health_owner_died() -> void:
	var adjusted_drop_percent = drop_percent
	var gain_experience_meta_upgrade_count = MetaProgression.get_active_meta_upgrade_count("gain_experience")
	if(gain_experience_meta_upgrade_count >= 0 and MetaProgression.is_meta_upgrade_enabled("gain_experience") == true):
		adjusted_drop_percent += 0.1 * gain_experience_meta_upgrade_count
	if(randf() > adjusted_drop_percent):
		return
		
	if vial_scene == null:
		return
		
	#if the owner is not a 2D Node
	if not owner is Node2D:
		return
		
	var vial_spawn_position = (owner as Node2D).global_position
	var vial_instance = vial_scene.instantiate() as Node2D
	# Get the entities group
	var entities_group = get_tree().get_first_node_in_group("entities_group")
	# Add the vial to the entities group
	entities_group.add_child(vial_instance)
	# Set the global position in the scene to the spawn position of the vial
	vial_instance.global_position = vial_spawn_position
