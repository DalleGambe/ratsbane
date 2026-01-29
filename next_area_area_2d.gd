extends CharacterBody2D
class_name NextArea

@onready var wall_sprite_2d: Sprite2D = %WallSprite2D
@onready var door_sprite_2d: Sprite2D = %DoorSprite2D
@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var next_area: Area2D = $NextArea
@onready var collision_door_detection_shape: CollisionShape2D = %CollisionDoorDetectionShape

@export var wall_sprite: Texture2D
@export var door_sprite: Texture2D
@export var door_sprite_closed: Texture2D
@onready var guard_door_detection_range: Area2D = %GuardDoorDetectionRange

var path_to_next_area:String

var end_screen = preload("res://scenes/Ui/end_screen.tscn")

func _ready() -> void:
	next_area.body_entered.connect(on_body_entered)
	guard_door_detection_range.body_entered.connect(on_2d_body_entered)
	set_wall_texture()
	
func set_next_area(path:String) -> void:
	path_to_next_area = path

func set_door_texture(is_closed:bool = false) -> void:
	if(is_closed == true):
		door_sprite_2d.texture = door_sprite_closed
	else:	
		door_sprite_2d.texture = door_sprite
	
func set_wall_texture() -> void:
	wall_sprite_2d.texture = wall_sprite
	gpu_particles_2d.texture = wall_sprite

func on_2d_body_entered(body:Node2D) -> void:
	if(body.is_in_group("player")):
		#collision_door_detection_shape.disabled = true
		# Pause player movement
		# Code
		# Pause enemies
		# Code
		# Pause Enemy Manager
		# Code
		%AnimationPlayer.play("close_door")
		await %AnimationPlayer.animation_finished
		await get_tree().create_timer(0.75).timeout
		# Camera pan over
		# Black bars
		# Spawn boss in top and bottom
			# Play animation
			# Play text
		# Health bar comes in
		# Camera pan back over
		# Bars go poof
		# Unfreeze Player
		# Unfreeze Enemies
		
func on_body_entered(body:Node2D) -> void:
	# If the body is a player
	if(body.is_in_group("player")):
		MetaProgression.was_player_on_full_health = body.health_component.is_at_max_health()
		# Make them disappear
		body.queue_free()
		# Play door close animation
		%AnimationPlayer.play("close_door")
		await %AnimationPlayer.animation_finished
		await get_tree().create_timer(0.75).timeout
		var victory_screen_instance = end_screen.instantiate() as EndScreen
		victory_screen_instance.did_player_win_game = true
		get_tree().get_first_node_in_group("foreground").add_child(victory_screen_instance)
		victory_screen_instance.play_jingle("victory")
		MetaProgression.save()
