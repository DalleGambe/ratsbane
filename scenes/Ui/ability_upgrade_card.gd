extends PanelContainer

signal upgrade_selected

@onready var name_label:Label = %NameLabel
@onready var description_label:Label = %"Description Label"
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var is_disabled:bool = false

func _set_ability_upgrade(upgrade: AbilityUpgrade) -> void:
	gui_input.connect(on_gui_input)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	name_label.text = upgrade.name
	description_label.text = upgrade.get_translated_description()

func play_enter_animation(delay:float = 0) -> void:
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(delay).timeout
	animation_player.play("enter_screen")
	
func play_discard_animation() -> void:
	animation_player.play("discard")
	
func select_card() -> void:
	is_disabled = true
	animation_player.play("selected")
	for other_card in get_tree().get_nodes_in_group("upgrade_card"):
		if other_card == self:
			continue #continue with iteration, don't do anything else for this item
		other_card.modulate = Color.TRANSPARENT
	await animation_player.animation_finished
	upgrade_selected.emit()

func on_gui_input(event: InputEvent) -> void:
	if(is_disabled == true):
		return
	if(event.is_action_pressed("left_click")):
		MetaProgression.player_did_not_pick_own_cards_during_run = false
		select_card()
		
func on_mouse_entered() -> void:
	if(is_disabled == true):
		return
	%HoverAnimationPlayer.play("on_card_hover")
	
func on_mouse_exited() -> void:
	if(is_disabled == true):
		return
	%HoverAnimationPlayer.play("on_cursor_exit")
