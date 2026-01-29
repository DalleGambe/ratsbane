extends Node
class_name AbilityPowersController

var active_ability: AbilityPowerComponent
@onready var ability_cooldown_timer: Timer = %AbilityCooldownTimer

func set_ability(ability: AbilityPowerComponent):
	active_ability = ability
	%AbilityCooldownTimer.wait_time = ability.cooldown_time
	
func trigger_ability():
	if active_ability && %AbilityCooldownTimer.is_stopped():
		active_ability.trigger()
		GameEvents.emit_player_triggered_ability(%AbilityCooldownTimer.wait_time, active_ability.ability_duration)
		%AbilityCooldownTimer.start()

func assign_player_ability(player:CharacterBody2D, ability_name:String):	
	var ability_scene = load("res://scenes/AbilityPower/%s.tscn" % ability_name)
	var ability_instance = ability_scene.instantiate()
	
	player.ability_powers_controller.add_child(ability_instance)
	self.set_ability(ability_instance)
