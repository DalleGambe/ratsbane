extends CharacterBody2D

@onready var animation_player = %AnimationPlayer
@onready var visuals = %Visuals
@export var max_speed: int = 300
@export var acceleration: float = 300
@export var death_zone: float = 2  # 1-pixel tolerance

# Variables to track the mouse
var previous_mouse_position: Vector2 = Vector2.ZERO
var mouse_still: bool = false  # Whether the mouse has stopped moving

var base_speed = 0

func _ready() -> void:
	base_speed = max_speed
	# Initialize the previous mouse position
	previous_mouse_position = get_global_mouse_position()

func _process(delta: float) -> void:
	# Update whether the mouse is still or moving
	track_mouse_movement()

	# Get the mouse position and check if it is on screen
	var mouse_position = get_global_mouse_position()
	if is_mouse_off_screen(mouse_position):
		# Stop movement if the mouse is off-screen
		velocity = Vector2.ZERO
		%AnimationPlayer.play("RESET")
		return

	# Get the X position of the mouse
	var mouse_x = mouse_position.x
	
	# Check if both conditions are met:
	# - Mouse has stopped moving
	# - Sprite's X position is within the death zone of the mouse's X position
	if mouse_still and abs(global_position.x - mouse_x) <= death_zone:
		# Stop movement
		velocity = Vector2.ZERO
		%AnimationPlayer.play("RESET")
	else:
		# Continue moving towards the mouse
		accelerate_to_point()
		move(self)
		%AnimationPlayer.play("walk")

		# Determine the direction for horizontal facing
		var face_direction_sign = sign(velocity.x)
		if face_direction_sign != 0:
			visuals.scale = Vector2(-face_direction_sign, 1)

# Check if the mouse is off the screen
func is_mouse_off_screen(mouse_position: Vector2) -> bool:
	var screen_rect = get_viewport().get_visible_rect()
	return not screen_rect.has_point(mouse_position)

func track_mouse_movement() -> void:
	# Get the current mouse position
	var current_mouse_position = get_global_mouse_position()

	# Compare the current mouse position with the previous one
	if current_mouse_position == previous_mouse_position:
		# If the mouse hasn't moved, mark it as still
		mouse_still = true
	else:
		# If the mouse has moved, mark it as not still
		mouse_still = false

	# Update the previous mouse position for the next frame
	previous_mouse_position = current_mouse_position

func accelerate_to_point() -> void:
	# Calculate direction only on the X axis (since we only care about moving horizontally)
	var direction = Vector2((get_global_mouse_position().x - global_position.x), 0).normalized()
	accelerate_in_direction(direction)

func accelerate_in_direction(direction: Vector2) -> void:
	# Calculate the desired velocity based on the direction and max speed
	var desired_velocity = direction * max_speed
	# Smoothly accelerate towards the desired velocity using linear interpolation (lerp)
	velocity = velocity.lerp(desired_velocity, 1 - exp(-acceleration * get_process_delta_time()))

func move(character_body: CharacterBody2D) -> void:
	# Move the character using move_and_slide() and update the velocity
	character_body.velocity = velocity
	character_body.move_and_slide()
	velocity = character_body.velocity
