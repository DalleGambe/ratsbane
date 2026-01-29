extends BasicBoss

@onready var health_component: HealthComponent = %HealthComponent
@onready var velocity_component: VelocityComponent = %VelocityComponent
@onready var visuals: Node2D = %Visuals

func _ready() -> void:
	health_component.max_health = randf_range(min_health, max_health)
	health_component.current_health = health_component.max_health
	velocity_component.max_speed = default_movement_speed
	health_component.health_amount_changed.connect(on_health_changed)

func _physics_process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)
	set_face_direction()	

func set_face_direction() -> void:
	# The direction the bat will be walking and facing
	var face_direction_sign = sign(velocity.x)
	if(face_direction_sign != 0):
		visuals.scale = Vector2(face_direction_sign, 1)
	
func execute_move(move_name:String) -> void:
	match move_name:
		"aaa":
			pass
		"aaaa":
			pass
		"aaaaaaa":
			pass
		"aaaaaaa":
			pass
		"bbbbbb":
			pass			

# Decides what move
func get_next_move() -> void:
	pass

func on_health_changed() -> void:
	GameEvents.emit_update_boss_bar(health_component.current_health)
