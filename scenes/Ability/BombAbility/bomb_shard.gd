extends Node2D
class_name BombShard

@export var max_travel_speed:float = 2400
@export var flying_direction:Vector2
@export var life_duration:float = 0.25
@export var damage_on_hit:float = 15
@onready var hit_box_component: HitboxComponent = %HitBoxComponent

func _ready() -> void:
	var tween = create_tween()
	tween.tween_method(tween_method, 0.0, 16.0, life_duration)
	tween.tween_callback(make_bomb_shard_disappear)
	
func tween_method(percentage:float) -> void:
	var target_rotation = flying_direction.angle() + deg_to_rad(90)
	global_position += flying_direction * max_travel_speed * get_process_delta_time()
	rotation = lerp_angle(rotation, target_rotation, 1-exp(-4 * get_process_delta_time()))

func make_bomb_shard_disappear() -> void:
	%AnimationPlayer.play("disappear")

func set_flying_direction(destination:Vector2) -> void:
	flying_direction = (destination - global_position).normalized()
