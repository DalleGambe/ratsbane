extends BasicEnemy

@onready var visuals = %Visuals
@onready var velocity_component = %VelocityComponent

func _process(delta: float) -> void:
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	
	# The direction the bat will be walking and facing
	var face_direction_sign = sign(velocity.x)
	if(face_direction_sign != 0):
		visuals.scale = Vector2(face_direction_sign, 1)
