extends CanvasLayer

@onready var time_left = %TimeLeft
@onready var one_minute_left_label: Label = %AnnouncementLabel
@onready var player_health_bar: ProgressBar = %PlayerHealthBar
@onready var player_health_display: Label = %PlayerHealthDisplay
@onready var ability_power_bar: ProgressBar = %AbilityPowerBar
@onready var boss_health_bar: ProgressBar = %BossHealthBar
@onready var boss_health_display: Label = %BossHealthDisplay

@export var arena_time_manager:Node
@export var player:CharacterBody2D
@export var camera_2d:Camera2D
@onready var ability_visual_cooldown_timer: Timer = %AbilityVisualCooldownTimer
@onready var ability_visual_duration_timer: Timer = %AbilityVisualDurationTimer

var colors: Array[Color] = [Color.RED, Color.GREEN]
var experience_multiplier:float = 20
var currentBoss:BasicBoss

func _ready() -> void:
	time_left.text = format_seconds(arena_time_manager._get_time_elapsed())	
	arena_time_manager.music_momentum_timer.timeout.connect(_on_music_momentum_timer_timout)
	GameEvents.player_dealt_damage.connect(on_player_dealing_damage)
	GameEvents.experience_vial_collected.connect(on_player_picking_up_experience)
	GameEvents.updated_player_health_to.connect(on_player_health_update)
	GameEvents.player_triggered_ability.connect(on_player_ability_triggered)
	GameEvents.update_boss_health_bar.connect(on_update_boss_health_bar)
	
func _process(delta: float) -> void:
	if(arena_time_manager == null):
		return
	time_left.text = format_seconds(arena_time_manager._get_time_elapsed())
	if not ability_visual_duration_timer.is_stopped():
		ability_power_bar.value = (ability_visual_duration_timer.time_left / ability_visual_duration_timer.wait_time)
	elif not ability_visual_cooldown_timer.is_stopped():
		ability_power_bar.value = (ability_visual_cooldown_timer.wait_time - ability_visual_cooldown_timer.time_left)/ability_visual_cooldown_timer.wait_time
	elif(ability_power_bar.value == ability_power_bar.max_value && not ability_power_bar.flicker):
		ability_power_bar.set_flickering_to(true)
		ability_power_bar.bounce()
		AudioManager.create_2d_audio_at_location(ability_power_bar.global_position, SoundEffectSettings.SOUND_EFFECT_TYPE.UI, "ability_ready")

func format_seconds(seconds:float) -> String:
	MetaProgression.player_lasted_time_in_seconds = seconds
	return Util.convert_to_time(seconds)

func on_player_dealing_damage(damage_dealt:float) -> void:
	MetaProgression.player_score += damage_dealt
	update_score(str(MetaProgression.player_score))

func update_score(added_score: String) -> void:
	var label := %DamageScore
	label.text = added_score
	label.pivot_offset = label.size * 0.5
	label.position = label.get_parent().size * 0.5 - label.size * 0.5

	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.25, 1.25), 0.1)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(label, "scale", Vector2(1, 1), 0.1)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_CUBIC)

	
func on_player_picking_up_experience(amount_of_experience:float) -> void:
	MetaProgression.player_score += (amount_of_experience * experience_multiplier )
	update_score(str(MetaProgression.player_score))
	
func on_player_health_update(new_player_health:float, max_player_health:float) -> void:
	player_health_bar.value = new_player_health
	var new_current_hp:float = max_player_health * new_player_health
	player_health_display.text = str(new_current_hp) + "/" + str(max_player_health)
	player_health_bar.set_flickering_to(new_current_hp == 1)

func on_player_ability_triggered(new_cooldown:float, ability_duration:float) -> void:
	ability_visual_duration_timer.wait_time = ability_duration
	ability_visual_duration_timer.start()
	ability_power_bar.set_flickering_to(false)
	await ability_visual_duration_timer.timeout
	ability_visual_cooldown_timer.wait_time = new_cooldown
	ability_visual_cooldown_timer.start()

func on_update_boss_health_bar(current_boss_health:float) -> void:
	boss_health_bar.value = current_boss_health
	boss_health_display.text = str(current_boss_health) + "/" + str(currentBoss.max_health)
	
func _on_music_momentum_timer_timout() -> void:
	var tween = create_tween()
	tween.parallel()
	tween.tween_property(one_minute_left_label, "modulate:a", 0.0, 0.5)
	tween.tween_property(one_minute_left_label, "modulate:a", 1, 0.5)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_QUINT)
	tween.chain()
	tween.tween_property(one_minute_left_label, "modulate:a", 0.0, 0.5)
	tween.tween_property(one_minute_left_label, "modulate:a", 1, 0.5)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_QUINT)
	tween.chain()
	tween.tween_property(one_minute_left_label, "modulate:a", 0.0, 0.5)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_CIRC)
