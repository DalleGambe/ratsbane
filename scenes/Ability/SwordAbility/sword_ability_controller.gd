extends Node

# Enemies damaged within this range with a melee attack
@export var MAX_RANGE:float

@export var sword_ability:PackedScene
@export var plasma_sword_ability:PackedScene

var base_damage:float = 50
var additional_damage_percentage:float = 1
var base_wait_time:float
var chop_chop_activated:bool = false
var is_plasma_sword_active:bool = false
var total_swings:int = 1
var area:Area2D
var attack_start_locked: bool = false

func _ready() -> void:
	base_wait_time = %Timer.wait_time
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	_setup_detection_area()

func _setup_detection_area() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		push_warning("SwordController: No player found to attach detection area!")
		return

	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()

	shape.radius = MAX_RANGE
	collision.shape = shape

	area.set_collision_layer_value(4, true)
	area.set_collision_mask_value(4, true) 

	area.add_child(collision)
	player.call_deferred("add_child", area)

	area.position = Vector2.ZERO

	area.body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if %Timer.is_stopped() and not attack_start_locked:
		attack_start_locked = true
		call_deferred("perform_attack")

func perform_attack() -> void:
	attack_start_locked = false
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if(player == null):
		return
	
	if(is_plasma_sword_active):	
		var enemies = get_tree().get_nodes_in_group("enemy").filter(func(enemy:Node2D):
			return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE,2))
		
		if enemies.size() > 0:
			var plasma_sword_instance = plasma_sword_ability.instantiate() as PlasmaSwordAbiility
			var foreground_layer = get_tree().get_first_node_in_group("foreground")
			plasma_sword_instance.global_position = player.global_position + Vector2(randf_range(-10,10), randf_range(-10,10))
			foreground_layer.add_child(plasma_sword_instance)
			plasma_sword_instance.sprite_2d.texture = load("res://assets/weapons/plasma_sword.png")
			
			var mat = plasma_sword_instance.sprite_2d.material
			plasma_sword_instance.sprite_2d.material = mat.duplicate()
			var color = Color.from_hsv(randf(), 1.0, 1.0)
			plasma_sword_instance.sprite_2d.material.set_shader_parameter("tolerance", 0.5)
			plasma_sword_instance.sprite_2d.material.set_shader_parameter(
				"replace_color",
				Vector4(color.r, color.g, color.b, 1.0)
			)
			var swungSoFar:int = 0;
			for swingsMade in range(total_swings*2 if chop_chop_activated else total_swings):
				var target_pos: Vector2 = Vector2.ZERO
				plasma_sword_instance.hit_box.damage = (50 if randi() % 100 > 15 else 100) * additional_damage_percentage 
				enemies = get_tree().get_nodes_in_group("enemy").filter(func(enemy:Node2D):
					return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE,2))
				if enemies.size() > 0:
					var index = randi() % enemies.size()
					target_pos = enemies[index].global_position
				elif swingsMade == 0 && enemies.size() <= 0:
					plasma_sword_instance.animation_player.play("disappear")
					await plasma_sword_instance.animation_player.animation_finished
					return;
				elif player:
					target_pos = player.global_position
				if(%Timer.is_stopped()):
					%Timer.start()
				plasma_sword_instance.collision_shape_2d.disabled = false	
				await plasma_sword_instance.swing_to(target_pos).finished
				plasma_sword_instance.is_swinging = false
				plasma_sword_instance.collision_shape_2d.disabled = true
				swungSoFar += 1
				if(swungSoFar != (total_swings*2 if chop_chop_activated else total_swings)):
					await get_tree().create_timer(0.50).timeout
				else:
					plasma_sword_instance.animation_player.play("disappear")
	else:
		var enemies = get_tree().get_nodes_in_group("enemy")
		enemies = enemies.filter(func(enemy:Node2D):
			return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE,2))

		if(enemies.size() <= 0):
			return
			
		enemies.sort_custom(func(a_enemy:Node2D, b_enemy:Node2D):
			var a_enemy_distance = a_enemy.global_position.distance_squared_to(player.global_position)
			var b_enemy_distance = b_enemy.global_position.distance_squared_to(player.global_position)
			return a_enemy_distance < b_enemy_distance)
		var sword_instance = sword_ability.instantiate() as SwordAbility
		var foreground_layer = get_tree().get_first_node_in_group("foreground")
		foreground_layer.add_child(sword_instance)
		sword_instance.set_chop_chop(chop_chop_activated)
		sword_instance.hitbox_component.damage = base_damage * additional_damage_percentage
		sword_instance.global_position = enemies[0].global_position
		if(%Timer.is_stopped()):
			%Timer.start()
		# Spawn the sword in a random radiusà
		sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0,TAU)) * 4
		var enemy_direction = enemies[0].global_position - sword_instance.global_position
		sword_instance.rotation = enemy_direction.angle()	
	
func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrade:Dictionary):
	# Ignore any abilities that aren't the sword rate ones
	match ability_upgrade.id:
		"sword_rate":
			var percent_reduction = current_upgrade["sword_rate"]["quantity"] * 0.20
			%Timer.wait_time = base_wait_time * (1 - percent_reduction)
		"sword_damage":
			additional_damage_percentage = 1 + current_upgrade["sword_damage"]["quantity"] * 0.50
		"chop_chop":
			chop_chop_activated = true
		"plasma_sword":	
			is_plasma_sword_active = true
