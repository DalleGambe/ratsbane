extends CanvasLayer

signal transitioned_halfway

var skip_emit = false

func transition() -> void:
	%AnimationPlayer.play("default")
	await transitioned_halfway
	%AnimationPlayer.play_backwards("default")
	
func emit_transitioned_halfway() -> void:
	if skip_emit == true:
		skip_emit = false
		return
	transitioned_halfway.emit()
