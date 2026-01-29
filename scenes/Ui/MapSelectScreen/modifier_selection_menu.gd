extends CanvasLayer

@onready var modifier_title_label: Label = %ModifierTitleLabel
@onready var modifier_description_label: Label = %ModifierDescriptionLabel
@onready var time_line: ColorRect = %TimeLine
@onready var modifiers_container: MarginContainer = %ModifiersContainer
@onready var back_button: Button = %BackButton
@onready var continue_button: Button = %ContinueButton
@onready var map_modifier_select_grid_container: GridContainer = %MapModifierSelectGridContainer
@onready var no_modifiers_available: Label = %NoModifiersAvailable

var map_select_modifier_card_scene = preload("res://scenes/Ui/MapSelectScreen/modifier_card.tscn")

var selected_map:Map 

func _ready() -> void:
	# remove placeholders
	for map_modifier_card in map_modifier_select_grid_container.get_children():
		map_modifier_card.queue_free()
		
	continue_button.pressed.connect(on_continue_button_pressed)
	back_button.pressed.connect(on_back_button_pressed)
	
	# get the selected map from the map manager
	selected_map = MapManager.get_active_map()
	print(selected_map)
		
	# If the active map is valid and it has any modifiers
	if(selected_map != null && selected_map.modifiers.size() > 0):
		map_modifier_select_grid_container.visible = true
		no_modifiers_available.visible = false
		for modifier:Modifier in selected_map.modifiers:
			var modifier_card_instance:ModifierCard = map_select_modifier_card_scene.instantiate()
			modifier_card_instance.set_modifier_in_card(modifier)
			map_modifier_select_grid_container.add_child(modifier_card_instance)
			modifier_card_instance.mouse_entered_modifier.connect(on_mouse_entered_modifier.bind(modifier))
			modifier_card_instance.mouse_exited.connect(on_mouse_exited_modifier)
			modifier_card_instance.modifier_selected.connect(on_modifier_selected.bind(modifier))
	else:
		# Show label instead saying that there are no modifiers for the map
		map_modifier_select_grid_container.visible = false
		no_modifiers_available.visible = true	

func on_mouse_entered_modifier(modifier:Modifier) -> void:
	modifier_title_label.text = modifier.title
	modifier_description_label.text  = modifier.description

func on_mouse_exited_modifier() -> void:
	modifier_title_label.text = ""
	modifier_description_label.text = ""

func on_continue_button_pressed() -> void:
	if(selected_map == null):
		return;
	
	# Update the active map with the modifiers updated
	MapManager.set_active_map(selected_map)
		
	# Do the regular transition and move onto the selected map
	MusicPlayer.stop()
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/Main/main.tscn")

func on_back_button_pressed() -> void:
	# If the player is on the map screen, return to the selection screen, use different animation here later
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	#get_tree().change_scene_to_file("res://scenes/Ui/MapSelectScreen/MapSelectionMenu.tscn")	
	get_tree().change_scene_to_file("res://scenes/Ui/MainMenu.tscn")	

func on_modifier_selected(modifier:Modifier) -> void:
	selected_map.modifiers[selected_map.modifiers.find(modifier)].is_active = !selected_map.modifiers[selected_map.modifiers.find(modifier)].is_active
