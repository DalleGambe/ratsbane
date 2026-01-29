extends BasicEnemy

@onready var visuals = %Visuals
@onready var velocity_component = %VelocityComponent
@export var detection_radius = 2
@onready var health_component: HealthComponent = $HealthComponent

var is_player_close_enough

func _ready() -> void:
	health_component.health_amount_changed.connect(on_getting_damaged)

func _physics_process(delta):
	if being_knocked_back:
		velocity_component.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)

		if knockback_velocity.length() < 10:
			being_knocked_back = false
	else:
		velocity_component.accelerate_to_player()
	velocity_component.move(self)
	set_face_direction()	

func set_face_direction() -> void:
	# The direction the bat will be walking and facing
	var face_direction_sign = sign(velocity.x)
	if(face_direction_sign != 0):
		visuals.scale = Vector2(face_direction_sign, 1)

func on_getting_damaged(was_damaged:bool) -> void:
	$RandomSfxHitPlayerComponent.play_random_audio("hit")
