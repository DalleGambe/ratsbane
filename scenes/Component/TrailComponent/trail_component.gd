class_name Trail
extends Line2D

@export var MAX_POINTS: int = 100
@onready var curve := Curve2D.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	curve.add_point(get_parent().global_position)
	if curve.get_baked_points().size() > MAX_POINTS:
		curve.remove_point(0)
	points = curve.get_baked_points()

func stop() -> void:
	set_process(false)
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 3.0)
	await tw.finished
	queue_free()

static func create() -> Trail:
	var scn = load("res://scenes/Component/TrailComponent/trail_component.tscn")
	return scn.instantiate()
