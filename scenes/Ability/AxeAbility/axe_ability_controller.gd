extends Node

@export var axe_ability_scene:PackedScene

@onready var cooldown_timer:Timer = %CooldownTimer
@onready var temp_timer: Timer = $TempTimer

var base_damage_of_axe:float = 100
var additional_damage_percentage:float = 1
var additional_throw_range = 1
var additional_speed_of_axe = 1
var base_wait_time:float

func _ready() -> void:
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	temp_timer.timeout.connect(on_temp_timer_timeout)
	base_wait_time = cooldown_timer.wait_time
	_on_cooldown_timer_timeout()
	
func on_temp_timer_timeout() -> void:
	_on_cooldown_timer_timeout()
	%CooldownTimer.start()
	
func _on_cooldown_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var foreground = get_tree().get_first_node_in_group("foreground")
	if player == null or foreground == null:
		return
	var axe_ability_instance = axe_ability_scene.instantiate() as AxeAbility
	foreground.add_child(axe_ability_instance)
	axe_ability_instance.MAX_RADIUS = axe_ability_instance.MAX_RADIUS * additional_throw_range
	axe_ability_instance.axe_swing_speed = axe_ability_instance.axe_swing_speed * additional_speed_of_axe
	axe_ability_instance.global_position = player.global_position
	axe_ability_instance.hitbox_component.damage = base_damage_of_axe * additional_damage_percentage

func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrade:Dictionary):
	# Ignore any abilities that aren't the sword rate ones
	match ability_upgrade.id:
		"double_bladed_axe_rate":
			var percent_reduction = current_upgrade["double_bladed_axe_rate"]["quantity"] * 0.20
			temp_timer.wait_time = %CooldownTimer.time_left * (1-percent_reduction)
			temp_timer.start()
			%CooldownTimer.stop()
			%CooldownTimer.wait_time = base_wait_time * (1-percent_reduction)
			ability_upgrade.update_value("axe_summon_rate",0.20*100)
			#ability_upgrade.description = tr("CHONGA_BONGA_DESCRIPTION").format({"axe_summon_rate": percent_reduction*100})
		"double_bladed_axe_damage":
			additional_damage_percentage = 1 + current_upgrade["double_bladed_axe_damage"]["quantity"] * 0.25
			ability_upgrade.update_value("axe_damage",0.25*100)
			#ability_upgrade.description = tr("GREAT_FOR_SHAVING_DESCRIPTION").format({"axe_damage": additional_damage_percentage*100})
		"double_bladed_axe_speed":
			additional_speed_of_axe = 1 + current_upgrade["double_bladed_axe_speed"]["quantity"] * 0.50
			ability_upgrade.update_value("axe_swing_speed",0.50*100)
			#ability_upgrade.description = tr("LUMBER_STUMBLER_DESCRIPTION").format({"axe_swing_speed": additional_speed_of_axe*100})
		"double_bladed_axe_range":
			additional_throw_range = 1 + current_upgrade["double_bladed_axe_range"]["quantity"] * 0.25
			ability_upgrade.update_value("axe_swing_range",0.25*100)
			#ability_upgrade.description = tr("BUSH_TRIMMER_DESCRIPTION").format({"axe_swing_range": additional_throw_range*100})
