extends CharacterBody2D

@onready var visuals = %Visuals
@onready var velocity_component = %VelocityComponent
@export var detection_radius = 2
@onready var health_component: HealthComponent = $HealthComponent
@onready var navigation_agent_2d: NavigationAgent2D = %NavigationAgent2D

var is_player_close_enough
var movement_speed = 112.0

func _ready() -> void:
	health_component.health_amount_changed.connect(on_getting_damaged)
	navigation_agent_2d.velocity_computed.connect(on_navigation_agent_2d_velocity_computed)

var last_target_position: Vector2 = Vector2.ZERO
const TARGET_UPDATE_THRESHOLD := 8.0

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		var player_pos = player.global_position
		if player_pos.distance_to(last_target_position) > TARGET_UPDATE_THRESHOLD:
			navigation_agent_2d.target_position = player_pos
			last_target_position = player_pos

	if not navigation_agent_2d.is_navigation_finished():
		var next_path_position = navigation_agent_2d.get_next_path_position()
		var new_velocity = global_position.direction_to(next_path_position) * movement_speed
		self.velocity = new_velocity
		if navigation_agent_2d.avoidance_enabled:
			navigation_agent_2d.set_velocity(new_velocity)
		else:
			on_navigation_agent_2d_velocity_computed(new_velocity)
	else:
		self.velocity = Vector2.ZERO

	move_and_slide()

func set_face_direction() -> void:
	# The direction the bat will be walking and facing
	var face_direction_sign = sign(velocity.x)
	if(face_direction_sign != 0):
		visuals.scale = Vector2(face_direction_sign, 1)

func on_navigation_agent_2d_velocity_computed(safe_velocity:Vector2) -> void:
	pass

func on_getting_damaged(was_damaged:bool) -> void:
	$RandomSfxHitPlayerComponent.play_random_audio("hit")
