extends CharacterBody2D
class_name Player

@onready var damage_interval_timer = %DamageIntervalTimer
@onready var health_component:HealthComponent = %HealthComponent
@onready var health_bar = %Healthbar
@onready var abilities = %Abilities
@onready var animation_player = %AnimationPlayer
@onready var vfx_animation_player: AnimationPlayer = %VfxAnimationPlayer
@onready var visuals = %Visuals
@onready var velocity_component: VelocityComponent = %VelocityComponent
@onready var hitbox: Area2D = $Hitbox
@onready var exp_pick_up_collision_shape_2d: CollisionShape2D = %ExpPickUpCollisionShape2D
@onready var token_pick_up_collision_shape_2d: CollisionShape2D = %TokenPickUpCollisionShape2D
@onready var invincible_frames_timer: Timer = %InvincibleFramesTimer
@onready var ability_powers_controller: AbilityPowersController = %AbilityPowersController
@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D

var glow_shader = preload('res://resources/shaders/glowing_border.gdshader')

var base_speed:float = 0
var number_colliding_bodies:int = 0
var is_playing_death_animation:bool = false
var glow_time:float = 0.0
var base_token_pickup_radius:float = 32
var base_exp_pickup_radius:float = 32
var is_invincible_by_powerup:bool = false

func _ready() -> void:
	# Handle Meta Upgrade stufff
	handle_meta_upgrades()
	base_speed = velocity_component.max_speed
	health_component.health_amount_changed.connect(_on_health_changed)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.body_exited.connect(_on_hitbox_body_exited)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	GameEvents.player_collected_a_pickup.connect(on_player_collected_a_pickup)
	GameEvents.start_invincible_frames.connect(on_invincible_frames_started)
	update_health_bar_display()
	ability_powers_controller.assign_player_ability(self, "ChargeAbilityPowerComponent")

func _process(delta: float) -> void:
	if(is_playing_death_animation == false):
		glow_time += delta
		%Sprite2D.material.set_shader_parameter("time", glow_time)
		var movement_vector = get_movement_vector()
		# Normalizing since the Vector can otherwise exceed the maximum amount of targetted speed when multiplied with it
		var direction = movement_vector.normalized()

		velocity_component.accelerate_in_direction(direction)
		velocity_component.move(self)
		
		#if(movement_vector.x != 0 or movement_vector.y != 0):
			#animation_player.play("walk")
			#if(gpu_particles_2d.emitting == false):
				#gpu_particles_2d.emitting = true
			#if(is_invincible_by_powerup == true):
				#gpu_particles_2d.amount = 32
			#else:
				#gpu_particles_2d.amount = 8	
		#else:
			#animation_player.play("RESET")	
			#if(gpu_particles_2d.emitting == true):
				#await get_tree().create_timer(gpu_particles_2d.lifetime).timeout
			#gpu_particles_2d.emitting = false
			#gpu_particles_2d.restart()
		
		if(movement_vector.x != 0 or movement_vector.y != 0):
			animation_player.play("walk")
			if(is_invincible_by_powerup == true):
				gpu_particles_2d.emitting = true
				gpu_particles_2d.amount = 16
			elif(is_invincible_by_powerup == false && gpu_particles_2d.amount == 16):
				gpu_particles_2d.emitting = false
		else:
			animation_player.play("RESET")	
			gpu_particles_2d.emitting = false
		
		# The direction the player will be walking and facing 
		var face_direction_sign = sign(movement_vector.x)
		if(face_direction_sign != 0):
			visuals.scale = Vector2(-face_direction_sign, 1)

func get_movement_vector() -> Vector2:
	# Right first since it's positive, Left is negative
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left") 
	# Down first since it's positive, Up is negative 1.0 scale based on where to go
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up") 
	return Vector2(x_movement, y_movement)	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("trigger_ability"):
		ability_powers_controller.trigger_ability()
		get_tree().root.set_input_as_handled()

func should_player_take_damage() -> void:
	# If there are no enemies colliding or the timer hasn't run out don't deal damage
	if(is_invincible_by_powerup == true || number_colliding_bodies == 0 || not damage_interval_timer.is_stopped() || not invincible_frames_timer.is_stopped()):
		return
	health_component.damage(1)
	vfx_animation_player.play("blink")
	damage_interval_timer.start()

func update_health_bar_display() -> void:
	health_bar.value = health_component.get_health_percentage()	
	GameEvents.emit_updated_player_health_to(health_component.get_health_percentage(), health_component.get_max_health())
	
func on_invincible_frames_started() -> void:
	if(not invincible_frames_timer.is_stopped()):
		invincible_frames_timer.stop();
	invincible_frames_timer.start();

func handle_meta_upgrades() -> void:
	if(MetaProgression.is_meta_upgrade_enabled("healthy_diet") == true):
		var healthy_diet_meta_upgrade_count = MetaProgression.get_active_meta_upgrade_count("healthy_diet")
		health_component.max_health += 1 * healthy_diet_meta_upgrade_count
		health_component.current_health = health_component.max_health
	if(MetaProgression.is_meta_upgrade_enabled("telekinetic_reach") == true):
		var telekinetic_reach_meta_upgrade_count = MetaProgression.get_active_meta_upgrade_count("telekinetic_reach")
		var value_to_multiply_by:float = 1+(0.15*telekinetic_reach_meta_upgrade_count)
		exp_pick_up_collision_shape_2d.shape.radius = base_exp_pickup_radius * value_to_multiply_by
		token_pick_up_collision_shape_2d.shape.radius = base_token_pickup_radius * value_to_multiply_by
		
func _on_hitbox_body_entered(body: Node2D) -> void:
	number_colliding_bodies += 1
	if body.is_in_group("enemy"):
		if body.has_method("on_player_hit"):
			body.on_player_hit()
			
	#TODO: Transfer this to on_player_hit function based on enemy state
	if((body.is_in_group("enemy") || body.is_in_group("projectile") || body.is_in_group("magic_projectile"))
	 && body.has_method("trigger_death")):
		body.trigger_death()		
	should_player_take_damage()

func _on_hitbox_body_exited(body: Node2D) -> void:
	number_colliding_bodies -= 1
	
func _on_damage_interval_timer_timeout() -> void:
	should_player_take_damage()

func _on_health_changed(was_damaged:bool) -> void:
	if(was_damaged == true):
		%HitPlayerComponent.play_random_audio("hit")
		if(health_component.get_health_percentage()	== 0):
			is_playing_death_animation = true
		GameEvents.emit_player_got_damaged()
	else:		
		AudioManager.create_2d_audio_at_location(global_position, SoundEffectSettings.SOUND_EFFECT_TYPE.GAINED_HP)
	update_health_bar_display()

func on_player_collected_a_pickup(name_of_pickup:String) -> void:
	match name_of_pickup:
		"vacuum_token":
			exp_pick_up_collision_shape_2d.shape.radius = exp_pick_up_collision_shape_2d.shape.radius * 100
			await get_tree().create_timer(0.10).timeout
			exp_pick_up_collision_shape_2d.shape.radius = exp_pick_up_collision_shape_2d.shape.radius / 100
			
func on_ability_upgrade_added(ability_upgrade:AbilityUpgrade, current_upgrades:Dictionary) -> void:
	if (ability_upgrade is Ability):
		var ability = ability_upgrade as Ability
		abilities.add_child(ability.ability_controller_scene.instantiate())
	else:
		match ability_upgrade.id:
			"rat_player_increase_speed":
				velocity_component.max_speed = base_speed + base_speed * current_upgrades["rat_player_increase_speed"]["quantity"] * 0.04
