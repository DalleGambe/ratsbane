extends Camera2D
class_name GameCamera 

var target_position = Vector2.ZERO
var smoothing_camera_value = 20
var ignore_target = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(ignore_target == false):
		_aqcuire_target()
	else:
		go_to(target_position)	
	# Lineair interpolate (Basically having a start and end position % of position between two positions)
	global_position = global_position.lerp(target_position, 1.0-exp(-delta*smoothing_camera_value))
	
# Aqcuires the target position if the player exists
func _aqcuire_target():
	if(ignore_target == true):
		ignore_target = false
	var player_nodes = get_tree().get_nodes_in_group("player")
	if(player_nodes.size() > 0):
		var player = player_nodes[0] as Node2D
		target_position = player.global_position
		
func go_to(position:Vector2) -> void:
	#print("GOING FROM " + str(target_position)  " TO " + str(position))
	ignore_target = true
	target_position = position
