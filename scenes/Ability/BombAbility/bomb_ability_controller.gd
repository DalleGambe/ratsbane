extends Node

@export var base_range:float = 50
@export var bomb_ability_scene:PackedScene

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var temp_timer: Timer = %TempTimer

var base_explosion_damage:float = 130
var base_fall_damage:float = 30
var additional_fall_damage_perentage:float = 1
var additional_explosion_damage_perentage:float = 1
var amount_of_children_to_spawn:int = 0
var amount_of_big_bombs_to_spawn:int = 1
var explosion_radius:float = 1
var base_wait_time:float
var extra_fuse_speed:float
var selected_shrapnel_status = ShrapnelStatus.ShrapnelAmountStatus.NONE

func _ready() -> void:
	amount_of_big_bombs_to_spawn = 1
	selected_shrapnel_status = ShrapnelStatus.ShrapnelAmountStatus.NONE
	base_wait_time = %CooldownTimer.wait_time
	cooldown_timer.timeout.connect(on_cooldown_timer_timeout)
	temp_timer.timeout.connect(on_temp_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	on_cooldown_timer_timeout()

func on_temp_timer_timeout() -> void:
	on_cooldown_timer_timeout()
	%CooldownTimer.start()
	
func on_cooldown_timer_timeout() -> void:
	var direction = Vector2.RIGHT.rotated(randf_range(0,TAU))
	#var additional_rotational_degrees = 360.0 / (amount_of_big_bombs_to_spawn + 1)
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return 
	for bomb_to_summon in amount_of_big_bombs_to_spawn:
		#var adjusted_direction = direction.rotated(deg_to_rad(bomb_to_summon * additional_rotational_degrees))
		var spawn_position = player.global_position + (direction * randf_range(25, bomb_to_summon*base_range))
	
		var additional_check_offset = direction * 10
		var terrain_layer_bit_mask_value = 1
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position,
		spawn_position + additional_check_offset,terrain_layer_bit_mask_value)
		var result_of_ray_cast = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		if !result_of_ray_cast.is_empty():
			spawn_position = result_of_ray_cast["position"]
		var bomb_ability_instance = bomb_ability_scene.instantiate() as BombAbility
		get_tree().get_first_node_in_group("foreground").add_child(bomb_ability_instance)
		
		# Update extra fuse speed
		bomb_ability_instance.bomb_explosion_extra_speed_animation = extra_fuse_speed
		
		# Update explosion radius 
		bomb_ability_instance.explosion_radius_collision_shape_2d.shape.radius = 24 * explosion_radius 
		bomb_ability_instance.boom_particles.process_material.scale = Vector2(0,60) * Vector2(explosion_radius,explosion_radius)
		
		# Set spawn point
		bomb_ability_instance.global_position = spawn_position
		
		# Setting the knock of the bomb
		#bomb_ability_instance.explosion_radius_component.knockback_modifier = 1
		
		#Seting the damage based on distance
		bomb_ability_instance.impact_hit_box_component.damage = base_fall_damage * additional_fall_damage_perentage
		bomb_ability_instance.explosion_radius_component.damage = base_explosion_damage * additional_explosion_damage_perentage
		
		if(amount_of_children_to_spawn > 0):
			for amount in amount_of_children_to_spawn:
				var baby_bomb = bomb_ability_scene.instantiate() as BombAbility
				bomb_ability_instance.baby_bombs.append(baby_bomb)
		bomb_ability_instance.selected_spawn_shrapnel_status = selected_shrapnel_status
			
func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrade:Dictionary):
	match ability_upgrade.id:
		"matryoshka_bomb":
			amount_of_children_to_spawn = current_upgrade["matryoshka_bomb"]["quantity"] * 3
			# Update value of upgrade
			ability_upgrade.update_value("baby_bomb_count",3)
		"faster_bomb":
			var percent_reduction = current_upgrade["faster_bomb"]["quantity"] * 0.15
			temp_timer.wait_time = %CooldownTimer.time_left * (1-percent_reduction)
			temp_timer.start()
			%CooldownTimer.stop()
			%CooldownTimer.wait_time = base_wait_time * (1-percent_reduction)
			# Update value of upgrade
			ability_upgrade.update_value("bomb_summon_speed", 15)
		"more_boom":
			amount_of_big_bombs_to_spawn = current_upgrade["more_boom"]["quantity"] + 1
			ability_upgrade.update_value("bomb_count",amount_of_big_bombs_to_spawn+1)
		"bombastic":
			explosion_radius = 1 + (0.25 * current_upgrade["bombastic"]["quantity"])
		"shorter_fuse":
			extra_fuse_speed = 1.5 * (0.15 * current_upgrade["shorter_fuse"]["quantity"])
		"shrapnel_bomb":
			selected_shrapnel_status = ShrapnelStatus.ShrapnelAmountStatus.FOUR if selected_shrapnel_status == ShrapnelStatus.ShrapnelAmountStatus.NONE else ShrapnelStatus.ShrapnelAmountStatus.EIGHT
			ability_upgrade.update_value("amount_of_shrapnel", 4 if selected_shrapnel_status == ShrapnelStatus.ShrapnelAmountStatus.NONE else 8)
