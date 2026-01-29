extends CanvasLayer

@onready var grid_container: GridContainer = %GridContainer
@onready var close_button: Button = %CloseButton
@onready var upgrades_collected_amount_label: Label = %UpgradesCollectedAmountLabel
@onready var search_bar: LineEdit = %Searchbar  # Add a reference to the search bar

var is_closing: bool = false
var inventory_upgrade_card_scene = preload("res://scenes/Ui/inventory_ability_upgrade_card.tscn")
var upgrades_on_screen: Array[OwnedAbilityUpgrade]  # Stores all available upgrades
var filtered_upgrades: Array[OwnedAbilityUpgrade]  # Stores filtered upgrades

func _ready() -> void:
	MenuManager._add_menu_to_list(self)
	close_button.pressed.connect(on_close_button_pressed)
	search_bar.text_changed.connect(on_search_text_changed)  # Listen for text changes

	filtered_upgrades = upgrades_on_screen
	upgrades_collected_amount_label.text = str(get_owned_total_amount()) + "/34"
	
	# Remove the test cards
	for child in grid_container.get_children():
		child.queue_free()
		
	%AnimationPlayer.play("fade in")
	await %AnimationPlayer.animation_finished
	
	# Show all upgrades initially
	filtered_upgrades = upgrades_on_screen.duplicate()
	set_abilities_shown(filtered_upgrades)

func get_owned_total_amount() -> int:
	var total: int = 0
	for upgrade in filtered_upgrades:
		total += upgrade.owned_amount
	return total	

func set_abilities_shown(upgrades: Array[OwnedAbilityUpgrade]) -> void:
	# Clear UI
	for child in grid_container.get_children():
		child.queue_free()
	
	# Add filtered upgrades to the grid
	for ability_upgrade in upgrades:
		var inventory_card_instance = inventory_upgrade_card_scene.instantiate()
		grid_container.add_child(inventory_card_instance)
		inventory_card_instance._set_ability_upgrade(ability_upgrade)

func on_search_text_changed(search_text: String) -> void:
	search_text = search_text.to_lower().strip_edges()  # Normalize input
	filtered_upgrades.clear()

	print("🔍 Search Query:", search_text)

	# Show all if search is empty
	if search_text.is_empty():
		filtered_upgrades = upgrades_on_screen.duplicate()
	else:
		for upgrade in upgrades_on_screen:
			var name_lower = tr(upgrade.name).to_lower()
			var desc_lower = tr(upgrade.description).to_lower()
			
			# Debugging output
			print("Checking:", name_lower, "|", desc_lower)
			
			# If the search text is in name or description, add to filtered list
			if search_text in name_lower or search_text in desc_lower:
				filtered_upgrades.append(upgrade)

	print("📋 Filtered List After Search:", filtered_upgrades.size())

	# Update UI
	set_abilities_shown(filtered_upgrades)
	upgrades_collected_amount_label.text = str(get_owned_total_amount()) + "/34"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_run_inventory") or event.is_action_pressed("close_run_inventory"):
		on_close_button_pressed()
		get_tree().root.set_input_as_handled()

func fade_out_menu() -> void:
	for upgrade_card in grid_container.get_children():
		upgrade_card.animation_player.play("discard")
	%AnimationPlayer.play("fade out")
	await %AnimationPlayer.animation_finished

func _exit_tree():
	MenuManager._remove_menu_from_list(self)

func on_close_button_pressed() -> void:
	is_closing = true
	fade_out_menu()
	await get_tree().create_timer(0.2).timeout
	MenuManager._remove_menu_from_list(self)
	MusicPlayer.volume_db += 5
	queue_free()
