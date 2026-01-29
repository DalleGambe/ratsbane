extends CanvasLayer

@onready var meta_upgrades: Array[MetaUpgrade]
@onready var grid_container: GridContainer = %GridContainer
@onready var back_button: Button = %BackButton
@onready var open_card_inventory_button: Button = %OpenCardInventoryButton

var meta_upgrade_card_scene = preload("res://scenes/Ui/meta_upgrade_card.tscn")
var inventory_scene = preload("res://scenes/Ui/inventory_menu.tscn")

func _ready() -> void:
	meta_upgrades = MetaUpgradeManager.meta_upgrades
	GameEvents.unlock_inventory.connect(update_inventory_button_availability)
	# Remove the test cards
	for child in grid_container.get_children():
		child.queue_free()
		
	var enter_delay = 0
	back_button.pressed.connect(on_back_button_pressed)
	open_card_inventory_button.pressed.connect(on_open_card_inventory_button_pressed)
	meta_upgrades.sort_custom(func(upgrade_a, upgrade_b): return upgrade_a["experience_cost"] < upgrade_b["experience_cost"])
	meta_upgrades.sort_custom(func(upgrade_a, upgrade_b): return MetaProgression.is_meta_upgrade_sold_out_integer(upgrade_a) < MetaProgression.is_meta_upgrade_sold_out_integer(upgrade_b))
	var pitch_to_add:float = 0
	var currently_at_card:int = 1
	var speed_scale:float = 1.0
	for meta_upgrade in meta_upgrades:
		var meta_upgrade_card_instace = meta_upgrade_card_scene.instantiate()
		grid_container.add_child(meta_upgrade_card_instace)
		meta_upgrade_card_instace._set_meta_upgrade(meta_upgrade)
		meta_upgrade_card_instace.audio_player.set_pitch(1+pitch_to_add,1+pitch_to_add)
		meta_upgrade_card_instace.animation_player.speed_scale = speed_scale
		#meta_upgrade_card_instace.play_enter_animation(enter_delay)
		#meta_upgrade_card_instace.audio_player.set_pitch(1,1)			
		#enter_delay += 0.4
		#if(currently_at_card % 2 == 0):
			#pitch_to_add += 0.1
		#if(currently_at_card % 8 == 0):
			#speed_scale += 1
		#currently_at_card += 1
	update_inventory_button_availability()		

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		on_back_button_pressed()

func on_back_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/Ui/MainMenu.tscn")	
	
func update_inventory_button_availability() -> void:
	MetaProgression.check_if_inventory_unlocked_exists()
	if(MetaProgression.save_data["meta_stats"]["inventory_unlocked"] == true):
		open_card_inventory_button.disabled = false		
	else:
		open_card_inventory_button.disabled = true	
	
func on_open_card_inventory_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	var inventory_instance = inventory_scene.instantiate()
	var owned_meta_upgrades:Array[MetaUpgrade] = []
	for meta_upgrade in meta_upgrades:
		if(MetaProgression.save_data["meta_upgrades"].has(meta_upgrade.id)):
			if(MetaProgression.save_data["meta_upgrades"][meta_upgrade.id]["owned_quantity"] > 0):
				owned_meta_upgrades.append(meta_upgrade)
	inventory_instance.owned_meta_upgrades = owned_meta_upgrades
	add_child(inventory_instance)
