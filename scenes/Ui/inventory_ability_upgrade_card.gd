extends PanelContainer

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var is_disabled:bool = false

func _set_ability_upgrade(upgrade: OwnedAbilityUpgrade) -> void:
	#mouse_entered.connect(on_mouse_entered)
	#mouse_exited.connect(on_mouse_exited)
	%NameLabel.text = upgrade.name
	%"Description Label".text = upgrade.get_translated_description()
	%AmountLabel.text = str(upgrade.owned_amount) + "/" + str(upgrade.amount_that_can_be_picked)
	
func play_enter_animation(delay:float = 0) -> void:
	#modulate = Color.TRANSPARENT
	#await get_tree().create_timer(delay).timeout
	%AnimationPlayer.play("enter_screen")
	
func play_discard_animation() -> void:
	%AnimationPlayer.play("discard")	
		
func on_mouse_entered() -> void:
	if(is_disabled == true):
		return
	%HoverAnimationPlayer.play("on_card_hover")

func play_card_enter_sound() -> void:
	AudioManager.create_2d_audio_at_location(global_position, SoundEffectSettings.SOUND_EFFECT_TYPE.CARD_ENTER)
