extends PanelContainer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var map_thumbnail: TextureRect = %MapThumbnail

signal map_selected

var is_selected:bool = false
	
func set_map_in_card(map: Map) -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	%MapTitleLabel.text = map.title if map.is_unlocked == true else "???"
	%MapThumbnail.texture = map.thumbnail
	if(is_selected == false):
		modulate = Color(0.502,0.502,0.502,1.0)
	
func _on_gui_input(event: InputEvent) -> void:
	if(is_selected == true):
		return
	if(event.is_action_pressed("left_click")):
		select_map()	

func _on_mouse_entered() -> void:
	if(is_selected == true):
		return
	modulate = Color(1.0,1.0,1.0,1.0)
	
func _on_mouse_exited() -> void:
	if(is_selected == true):
		return
	modulate = Color(0.502,0.502,0.502,1.0)

func select_map() -> void:
	is_selected = true
	modulate = Color(1.0,1.0,1.0,1.0)
	animation_player.play("selected")
	for other_card in get_tree().get_nodes_in_group("map_card"):
		if other_card == self:
			continue #continue with iteration, don't do anything else for this item
		elif other_card.is_selected == true:
			other_card.is_selected = false
			other_card.modulate = Color(0.502,0.502,0.502,1.0)
	await animation_player.animation_finished
	map_selected.emit()
