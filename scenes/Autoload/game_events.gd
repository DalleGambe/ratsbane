extends Node

signal experience_vial_collected(amount_of_experience:float)
signal ability_upgrade_added(ability_upgrade:AbilityUpgrade, current_upgrades:Dictionary)
signal player_got_damaged
signal player_got_healed
signal player_dealt_damage(damage_dealt:float)
signal player_died
signal unlock_inventory(should_be_unlocked:bool)
signal door_to_next_area_should_open
signal player_collected_a_pickup
signal player_triggered_ability
signal updated_player_health_to(player_health:float, player_max_health:float)
signal start_invincible_frames
signal update_boss_health_bar(current_boss_health:float)

func emit_experience_vial_collected(amount_of_experience: float) -> void:
	experience_vial_collected.emit(amount_of_experience)

func emit_ability_upgrade_added(ability_upgrade:AbilityUpgrade, current_upgrades:Dictionary) -> void:
	ability_upgrade_added.emit(ability_upgrade, current_upgrades)

func emit_player_collected_a_pickup(name_of_pickup: String) -> void:
	player_collected_a_pickup.emit(name_of_pickup)
	
func emit_player_triggered_ability(cooldown_amount:float, ability_duration:float) -> void:
	player_triggered_ability.emit(cooldown_amount, ability_duration)	
	
func emit_player_got_damaged() -> void:
		player_got_damaged.emit()

func emit_player_got_healed() -> void:
		player_got_healed.emit()		

func emit_player_dealt_damage(damage_dealt:float) -> void:
	player_dealt_damage.emit(damage_dealt)

func emit_updated_player_health_to(player_health_percentage: float, player_max_health:float) -> void: 
	updated_player_health_to.emit(player_health_percentage, player_max_health)

func emit_door_to_next_area_should_open() -> void:
	door_to_next_area_should_open.emit()

func emit_unlock_inventory(should_be_unlocked:bool) -> void:
	unlock_inventory.emit(should_be_unlocked)	
	
func emit_invincible_frames_started() -> void:
	start_invincible_frames.emit()

func emit_update_boss_bar(current_boss_health:float) -> void:
	update_boss_health_bar.emit(current_boss_health)
