extends Node

@export var basic_enemy_scene:PackedScene
@export var knight_enemy_scene:PackedScene
@export var ranger_enemy_scene:PackedScene
@export var sorcerer_apprentice_enemy_scene:PackedScene
@export var upgraded_knight_scene:PackedScene
@export var SPAWN_RADIUS:float = 360
@export var arena_time_manager:Node

@onready var spawn_timer = %SpawnTimer

var base_spawn_time = 0
var enemy_spawn_table = WeightedTable.new()
var number_of_enemies_to_spawn = 1

func _ready():
	enemy_spawn_table.add_item(knight_enemy_scene, 15)
	base_spawn_time = spawn_timer.wait_time
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)

func get_spawn_position() -> Vector2:
	# Check if there is a player present
	var player = get_tree().get_first_node_in_group("player") as Node2D
	var spawn_position = Vector2.ZERO
	# Get random direction to start with
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	# If there is no player present, don't run this code
	if(player == null):
		return Vector2.ZERO
		
	# Not inclusive so direction will never be four
	for times_direction_has_rotated in 4:
		
		# Define the spawn position outside of the player view
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset = random_direction * 20
		var terrain_layer_bit_mask_value = 1
		
		# Bit masking = take the value and shift it over x places in the bit mask collision layer in this case 0
		# Useful because typing values constantly isn't fun => current_layer << amount_to_shift
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position,
		 spawn_position + additional_check_offset,terrain_layer_bit_mask_value)
	
		# Raycast check to see if there are any walls
		var result_of_ray_cast = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		# If the dictionary was empty
		if(result_of_ray_cast.is_empty()):
			# There is no wall or something else that collides, the enemy can spawn!
			# Break the current loop
			break
		else:
			# If there is a wall or something else that collides, oooh boy..
			# Rotate random direction by 90 degrees
			random_direction = random_direction.rotated(deg_to_rad(90))
			
	return spawn_position
	
func _on_spawn_timer_timeout() -> void:
	spawn_timer.start()
	# Check if there is a player present
	var player = get_tree().get_first_node_in_group("player") as Node2D
	# If there is no player present, don't run this code
	if(player == null):
		return
	for number in number_of_enemies_to_spawn:	
		# Pick enemy scene
		var enemy_scene = enemy_spawn_table.pick_item()	
		# Initialise the enemy
		var enemy = enemy_scene.instantiate() as Node2D
		var entities_group
		if(enemy.is_in_group("flying_enemy")):
			entities_group = get_tree().get_first_node_in_group("flying_entities_group")
		else:
			entities_group = get_tree().get_first_node_in_group("entities_group")
		# Add the enemy to the Enemy Manager
		entities_group.add_child(enemy)
		# Set the global position in the scene to the spawn position
		enemy.global_position = get_spawn_position()
	
func on_arena_difficulty_increased(arena_difficulty:int) -> void:
	# 12 waves per minute
	var time_off = (.1/12) * arena_difficulty
	# if the timer exceeds .5, make it stay there. 
	time_off = min(time_off, .5)
	#print("Time Off: " + str(time_off) + "\n")
	spawn_timer.wait_time = base_spawn_time - time_off
	if arena_difficulty == 5:
		enemy_spawn_table.add_item(basic_enemy_scene, 10)
	if arena_difficulty == 18:
		enemy_spawn_table.add_item(ranger_enemy_scene, 5)
	#if arena_difficulty == 26:
		#enemy_spawn_table.add_item(sorcerer_apprentice_enemy_scene, 5)
	
	# Every 96 seconds, spawn 1 or 2 more enemies per second
	if (arena_difficulty % 24) == 0:
		number_of_enemies_to_spawn += randf_range(1,2)
