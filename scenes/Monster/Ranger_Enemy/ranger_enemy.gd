extends BasicEnemy

@onready var visuals: Node2D = %Visuals
@onready var velocity_component: VelocityComponent = %VelocityComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var run_away_timer: Timer = $RunAwayTimer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var random_audio_player_component: RandomAudioPlayerComponent = %RandomAudioPlayerComponent
@onready var arrow_abillity_controller: Node = %ArrowAbillityController

@export var detection_range = 350
@export var run_range = 75
@export var stab_range = 50

## 50 % Chance to run away
#var stands_still:int = randi() % 2
## 40 % chance to not move up and stay in position
#var moves_up:int = randi() % 5

var stands_still:int  = 0
var moves_up:int = 5

func _ready() -> void:
	health_component.health_amount_changed.connect(on_getting_damaged)
	arrow_abillity_controller.cooldown_timer.timeout.connect(on_arrow_being_fired)
	if(randi() % 2 == 0):
		%Sprite2D.texture = load("res://assets/monsters/Ranger/ranger_2.png")

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if(player != null):
		# Check if player is in radius to shoot
		var is_player_close_enough =  is_player_in_range(player, detection_range)
		if(is_player_close_enough == true and run_away_timer.is_stopped()):
			var is_player_in_run_range = is_player_in_range(player, run_range)
			# Check if player is too close
			#if(is_player_in_run_range == true and stands_still == 1):
			if(is_player_in_run_range == true):
				arrow_abillity_controller.can_shoot = false
				#var is_player_in_stab_range = is_player_in_range(player, stab_range)
				#if(is_player_in_stab_range == true):
					## Try to stab
					#velocity_component.accelerate_to_player()
					#velocity_component.move(self)
				#else:
				# Run away
				velocity_component.accelerate_away_from_player()
				velocity_component.move(self)
				animation_player.play("walk")
				run_away_timer.start()
			# if they aren't fire away!			
			else:
				# shoot 
				arrow_abillity_controller.can_shoot = true
				animation_player.play("RESET")
				if(arrow_abillity_controller.cooldown_timer.is_stopped()):
					arrow_abillity_controller.cooldown_timer.wait_time = randf_range(1,1.50)
					arrow_abillity_controller.cooldown_timer.start()
		# Run towards player if they aren't in range
		else:
			#if(moves_up <= 2):
				arrow_abillity_controller.can_shoot = false
				if not (run_away_timer.is_stopped()):
					#var is_player_in_stab_range = is_player_in_range(player, stab_range)
					#if(is_player_in_stab_range == true):
						## Try to stab instead
						#run_away_timer.stop()
						#velocity_component.accelerate_to_player()
					#else:	
					velocity_component.accelerate_away_from_player()
				else:	
					velocity_component.accelerate_to_player()	
				velocity_component.move(self)
				animation_player.play("walk")
	set_face_direction()	

func set_face_direction() -> void:
	# The direction the bat will be walking and facing
	var face_direction_sign = sign(velocity.x)
	if(face_direction_sign != 0):
		visuals.scale = Vector2(face_direction_sign, 1)

func on_arrow_being_fired() -> void:
	AudioManager.create_2d_audio_at_location(global_position, SoundEffectSettings.SOUND_EFFECT_TYPE.BOW_BEING_FIRED,"bow_fired")

func is_player_in_range(player:CharacterBody2D, range:float) -> bool:
	return player.global_position.distance_squared_to(global_position) < pow(range,2)
		
func on_getting_damaged(was_damaged:bool) -> void:
	random_audio_player_component.play_random_audio("hit")
