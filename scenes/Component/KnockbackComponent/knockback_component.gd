extends Node
class_name KnockbackComponent

var knockback_strength = 0
var knockback_direction = Vector2.ZERO
var owner_node2d
var _damage_source: HitboxComponent
var knockback_velocity = Vector2.ZERO
var apply_knockback_now = false

# Function to add knockback to the owner
func add_knockback_to_owner() -> void:
	if owner == null or _damage_source == null:
		return
	
	owner_node2d = owner as CharacterBody2D
	
	# Calculate knockback strength based on the damage and knockback modifier
	knockback_strength = _damage_source.damage * _damage_source.knockback_modifier
	
	# Calculate knockback direction based on the position of the damage source relative to the owner
	var direction_to_damage_source = (owner_node2d.global_position - _damage_source.global_position).normalized()
	knockback_direction = direction_to_damage_source
	
	# Apply the knockback velocity
	knockback_velocity = knockback_direction * knockback_strength
	apply_knockback_now = true

# Physics process for applying knockback
func _physics_process(delta: float) -> void:
	if _damage_source != null and apply_knockback_now == true:
		pass
		#owner_node2d = owner as CharacterBody2D
		#
		## Apply the knockback velocity to the owner
		#owner_node2d.velocity += knockback_velocity
		#
		## Gradually reduce the knockback velocity (smooth decay over time)
		#knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 1 - exp(-5 * delta)) # Adjust the decay rate as needed
		#
		## Check if the knockback velocity is close to zero, then stop applying knockback
		#if knockback_velocity.length() < 0.1:
			#knockback_velocity = Vector2.ZERO
			#apply_knockback_now = false
		#
		## Move the character with the updated velocity
		#owner_node2d.move_and_slide()
