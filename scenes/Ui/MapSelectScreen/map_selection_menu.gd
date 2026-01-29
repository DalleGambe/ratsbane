extends CanvasLayer

@onready var map_select_grid_container: GridContainer = %MapSelectGridContainer
@onready var maps: Array[Map]
@onready var map_title_label: Label = $MarginContainer/HBoxContainer/CurrentMapVboxContainer/MapTitleLabel
@onready var map_description_label: Label = $MarginContainer/HBoxContainer/CurrentMapVboxContainer/MapDescriptionLabel
@onready var time_line_container: MarginContainer = %TimeLineContainer
@onready var time_line: ColorRect = %TimeLine
@onready var current_map_vbox_container: VBoxContainer = %CurrentMapVboxContainer
@onready var back_button: Button = %BackButton
@onready var continue_button: Button = %ContinueButton

var map_select_card_scene = preload("res://scenes/Ui/MapSelectScreen/map_select_card.tscn")
var map_select_modifier_card_scene = preload("res://scenes/Ui/MapSelectScreen/modifier_card.tscn")

var selected_map:Map 

func _ready() -> void:
	# remove placeholders
	for map_placeholder_card in map_select_grid_container.get_children():
		map_placeholder_card.queue_free()	
		
	continue_button.pressed.connect(on_continue_button_pressed)
	back_button.pressed.connect(on_back_button_pressed)
	
	# get the maps from the map manager
	maps = MapManager.get_maps()
	
	# Set the default selected map
	on_map_selected(MapManager.get_active_map())
	
	if(maps == null or maps.size() <= 0):
		return;
		
	# Load in the map cards
	for map:Map in maps:
		# Initialize the map scene
		var map_select_card_instance = map_select_card_scene.instantiate()
		
		# if the map is equal to the selected one aka the last played map
		if(map.id == selected_map.id):
			# Set it to the selected one
			map_select_card_instance.is_selected = true
		
		# add the card to the container
		map_select_grid_container.add_child(map_select_card_instance)

		# Set the map from the list onto the card
		map_select_card_instance.set_map_in_card(map)
		
		# Bind the map so that when it is selected, it is assigned at the new one
		map_select_card_instance.map_selected.connect(on_map_selected.bind(map))

func on_continue_button_pressed() -> void:
	if(selected_map == null):
		return;
		
	# if showing_map_modifiers is false AND the map that is selected is unlocked by the player
	if(selected_map.is_unlocked == true):
		# Do the transition animation
		# code
		# wait until animation is finished
		# set showing_map_modifiers to true
		
		MapManager.set_active_map(selected_map)
		
		# Do the regular transition and move onto the selected map
		ScreenTransition.transition()
		await ScreenTransition.transitioned_halfway
		get_tree().change_scene_to_file("res://scenes/Ui/MapSelectScreen/ModifierSelectionMenu.tscn")

func on_back_button_pressed() -> void:
	# If the player is on the map screen, return to the main menu
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/Ui/MainMenu.tscn")	

func on_map_selected(chosen_map:Map) -> void:
	selected_map = chosen_map
	# Do same animation as card
	# wait until halfway
	map_title_label.text = selected_map.title
	map_description_label.text  = selected_map.description
