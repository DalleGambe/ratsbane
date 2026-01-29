extends CanvasLayer

@export var owned_meta_upgrades: Array[MetaUpgrade]
@onready var grid_container: GridContainer = %GridContainer
@onready var close_button: Button = %CloseButton

var owned_meta_upgrade_card = preload("res://scenes/Ui/owned_meta_upgrade_card.tscn")
var is_closing:bool = false

func _ready() -> void:
	MenuManager._add_menu_to_list(self)
	# Remove the test cards
	for child in grid_container.get_children():
		child.queue_free()
		
	var enter_delay = 0
	close_button.pressed.connect(on_close_button_pressed)
	var pitch_to_add:float = 0
	var currently_at_card:int = 1
	var speed_scale:float = 1.0
	#owned_meta_upgrades = MetaProgression.get_all_owned_meta_upgrades()
	for meta_upgrade in owned_meta_upgrades:
		var owned_meta_upgrade_card_instace = owned_meta_upgrade_card.instantiate()
		grid_container.add_child(owned_meta_upgrade_card_instace)
		owned_meta_upgrade_card_instace._set_meta_upgrade(meta_upgrade)
		owned_meta_upgrade_card_instace.audio_player.set_pitch(1+pitch_to_add,1+pitch_to_add)
		owned_meta_upgrade_card_instace.animation_player.speed_scale = speed_scale
		#owned_meta_upgrade_card_instace.play_enter_animation(enter_delay)
		owned_meta_upgrade_card_instace.audio_player.set_pitch(1,1)
		enter_delay += 0.4
		if(currently_at_card % 2 == 0):
			pitch_to_add += 0.1
		if(currently_at_card % 8 == 0):
			speed_scale += 1
		currently_at_card += 1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		on_close_button_pressed()
		get_tree().root.set_input_as_handled()

func _exit_tree():
	MenuManager._remove_menu_from_list(self)
		
func on_close_button_pressed() -> void:
	is_closing = true
	MenuManager._remove_menu_from_list(self)
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	is_closing = false
	queue_free()
