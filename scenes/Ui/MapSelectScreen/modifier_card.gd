extends PanelContainer
class_name ModifierCard

signal modifier_selected
signal mouse_entered_modifier

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var is_selected:bool = false
var is_playing_animation:bool = false
var modifier_has_been_beaten:bool
var glow_time = 0
var modifier_of_card:Modifier
var is_animation_playing

func set_modifier_in_card(modifier: Modifier) -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	modifier_of_card = modifier
	var modifier_data:Dictionary = MetaProgression.get_saved_modifier_data(modifier.id, MapManager.active_map)
	%ModifierTitleLabel.text = modifier_data.title
	%ModifierIcon.texture = modifier.icon
	is_selected = modifier_data.is_active 
	modifier_has_been_beaten = modifier_data.has_been_beaten
	%ModifierIcon.texture = modifier_of_card.icon if modifier_of_card.icon_active == null || is_selected == false else modifier_of_card.icon_active
	if(is_selected == false):
		modulate = Color(0.502,0.502,0.502,1.0)
		material.set_shader_parameter("glow_is_active", is_selected)
		%ModifierIcon.material.set_shader_parameter("glow_is_active", is_selected)	
	
func _process(delta: float) -> void:
		glow_time += delta
		material.set_shader_parameter("time", glow_time)
		%ModifierIcon.material.set_shader_parameter("time", glow_time)
		
func select_modifier() -> void:
	if is_animation_playing:
		animation_player.stop()

	is_animation_playing = true
	is_selected = not is_selected
	update_modifier_visuals(is_selected)
	animation_player.play("selected")
	await animation_player.animation_finished
	is_animation_playing = false

	modifier_of_card.is_active = is_selected
	MetaProgression.update_modifier(modifier_of_card, MapManager.active_map)
	modifier_selected.emit()

func update_modifier_visuals(selected: bool) -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0) if selected else Color(0.502, 0.502, 0.502, 1.0)
	material.set_shader_parameter("glow_is_active", selected)
	%ModifierIcon.material.set_shader_parameter("glow_is_active", is_selected)
	%ModifierIcon.texture = modifier_of_card.icon if modifier_of_card.icon_active == null || selected == false else modifier_of_card.icon_active
			
func _on_gui_input(event: InputEvent) -> void:
	if(event.is_action_pressed("left_click")):
		select_modifier()	

func _on_mouse_entered() -> void:
	mouse_entered_modifier.emit()
	if(is_selected == true):
		return
	modulate = Color(1.0,1.0,1.0,1.0)
	
func _on_mouse_exited() -> void:
	if(is_selected == true):
		return
	modulate = Color(0.502,0.502,0.502,1.0)
	
