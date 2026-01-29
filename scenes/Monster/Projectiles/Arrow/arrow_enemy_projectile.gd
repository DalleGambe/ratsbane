extends CharacterBody2D
class_name ArrowEnemyProjectile

@export var max_speed:int = 210
var owner2d

var target_direction

func _ready() -> void:
	var tween = create_tween()
	var animation_duration:float = 2
	tween.tween_method(tween_method, 0.0, 16.0, animation_duration)
	# Remove the spear after the tween method is done
	tween.tween_callback(make_arrow_disappear)
	
func tween_method(percentage:float) -> void:
	var target_rotation = target_direction.angle() + deg_to_rad(90)
	global_position += target_direction * max_speed * get_process_delta_time()
	rotation = lerp_angle(rotation, target_rotation, 1-exp(-4 * get_process_delta_time()))

func make_arrow_disappear() -> void:
	%AnimationPlayer.play("disappear")

func set_shoot_direction(destination:Vector2) -> void:
	target_direction = (destination - global_position).normalized()
