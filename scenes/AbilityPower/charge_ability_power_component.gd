extends AbilityPowerComponent
class_name ChargeAbilityPowerComponent

@export var charge_speed := 2100
@export var charge_damage := 30.0
@export var charge_knockback := 1000
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var hit_box_component: HitboxComponent = %ChargeHitBoxComponent

var is_charging := false
var timer := 0.0
var player

func _ready():
	player = get_tree().get_first_node_in_group("player")
	hit_box_component.damage = charge_damage
	hit_box_component.knockback_modifier = charge_knockback
	hit_box_component.global_position = player.global_position

func trigger():
	if is_charging || not is_instance_valid(player):
		return

	AudioManager.create_2d_audio_at_location(player.global_position, SoundEffectSettings.SOUND_EFFECT_TYPE.PLAYER, "charge")
	is_charging = true
	player.is_invincible_by_powerup = true
	collision_shape_2d.disabled = false
	timer = ability_duration
	hit_box_component.damage = charge_damage
	hit_box_component.knockback_modifier = charge_knockback
	collision_shape_2d.disabled = false

	var dir = player.get_movement_vector().rotated(player.rotation)
	var val = player.get_node_or_null("VelocityComponent")
	if val:
		val.accelerate_in_direction(dir, charge_speed)

func _physics_process(delta):
	if not is_charging || not is_instance_valid(player):
		return
	
	timer -= delta
	var dir = player.get_movement_vector().rotated(player.rotation)
	player.get_node("VelocityComponent").accelerate_in_direction(dir, charge_speed)
			
	if timer <= 0:
		end_charge()

func end_charge():
	is_charging = false
	collision_shape_2d.disabled = true
	player.get_node("VelocityComponent").decelerate()
	#await get_tree().create_timer(coyote_buffer).timeout
	player.is_invincible_by_powerup = false
