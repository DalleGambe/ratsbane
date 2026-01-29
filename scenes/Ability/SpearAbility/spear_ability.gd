extends Node2D
class_name SpearAbility

const MAX_RADIUS:float = 20

@export var max_speed:int = 400

@onready var hitbox_component = %HitBoxComponent

var target_direction
var turn_around_after_first_throw = false
var base_duration:float = 1.25
var glow_time:float = 0.0

func _ready() -> void:
	if(turn_around_after_first_throw == true):
		base_duration = 0.625
	move_spear(base_duration)

func _process(delta: float) -> void:
	glow_time += delta
	%Sprite2D.material.set_shader_parameter("time", glow_time)

func move_spear(animation_duration:float = 1.25) -> void:
	var tween = create_tween()
	tween.tween_method(tween_method, 0.0, 16.0, animation_duration)
	# Remove the spear after the tween method is done
	tween.tween_callback(make_spear_disappear)
	
func tween_method(percentage:float) -> void:
	var target_rotation = target_direction.angle() + deg_to_rad(45)
	global_position += target_direction * max_speed * get_process_delta_time()
	rotation = lerp_angle(rotation, target_rotation, 1-exp(-4 * get_process_delta_time()))

func make_spear_disappear() -> void:
	# if turn around is true
	if(turn_around_after_first_throw == true):
		# set it to false		
		turn_around_after_first_throw = false
		var player = get_tree().get_first_node_in_group("player")
		if(player != null):	
			# Make spear bounce back to player
			set_throw_direction(player.global_position)
		else:
			# make the code repeat itself, but mirror throw direction
			target_direction = -target_direction
		move_spear()
	else:
		# disappear	
		%AnimationPlayer.play("disappear")

func set_throw_direction(destination:Vector2) -> void:
	target_direction = (destination - global_position).normalized()
