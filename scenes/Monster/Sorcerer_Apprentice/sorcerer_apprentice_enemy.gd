extends BasicEnemy

@onready var visuals: Node2D = %Visuals
@onready var velocity_component: VelocityComponent = %VelocityComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var random_audio_player_component: RandomAudioPlayerComponent = %RandomAudioPlayerComponent
@onready var arcane_bolt_abillity_controller: Node = %ArcaneBoltAbillityController

@export var detection_range:float = 250

func _ready() -> void:
	health_component.health_amount_changed.connect(on_getting_damaged)
	health_component.health_owner_died.connect(on_health_owner_dying)
	arcane_bolt_abillity_controller.summoned_arcane_bolt.connect(on_arcane_bolt_being_summoned)
	var player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if not (arcane_bolt_abillity_controller.is_controlling_a_bolt()):
		# Check if player is in radius to shoot
		var player = get_tree().get_first_node_in_group("player")
		if(player != null && player_is_in_range(player, detection_range)):
			%AnimationPlayer.play("summon_arcane_bolt")
			arcane_bolt_abillity_controller.summon_arcane_bolt()
		else:
			# Run towards player so the apprentice can summon the bolt
			velocity_component.accelerate_to_player()	
			velocity_component.move(self)
			animation_player.play("walk")
	set_face_direction()	

func set_face_direction() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if(player == null):
		return
		
	var direction_to_player = player.global_position.x - global_position.x

	if direction_to_player != 0:
		visuals.scale.x = sign(direction_to_player)
		
func on_arcane_bolt_being_summoned() -> void:
	random_audio_player_component.play_random_audio("battlecry");
	AudioManager.create_2d_audio_at_location(global_position, SoundEffectSettings.SOUND_EFFECT_TYPE.ARCANE_BOLT_BEING_SUMMONED)

func on_health_owner_dying() -> void:
	# Get all missiles linked to the controller
	var arcane_missiles = get_tree().get_nodes_in_group("magic_projectile")
	arcane_missiles = arcane_missiles.filter(func(element): return element.owner2d == arcane_bolt_abillity_controller);
	# Kill any that are still alive
	for arcane_missile in arcane_missiles:
		arcane_missile.make_bolt_disappear()

func player_is_in_range(player:CharacterBody2D, range:float) -> bool:
	return player.global_position.distance_squared_to(global_position) < pow(range,2)
		
func on_getting_damaged(was_damaged:bool) -> void:
	random_audio_player_component.play_random_audio("hit")
