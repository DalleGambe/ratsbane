extends Node

@export var upgrade_screen_scene:PackedScene
@export var arena_stats_manager:PackedScene

var arena_stats_manager_instance
var current_upgrades:Dictionary = {}
var amount_of_upgrades_to_pick = 2
var upgrade_pool:WeightedTable = WeightedTable.new()

# Active upgrades during the run
var upgrades_in_current_run:Array[OwnedAbilityUpgrade]

# Initial Abilities	
var double_bladed_axe_ability = preload("res://resources/upgrades/double_bladed_axe.tres")
var spear_ability = preload("res://resources/upgrades/spear_ability.tres")
var bomb_ability = preload("res://resources/upgrades/bomb_ability.tres")
var pinball_massacre = preload("res://resources/upgrades/pinball_massacre.tres")

# Pinball Massacre Upgrades
var boing = preload("res://resources/upgrades/pinball/boing.tres")
var bouncy_storm = preload("res://resources/upgrades/pinball/bouncy_storm.tres")

# Bomb Upgrades
var faster_bomb_upgrade = preload("res://resources/upgrades/bomb/faster_bomb.tres")
var bombastic = preload("res://resources/upgrades/bomb/bombastic.tres")
var shorter_fuse = preload("res://resources/upgrades/bomb/shorter_fuse.tres")
var shrapnel_bomb
var more_boom_upgrade
var matryoska_bomb_upgrade

# Spear Upgrades
var toothpick_festival
var sharper_spear = preload("res://resources/upgrades/spear/sharper_spear.tres")
var piercing_echo = preload("res://resources/upgrades/spear/piercing_echo.tres")

# Axe Upgrades
var double_bladed_axe_damage_upgrade = preload("res://resources/upgrades/axe/double_bladed_axe_damage.tres")
var double_bladed_axe_rate_upgrade = preload("res://resources/upgrades/axe/double_bladed_axe_rate.tres")
var double_bladed_axe_speed_upgrade = preload("res://resources/upgrades/axe/double_bladed_axe_speed.tres")
var double_bladed_axe_range_upgrade = preload("res://resources/upgrades/axe/double_bladed_axe_range.tres")

# Sword upgrades
var sword_rate_upgrade = preload(	"res://resources/upgrades/sword/sword_rate.tres")
var sword_damage_upgrade = preload(	"res://resources/upgrades/sword/sword_damage.tres")
var sword_chop_chop_upgrade = preload(	"res://resources/upgrades/sword/sword_chop_chop.tres")
var plasma_sword_upgrade = preload(	"res://resources/upgrades/sword/plasma_sword.tres")

# Player 
var rat_player_movement_speed_upgrade = preload("res://resources/upgrades/player/rat_player_increase_speed.tres")

func _ready() -> void:
	MetaProgression.amount_of_upgrades_picked = 0
	upgrades_in_current_run.clear()
	loadAbilities()
	upgrade_pool.add_item(double_bladed_axe_ability, 10)
	upgrade_pool.add_item(spear_ability, 10)
	upgrade_pool.add_item(bomb_ability, 10)
	upgrade_pool.add_item(pinball_massacre, 10)
	upgrade_pool.add_item(sword_rate_upgrade, 15)
	upgrade_pool.add_item(sword_damage_upgrade, 15)
	upgrade_pool.add_item(plasma_sword_upgrade, 5)
	upgrade_pool.add_item(sword_chop_chop_upgrade, 10)
	upgrade_pool.add_item(rat_player_movement_speed_upgrade, 5)
	arena_stats_manager_instance = arena_stats_manager.instantiate()
	handle_meta_upgrades()

func loadAbilities():
	# Load in the following abilities since their description will otherwise not reset
	toothpick_festival = load("res://resources/upgrades/spear/toothpick_festival.tres")
	more_boom_upgrade = load("res://resources/upgrades/bomb/more_boom.tres")
	matryoska_bomb_upgrade = load("res://resources/upgrades/bomb/matryoska_bomb.tres")
	shrapnel_bomb = load("res://resources/upgrades/bomb/shrapnel_bomb.tres")
	
func apply_upgrade(upgrade:AbilityUpgrade) -> void:
	if upgrade == null:
		return
	var has_upgrade = current_upgrades.has(upgrade.id)
	if not has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
	
	update_upgrade_pool(upgrade)
	MetaProgression.amount_of_upgrades_picked += 1
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)

