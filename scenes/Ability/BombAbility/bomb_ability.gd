extends Node2D
class_name BombAbility

@onready var impact_hit_box_component: HitboxComponent = %ImpactHitBoxComponent
@onready var explosion_radius_component: HitboxComponent = %ExplosionRadiusComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var explosion_radius_collision_shape_2d: CollisionShape2D = $ExplosionRadiusComponent/ExplosionRadiusCollisionShape2D
@onready var boom_particles: GPUParticles2D = %BoomParticles

var baby_bombs:Array[BombAbility] = []
var glow_time = 0.0
# determines the speed of explode animation => 2.0 = dubbel de speed
var bomb_explosion_base_speed_animation = 1.5
var bomb_explosion_extra_speed_animation = 0
var selected_spawn_shrapnel_status:ShrapnelStatus.ShrapnelAmountStatus
var bomb_shard = load("res://scenes/Ability/BombAbility/bomb_shard.tscn")
var bomb_shard_damage_modifier = 1

func _ready() -> void:
	animation_player.play("fall_down")
	await animation_player.animation_finished
	animation_player.speed_scale = bomb_explosion_base_speed_animation + bomb_explosion_extra_speed_animation
	boom_particles.speed_scale = bomb_explosion_base_speed_animation + bomb_explosion_extra_speed_animation * 2
	animation_player.play("ticking")
	await animation_player.animation_finished
	animation_player.speed_scale = 1
	
func play_bomb_sfx(sfx_name:String):
	#var audio_type:SoundEffectSettings.SOUND_EFFECT_TYPE
	#if(sfx_name == "bomb_fuse"):
		#pass
		##audio_type = SoundEffectSettings.SOUND_EFFECT_TYPE.BOMB_FUSE
	#else:
		#audio_type = SoundEffectSettings.SOUND_EFFECT_TYPE.BOMB_EXPLOSION
	AudioManager.create_2d_audio_at_location(global_position, SoundEffectSettings.SOUND_EFFECT_TYPE.BOMB_EXPLOSION, sfx_name)

func _process(delta: float) -> void:
	glow_time += delta
	%Sprite2D.material.set_shader_parameter("time", glow_time)	

func spawn_shrapnel():
	#var number_of_shards:int = 0
	var flying_directions:Array = []
	match selected_spawn_shrapnel_status: 
		ShrapnelStatus.ShrapnelAmountStatus.FOUR:
			flying_directions = [
				Vector2.UP,
				Vector2.RIGHT,
				Vector2.LEFT,
				Vector2.DOWN
				]
		ShrapnelStatus.ShrapnelAmountStatus.EIGHT:
			flying_directions = [
				Vector2.UP,
				Vector2.RIGHT, 
				Vector2.LEFT,
				Vector2.DOWN,
				Vector2(1,-1).normalized(),  
				Vector2(-1,-1).normalized(),
				Vector2(1,1).normalized(),   
				Vector2(-1,1).normalized()    
			]
		ShrapnelStatus.ShrapnelAmountStatus.NONE:
			pass	
	var amount_of_shards_to_spawn = flying_directions.size()
	if(amount_of_shards_to_spawn > 0):
		for shard_index in range(amount_of_shards_to_spawn):
			var bomb_shard_instance = bomb_shard.instantiate() as BombShard
			# Based on the index set the direction
			bomb_shard_instance.set_flying_direction( flying_directions[shard_index])
			bomb_shard_instance.global_position = global_position
			get_parent().add_child(bomb_shard_instance)	
			bomb_shard_instance.hit_box_component.damage = bomb_shard_instance.damage_on_hit * bomb_shard_damage_modifier
			
func explode() -> void:
	if baby_bombs.size() > 0:
		var num_bombs = baby_bombs.size()
		var base_angle_step = TAU / num_bombs  # Base angle spacing
		var base_radius = 75  
		
		for bomb_index in range(num_bombs):
			# Add a slight random offset to the angle for non-uniform placement
			var random_angle_offset = randf_range(-base_angle_step * 0.3, base_angle_step * 0.3) 
			var angle = (bomb_index * base_angle_step) + random_angle_offset  
			
			# Add a slight random variation to the radius
			var radius = base_radius + randf_range(-15, 15)  
			
			# Calculate the bomb spawn position
			var bomb_position = Vector2(cos(angle), sin(angle)) * radius  

			# Spawn the baby bomb at the calculated position relative to the original bomb
			var baby_bomb = baby_bombs[bomb_index]
			baby_bomb.position = global_position + bomb_position
			get_parent().add_child(baby_bomb)

			# Modify the bomb properties
			#baby_bomb.explosion_radius_component.knockback_modifier = 1
			baby_bomb.impact_hit_box_component.damage = impact_hit_box_component.damage / 2
			baby_bomb.explosion_radius_component.damage = explosion_radius_component.damage / 2
			
	# Remove the original bomb
	queue_free() 
