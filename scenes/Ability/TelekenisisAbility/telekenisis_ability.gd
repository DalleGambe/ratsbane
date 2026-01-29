extends Node2D
class_name TelekenisisAbility

@onready var hit_box_component: HitboxComponent = $HitBoxComponent

@export var enemy:CharacterBody2D

var glow_shader = preload('res://resources/shaders/glowing_border.gdshader')
var enemy_target

func _ready() -> void:
	if(enemy != null):
		set_glow_on_enemy(true)
		var tween = create_tween()
		tween.set_parallel()
		# Tween enemy to go up
		tween.tween_property(enemy, "position:y", position.y+16, 0.6)\
		.set_ease(Tween.EASE_IN)\
		.set_trans (Tween.TRANS_SINE)
		tween.chain()
		var position_to_go_to = enemy.global_position + Vector2(0,8)
		if(enemy_target != null):
			position_to_go_to = enemy_target.global_position
		# Tween enemy to go to the other enemy in question
		tween.tween_property(enemy, "position", position_to_go_to, 0.6)\
		.set_ease(Tween.EASE_IN)\
		.set_trans (Tween.TRANS_SINE)
		tween.chain()
		tween.tween_callback(set_glow_on_enemy)			

func set_target(enemy) -> void:
	enemy_target = enemy
	
func set_glow_on_enemy(should_glow:bool = false) -> void:
	pass
	#var shader_material = ShaderMaterial.new()
	#shader_material.shader = glow_shader
	#shader_material.set_shader_parameter("color",Vector4(0.659,0.314,0.682,1))
	#shader_material.set_shader_parameter("width",2)
	#if(should_glow == false):
		#shader_material = ShaderMaterial.new()
	#if(enemy != null):
		#enemy.get_node("Visuals").get_node("Sprite2D").material = shader_material
		#var weapon_sprite = enemy.get_node("Visuals").get_node("Weapon")
		#if(weapon_sprite != null):
			#weapon_sprite.material = shader_material
	
