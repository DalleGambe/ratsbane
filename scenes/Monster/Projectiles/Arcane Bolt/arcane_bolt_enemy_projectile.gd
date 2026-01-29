extends CharacterBody2D
class_name ArcaneBoltEnemyProjectile

@onready var redirect_timer: Timer = %Timer
@onready var trail_component: Trail = %TrailComponent

@export var max_speed:int = 125
@export var min_redirect_time:float = 1.2
@export var max_redirect_time:float = 3.0

var owner2d

# Where I'm I going now?
var target_direction

var animation_duration:float

func _ready() -> void:
	var tween = create_tween()
	animation_duration = redirect_timer.wait_time
	tween.tween_method(tween_method, 0.0, 16.0, animation_duration)
	redirect_timer.timeout.connect(on_redirect_timer_timeout)
	redirect_timer.start()
	
func tween_method(percentage:float) -> void:
	var target_rotation = target_direction.angle() + deg_to_rad(90)
	global_position += target_direction * max_speed * get_process_delta_time()
	rotation = lerp_angle(rotation, target_rotation, 1-exp(-4 * get_process_delta_time()))

func make_bolt_explode() -> void:
	AudioManager.create_2d_audio_at_location(global_position, SoundEffectSettings.SOUND_EFFECT_TYPE.ARCANE_EXPLOSION)
	%AnimationPlayer.play("explode")

func make_bolt_disappear() -> void:
	%AnimationPlayer.play("disappear")

func set_shoot_direction(destination:Vector2) -> void:
	target_direction = (destination - global_position).normalized()

func on_redirect_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if(player == null): 
		return;
	redirect_timer.wait_time = randf_range(min_redirect_time, max_redirect_time);
	animation_duration = redirect_timer.wait_time
		
	set_shoot_direction(player.global_position);
	create_tween().tween_method(tween_method, 0.0, 16.0, animation_duration);
	redirect_timer.start()
		
func trigger_death() -> void:
	if(owner2d != null):
		owner2d.set_is_controlling_a_bolt(false)	
	make_bolt_explode();
