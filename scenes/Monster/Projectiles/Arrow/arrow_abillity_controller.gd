extends Node

@export var arrow_projectile_scene:PackedScene
@export var arrows_being_shot:int = 1

@onready var cooldown_timer = %CooldownTimer
var owner2d
var can_shoot = true

func _ready() -> void:
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	
func _on_cooldown_timer_timeout() -> void:
	if(can_shoot == false):
		return
		
	var player = get_tree().get_first_node_in_group("player") as Node2D
	var foreground = get_tree().get_first_node_in_group("foreground")
	if owner != null:
		owner2d = owner as CharacterBody2D
	else:
		return	
	
	if player == null or foreground == null:
		return
		
	for arrow_being_shot in arrows_being_shot:
		var arrow_projectile_instance = arrow_projectile_scene.instantiate() as ArrowEnemyProjectile
		arrow_projectile_instance.owner2d = owner2d
		arrow_projectile_instance.global_position = owner2d.global_position
		arrow_projectile_instance.set_shoot_direction(player.global_position)
		foreground.add_child(arrow_projectile_instance)
