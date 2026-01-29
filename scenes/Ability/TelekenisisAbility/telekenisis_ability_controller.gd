extends Node

# Range enemies can get grabbed in
@export var MAX_RANGE:float = 200
@onready var cooldown_timer: Timer = $CooldownTimer

@export var telekenisis_ability:PackedScene

var base_damage_percent:float = 0.50
var additional_damage_percentage:float = 1
var base_wait_time:float

func _ready() -> void:
	base_wait_time = cooldown_timer.wait_time
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func _on_cooldown_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if(player == null):
		return
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(enemy:Node2D):
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE,2))

	if(enemies.size() <= 0):
		return
		
	enemies.sort_custom(func(a_enemy:Node2D, b_enemy:Node2D):
		var a_enemy_distance = a_enemy.global_position.distance_squared_to(player.global_position)
		var b_enemy_distance = b_enemy.global_position.distance_squared_to(player.global_position)
		return a_enemy_distance < b_enemy_distance
		)
	var index_of_enemy_picked_up = randf_range(0, enemies.size()-1)
	var enemy_to_pick_up = 	enemies[index_of_enemy_picked_up]
	enemies.remove_at(index_of_enemy_picked_up)
		
	var telekenisis_instance = telekenisis_ability.instantiate() as TelekenisisAbility
	telekenisis_instance.enemy = enemy_to_pick_up
	
	if(enemies.size() > 0):	
		var enemy_target = enemies[min(randi() % enemies.size()-1,0)]
		telekenisis_instance.set_target(enemy_target)
		
	var foreground_layer = get_tree().get_first_node_in_group("foreground")
	foreground_layer.add_child(telekenisis_instance)
	telekenisis_instance.hit_box_component.damage = enemy_to_pick_up.health_component.max_health * base_damage_percent

func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrade:Dictionary) -> void:
	pass	
