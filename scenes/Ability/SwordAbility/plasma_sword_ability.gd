extends Node2D
class_name PlasmaSwordAbiility
@export var overshoot_distance = 40
@export var base_damage = 50
@export var trail_spacing: float = 2 

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hit_box: HitboxComponent = $HitBox
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var random_audio_player_component: RandomAudioPlayerComponent = %RandomAudioPlayerComponent
var sprite_array: Array[Sprite2D] = []
var is_swinging:bool = false
var last_spawn_pos: Vector2 = Vector2.INF 
func _ready() -> void:
	hit_box.damage = base_damage

func _process(delta: float) -> void:
	if is_swinging:
		if last_spawn_pos == Vector2.INF:
			last_spawn_pos = sprite_2d.global_position

		var current_pos = sprite_2d.global_position
		var distance = last_spawn_pos.distance_to(current_pos)

		while distance > trail_spacing:
			var next_ghost_pos = last_spawn_pos.move_toward(current_pos, trail_spacing)
			
			spawn_ghost_at(next_ghost_pos)
			
			last_spawn_pos = next_ghost_pos
			distance -= trail_spacing
			
	else:
		last_spawn_pos = Vector2.INF

func spawn_ghost_at(pos: Vector2):
	var sprite: Sprite2D = sprite_2d.duplicate()
	sprite.z_index = 0
	
	var foreground = get_tree().get_first_node_in_group("foreground")
	foreground.add_child(sprite)
	
	sprite.texture = sprite_2d.texture
	sprite.region_enabled = sprite_2d.region_enabled
	sprite.region_rect = sprite_2d.region_rect
	sprite.global_position = pos
	sprite.global_rotation = sprite_2d.global_rotation
	sprite.global_scale = sprite_2d.global_scale
	
	sprite.StartFading()

func rotate_towards(target_pos: Vector2, duration := 0.1):
	var angle = (target_pos - global_position).angle()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", angle, duration)
	
func move_to(target_pos: Vector2, duration := 0.1):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target_pos, duration)
	return tween
	
func swing_to(target_pos: Vector2, duration := 0.2):
	is_swinging = true
	random_audio_player_component.play_random_audio("")
	var start_pos = global_position
	var tween = get_tree().create_tween()
	var dir = (target_pos - start_pos).normalized()
	target_pos += dir * overshoot_distance
		
	tween.tween_method(
		func(value):
			global_position = value,
			start_pos,
			target_pos,
			duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	var angle = (target_pos - start_pos).angle()
	tween.parallel().tween_property(self, "rotation", angle, duration)
	
	return tween
