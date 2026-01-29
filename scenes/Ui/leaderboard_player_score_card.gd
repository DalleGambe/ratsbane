extends PanelContainer

@onready var ranking_label: Label = %RankingLabel
@onready var name_label: Label = %NameLabel
@onready var score_label: Label = %ScoreLabel

var original_margin_left: float = 0
var hover_offset:float = -16.0
var is_hovered: bool = false
var tween: Tween

func _ready() -> void:
	# We delay storing global_position to next frame so the layout has settled
	await get_tree().process_frame
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_player_score(score: Dictionary, rank: int) -> void:
	ranking_label.text = str(rank) + "#"
	name_label.text = score["player_name"]
	score_label.text = str(score["score"])

func _on_mouse_entered() -> void:
	is_hovered = true
	_start_tween_to(hover_offset)
	
func _on_mouse_exited() -> void:
	is_hovered = false
	_start_tween_to(0)

func _start_tween_to(target: float) -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "offset_left", target, 0.15)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
