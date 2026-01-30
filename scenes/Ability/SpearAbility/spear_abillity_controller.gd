extends Node

# Enemies damaged within this range with a melee attack
@export var MAX_RANGE:float

@export var spear_ability_scene:PackedScene

@onready var cooldown_timer = %CooldownTimer
var base_damage_of_spear:float = 75
var additional_damage_percentage:float = 1
var spears_being_thrown = 1
var base_wait_time:float
var should_turn_around:bool = false

func _ready() -> void:
	spears_being_thrown = 1
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	# throw a free spear IF there is an enemy in range
	_on_cooldown_timer_timeout()
	
func _on_cooldown_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	var foreground = get_tree().get_first_node_in_group("foreground")
	if player == null or foreground == null:
		return
	
	# Get all enemies and projectiles
	var enemies = get_tree().get_nodes_in_group("enemy")
	var projectiles = get_tree().get_nodes_in_group("projectile")
	
	# Filter out enemies that are projectiles or out of range
	enemies = enemies.filter(func(enemy: Node2D) -> bool:
		return not projectiles.has(enemy) and enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)
	
	# If there are no valid enemies, don't spawn a spear
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
	for spear_being_thrown in spears_being_thrown:	
		var spear_ability_scene_instance = spear_ability_scene.instantiate()
		spear_ability_scene_instance.global_position = player.global_position
		
		# If player has turn around upgrade, set turn around to true
		spear_ability_scene_instance.turn_around_after_first_throw = should_turn_around
		
		# Check if there are available targets
		if available_targets.size() > 0:
			var index_enemy_to_throw_at = randi() % available_targets.size()
			var target_enemy = available_targets[index_enemy_to_throw_at]
			
			# Remove the targeted enemy from the list
			available_targets.remove_at(index_enemy_to_throw_at)
			
			spear_ability_scene_instance.set_throw_direction(target_enemy.global_position)
		else:
			# Throw in a random direction if no targets remain
			spear_ability_scene_instance.set_throw_direction(Vector2(randf_range(-50, 50), randf_range(-50, 50)))
		
		# Add spear ability to the foreground
		foreground.add_child(spear_ability_scene_instance)
		
		# Set spear damage
		spear_ability_scene_instance.hitbox_component.damage = base_damage_of_spear * additional_damage_percentage

func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrade:Dictionary):
	match ability_upgrade.id:
		"sharper_spear":
			additional_damage_percentage = 1 + current_upgrade["sharper_spear"]["quantity"] * 0.20
			ability_upgrade.update_value("spear_damage",0.20*100)
		"toothpick_festival":
			spears_being_thrown = 1 + current_upgrade["toothpick_festival"]["quantity"]
			ability_upgrade.update_value("spear_amount",spears_being_thrown+1)
		"piercing_echo":
			should_turn_around = true
