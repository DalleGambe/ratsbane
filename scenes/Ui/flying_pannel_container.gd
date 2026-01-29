extends PanelContainer

func play_enter_animation() -> void:
	%AnimationPlayer.play("fly in")
	
func play_exit_animation() -> void:
	%AnimationPlayer.play_backwards("fly in")