func update_upgrade_pool(chosen_upgrade: AbilityUpgrade) -> void:
	match chosen_upgrade.id:
		double_bladed_axe_ability.id:
			upgrade_pool.add_item(double_bladed_axe_damage_upgrade, 10)
			upgrade_pool.add_item(double_bladed_axe_rate_upgrade, 10)
			upgrade_pool.add_item(double_bladed_axe_speed_upgrade, 10)
			# Temporary out of the pool until it is reworked as it is currently more a nerf rather than a buff
			#upgrade_pool.add_item(double_bladed_axe_range_upgrade, 10)
		spear_ability.id:
			upgrade_pool.add_item(toothpick_festival, 5)
			upgrade_pool.add_item(piercing_echo, 10)
			upgrade_pool.add_item(sharper_spear, 15)
		bomb_ability.id:
			upgrade_pool.add_item(matryoska_bomb_upgrade, 5)
			upgrade_pool.add_item(more_boom_upgrade, 10)
			upgrade_pool.add_item(bombastic, 10)
			upgrade_pool.add_item(shorter_fuse, 15)
			upgrade_pool.add_item(faster_bomb_upgrade, 15)
			upgrade_pool.add_item(shrapnel_bomb, 15)
		pinball_massacre.id:
			upgrade_pool.add_item(bouncy_storm, 10)	
			upgrade_pool.add_item(boing, 10)	
		
	# if max quantity from the item has been reached, remove it from the pool
	if(chosen_upgrade.amount_that_can_be_picked == current_upgrades[chosen_upgrade.id]["quantity"]):
		upgrade_pool.remove_item(chosen_upgrade)	

func pick_upgrades() -> Array[AbilityUpgrade]:
	# returns a copy of the upgrade pool
	var chosen_upgrades:Array[AbilityUpgrade] = []
	for upgrade_picked in amount_of_upgrades_to_pick:
		# if exclude array is equal in size to all upgrades it means there are no upgrades to choose
		if (upgrade_pool.items.size() == chosen_upgrades.size()):
			break
		#else:	
			# Pick a random upgrade from the pool
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrades)
		# If return true, the upgrade stays in here, otherwise not => prevents the same upgrade from appearing in the menu
		chosen_upgrades.append(chosen_upgrade)
	return chosen_upgrades
	
func on_level_up(total_amount_of_level_ups:int):
	var amount_completed:int = 0
	for level_up in total_amount_of_level_ups:
		open_upgrade_screen(total_amount_of_level_ups-amount_completed)
		amount_completed += level_up

func open_upgrade_screen(amount_of_times_to_pick:int) -> void:
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	upgrade_screen_instance.arena_stats_manager = arena_stats_manager_instance
	upgrade_screen_instance.set_pending_levels_up_label(amount_of_times_to_pick)
	add_child(upgrade_screen_instance)
	var chosen_upgrades = pick_upgrades()
	upgrade_screen_instance._set_ability_upgrades(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)

func handle_meta_upgrades() -> void:
	var more_options_meta_upgrade_count = MetaProgression.get_active_meta_upgrade_count("more_options")
	if(MetaProgression.is_meta_upgrade_enabled("more_options")):
		amount_of_upgrades_to_pick += 1 * more_options_meta_upgrade_count
	if(MetaProgression.is_meta_upgrade_enabled("well_prepared")):
		open_upgrade_screen(1)

func on_upgrade_selected(ability_upgrade: AbilityUpgrade) -> void:
	apply_upgrade(ability_upgrade)

	if ability_upgrade is AbilityUpgrade:
		var owned_ability_upgrade = OwnedAbilityUpgrade.new()
		owned_ability_upgrade.id = ability_upgrade.id
		owned_ability_upgrade.name = ability_upgrade.name
		owned_ability_upgrade.description = ability_upgrade.description
		owned_ability_upgrade.amount_that_can_be_picked = ability_upgrade.amount_that_can_be_picked
		owned_ability_upgrade.values = ability_upgrade.values.duplicate(true)
		owned_ability_upgrade.flavour_class = ability_upgrade.flavour_class

		if owned_ability_upgrade == null:
			print("OH BOY IT WAS NULL")
			return

		# Check if the upgrade is already in the list by ID
		var found = false
		for upgrade in upgrades_in_current_run:
			if upgrade.id == owned_ability_upgrade.id:
				upgrade.owned_amount += 1 
				found = true
				break

		# If not found, add it as a new entry
		if not found:
			owned_ability_upgrade.owned_amount = 1 
			upgrades_in_current_run.append(owned_ability_upgrade)

	
