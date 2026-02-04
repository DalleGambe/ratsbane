extends PanelContainer

@onready var name_label:Label = %NameLabel
@onready var description_label:Label = %"Description Label"
@onready var enable_upgrade_button: Button = %EnableUpgradeButton
@onready var amount_active_slider: HSlider = %AmountActiveSlider
@onready var audio_player: RandomSteamPlayerComponent = $AudioPlayerComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var header_container: PanelContainer = %HeaderContainer
@onready var owned_meta_upgrade_card: PanelContainer = $"."

var meta_upgrade: MetaUpgrade
var disabled_head_panel_container = preload("res://scenes/Textures/disabled_head_box_panel_container.tres")
var head_panel_container = preload("res://scenes/Textures/head_box_panel_container.tres")
var panel_container = preload("res://scenes/Textures/panel_container_texture.tres")
var disabled_panel_container = preload("res://scenes/Textures/disabled_panel_container_texture.tres")

var meta_upgrade_is_enabled = false
var is_card_loading = false
var active_quantity = 0
var owned_quantity = 1

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	amount_active_slider.value_changed.connect(on_amount_active_slider_value_changed)
	enable_upgrade_button.pressed.connect(on_enable_upgrade_button_pressed)
	
func _set_meta_upgrade(upgrade: MetaUpgrade) -> void:
	meta_upgrade = upgrade
	name_label.text = upgrade.title
	description_label.text = upgrade.get_translated_description()
	if MetaProgression.save_data["meta_upgrades"].has(meta_upgrade.id):
		active_quantity = MetaProgression.save_data["meta_upgrades"][meta_upgrade.id]["active_quantity"]
		owned_quantity = MetaProgression.save_data["meta_upgrades"][meta_upgrade.id]["owned_quantity"]
		meta_upgrade_is_enabled = MetaProgression.save_data["meta_upgrades"][meta_upgrade.id]["is_currently_active"]
	update_button_appearance(meta_upgrade_is_enabled)
	amount_active_slider.set_text_label(Util.format_float_to_string(active_quantity) + "/" + Util.format_float_to_string(owned_quantity))
	amount_active_slider.value = active_quantity
	amount_active_slider.last_value = active_quantity
	amount_active_slider.max_value = owned_quantity
	
func set_is_being_loading(is_loading:bool) -> void:
		is_card_loading = is_loading

func update_button_appearance(is_enabled:bool) -> void:
	var new_button_display_text = "ENABLE_BUTTON"
	
	if(is_enabled == true):
		new_button_display_text = "DISABLE_BUTTON"
		# apply red button textures
		enable_upgrade_button.theme_type_variation = "DisableButton" 
		name_label.theme_type_variation = "TitleLabel"
		description_label.theme_type_variation = ""
		owned_meta_upgrade_card.add_theme_stylebox_override("panel",panel_container)
		header_container.add_theme_stylebox_override("panel",head_panel_container)	
		amount_active_slider.theme_type_variation = ""
		amount_active_slider.editable = true;
		amount_active_slider.set_label_theme_type_variation("")
	else:
		# apply green button textures
		enable_upgrade_button.theme_type_variation = "EnableButton"
		name_label.theme_type_variation = "DisabledHeaderFont"
		description_label.theme_type_variation = "DisabledFont"
		owned_meta_upgrade_card.add_theme_stylebox_override("panel",disabled_panel_container)	
		header_container.add_theme_stylebox_override("panel",disabled_head_panel_container)	
		amount_active_slider.theme_type_variation = "DisabledHSlider"
		amount_active_slider.editable = false;
		amount_active_slider.set_label_theme_type_variation("DisabledFont")
	enable_upgrade_button.text = new_button_display_text

func _on_gui_input(event: InputEvent) -> void:
	if(event.is_action_pressed("left_click") and is_card_loading != true and meta_upgrade_is_enabled == true):
		animation_player.play("on_click")

func on_amount_active_slider_value_changed(value:float) -> void:
	active_quantity = value
	amount_active_slider.set_text_label(Util.format_float_to_string(active_quantity) + "/" + Util.format_float_to_string(owned_quantity))
	MetaProgression.save_data["meta_upgrades"][meta_upgrade.id]["active_quantity"] = active_quantity
	MetaProgression.save()

func on_enable_upgrade_button_pressed() -> void:
	is_card_loading = true
	if(meta_upgrade == null):
		return
	meta_upgrade_is_enabled = !meta_upgrade_is_enabled
	update_button_appearance(meta_upgrade_is_enabled)
	MetaProgression.save_data["meta_upgrades"][meta_upgrade.id]["is_currently_active"] = meta_upgrade_is_enabled
	MetaProgression.save()
	is_card_loading = false	
