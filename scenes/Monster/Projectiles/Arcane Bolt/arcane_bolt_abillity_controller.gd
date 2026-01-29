extends Node

@export var arcane_bolt_projectile_scene:PackedScene
@export var bolts_being_summoned:int = 1

var owner2d
var bolt_is_being_controlled:bool = false;

signal summoned_arcane_bolt;

func summon_arcane_bolt() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	var foreground = get_tree().get_first_node_in_group("foreground")
	if owner != null:
		owner2d = owner as CharacterBody2D
	else:
		return		
		
	if player == null or foreground == null:
		return
		
	for bolt_being_summoned in bolts_being_summoned:
		var arcane_bolt_projectile_instance = arcane_bolt_projectile_scene.instantiate() as ArcaneBoltEnemyProjectile
		arcane_bolt_projectile_instance.owner2d = self
		bolt_is_being_controlled = true;
		arcane_bolt_projectile_instance.global_position = owner2d.global_position
		arcane_bolt_projectile_instance.set_shoot_direction(player.global_position)
		foreground.add_child(arcane_bolt_projectile_instance)
		summoned_arcane_bolt.emit()

func is_controlling_a_bolt() -> bool:
	return bolt_is_being_controlled
	
func set_is_controlling_a_bolt(new_value:bool) -> void:
	bolt_is_being_controlled = new_value
