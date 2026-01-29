extends Node

@onready var cooldown_timer: Timer = %CooldownTimer

@export var pinball_ability_scene:PackedScene
@export var detection_range:float = 150 
@onready var timer: Timer = %Timer

var pinballs_being_summoned:int = 2
var additional_bounces:int = 0
var additional_pinballs:int = 0

func _ready() -> void:
	# Setup stuff
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	timer.timeout.connect(on_timer_timeout)
	summon_pinball()

func summon_pinball() -> void:
	if(cooldown_timer.is_stopped()):
		var player = get_tree().get_first_node_in_group("player") as Node2D
		var foreground = get_tree().get_first_node_in_group("foreground")
		if player == null or foreground == null:
			return
		
		# Get all enemies and projectiles
		var enemies = get_tree().get_nodes_in_group("enemy")
		var projectiles = get_tree().get_nodes_in_group("projectile")
		
		# Filter out enemies that are projectiles or out of range
		enemies = enemies.filter(func(enemy: Node2D) -> bool:
			return not projectiles.has(enemy) and enemy.global_position.distance_squared_to(player.global_position) < pow(detection_range, 2)
		)
		
		# If there are no valid enemies within range, don't spawn a pinball
		if enemies.is_empty():
			return
		
		# Sort enemies by distance to player
		enemies.sort_custom(func(a_enemy: Node2D, b_enemy: Node2D) -> bool:
			var a_enemy_distance = a_enemy.global_position.distance_squared_to(player.global_position)
			var b_enemy_distance = b_enemy.global_position.distance_squared_to(player.global_position)
			return a_enemy_distance < b_enemy_distance
		)
		
		# Create a copy of the enemies list for available targets
		var available_targets = enemies.duplicate()
		
		# Process spears being thrown
		for pinball in (pinballs_being_summoned+additional_pinballs):	
			var pinball_ability_scene_instance = pinball_ability_scene.instantiate()
			pinball_ability_scene_instance.global_position = player.global_position
			
			# Check if there are available targets
			if available_targets.size() > 0:
				var index_enemy_to_throw_at = randi() % available_targets.size()
				var target_enemy = available_targets[index_enemy_to_throw_at]
				
				# Remove the targeted enemy from the list
				available_targets.remove_at(index_enemy_to_throw_at)
				
				pinball_ability_scene_instance.set_movement_direction(target_enemy.global_position)
			else:
				# Throw in a random direction if no targets remain
				pinball_ability_scene_instance.set_movement_direction(Vector2(randf_range(-50, 50), randf_range(-50, 50)))
			
			# Add pin ball ability to the foreground
			foreground.add_child(pinball_ability_scene_instance)
		
			pinball_ability_scene_instance.hitbox_component.damage = pinball_ability_scene_instance.get_base_damage()
			pinball_ability_scene_instance.bounces_left += additional_bounces
		
		# start the cooldown
		cooldown_timer.start()

func on_timer_timeout():
	summon_pinball()

func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrade:Dictionary):
	match ability_upgrade.id:
		"boing":
			additional_bounces = current_upgrade["boing"]["quantity"] * 5
			ability_upgrade.update_value("extra_percentage",0.33*100)
		"bouncy_storm":
			var new_ball_extra_amount:int = 2
			additional_pinballs = current_upgrade["bouncy_storm"]["quantity"] * new_ball_extra_amount
			ability_upgrade.update_value("extra_amount",new_ball_extra_amount)
