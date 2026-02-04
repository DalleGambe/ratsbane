extends Area2D
class_name HurtboxComponent

@export var health_component: HealthComponent
@export var blood_splatter_component: BloodSplatterComponent
@export var knockback_component: KnockbackComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(other_area: Area2D) -> void:
	# if the area isn't the hitbox one
	if not other_area is HitboxComponent:
		return
	
	do_knockback_logic(other_area)	
	do_damage_logic(other_area)
	
func do_damage_logic(other_area:Area2D) -> void:
	if health_component == null:
		return
		
	var hitbox_component = other_area as HitboxComponent
	
	var format_string: String = "%0.1f"
	if round(hitbox_component.damage) == hitbox_component.damage:
		format_string = "%0.0f"

	var final_damage_number = format_string % hitbox_component.damage as float
	
	if(SettingsManager.get_damage_number_setting() == true):
		# Get the floating text from the pool
		var floating_text = FloatingTextManager.get_floating_text("damage_number")
		floating_text.show()
		# Add the floating text back to the scene
		get_tree().get_first_node_in_group("foreground").add_child(floating_text)
		# Set position and start the animation
		floating_text.global_position = global_position + (Vector2.UP * 16)
		# Start the animation
		floating_text.start_animation(str(final_damage_number))
	
	# Deal damage
	health_component.damage(final_damage_number)
	
	if(blood_splatter_component != null):
		blood_splatter_component.damage_taken = final_damage_number
	if(final_damage_number > 0):
		GameEvents.emit_player_dealt_damage(final_damage_number)
		
	if other_area.is_in_group("temporary_projectile"):
		other_area.owner.call_deferred("queue_free")	

func do_knockback_logic(other_area:Area2D) -> void:
	if not other_area is HitboxComponent:
		return
	if other_area.knockback_modifier == 0 || !owner.has_method("apply_knockback"):		
		return;
		
	var dir = (global_position - other_area.global_position).normalized()
	owner.apply_knockback(dir, other_area.knockback_modifier)	
