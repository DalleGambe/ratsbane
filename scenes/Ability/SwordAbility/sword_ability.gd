extends Node2D
class_name SwordAbility
@onready var hitbox_component : HitboxComponent = %HitBox

var has_chop_chop = false
var glow_time = 0.0

func _process(delta: float) -> void:
	glow_time += delta
	%Sprite2D.material.set_shader_parameter("time", glow_time)	

func set_chop_chop(is_chop_chop_unlocked:bool) -> void:
	has_chop_chop = is_chop_chop_unlocked
	if(has_chop_chop == true):
		%AnimationPlayer.play("swing")
	else:
		%AnimationPlayer.play("swing_once_down")
