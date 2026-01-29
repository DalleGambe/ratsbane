extends CanvasLayer

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	GameEvents.player_got_damaged.connect(on_player_damaged)
	GameEvents.player_got_healed.connect(on_player_healed)
	
func on_player_damaged() -> void:
	animation_player.play("player_gets_hit")	
	
func on_player_healed() -> void:
	animation_player.play("player_gets_healed")		
