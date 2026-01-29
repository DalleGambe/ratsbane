extends Node
class_name HealthComponent

@export var max_health:float = 5
var current_health

signal health_owner_died
signal health_amount_changed(was_damaged:bool)

func _ready() -> void:
	current_health = max_health

func heal(amount_to_heal:float, cap_at_max:bool = true) -> void:
	if(cap_at_max == true):
		# Makes sure health can't go above the max
		current_health = min(current_health+amount_to_heal, max_health)
	else:
		if(current_health + amount_to_heal > max_health):
			max_health = current_health + amount_to_heal
		current_health += amount_to_heal
	health_amount_changed.emit(false)
	
func damage(damage_about_to_take:float) -> void:
	# Makes sure health can't go below into the negatives
	current_health = max(current_health-damage_about_to_take, 0)
	health_amount_changed.emit(true)
	# Call the function on the next idle frame, instead of right away
	# This way, godot won't be picky while flushing queriesd
	Callable(check_if_died).call_deferred()

func get_health_percentage() -> float:
	if max_health <= 0:
		return 0
	return min(current_health/max_health,1)

func is_at_max_health() -> bool:
	return current_health == max_health

func get_max_health() -> float:
	return max_health

func check_if_died() -> void:
	if current_health <= 0:
		health_owner_died.emit()
		# Removes the owner
		owner.queue_free()
