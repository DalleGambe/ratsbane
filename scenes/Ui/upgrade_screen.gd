extends CanvasLayer

signal upgrade_selected(ability_upgrade: AbilityUpgrade)

@export var upgrade_card_scene:PackedScene

@onready var card_container:HBoxContainer = %CardContainer

@onready var heal_button: Button = %HealButton
@onready var do_nothing_button: Button = %DoNothingButton
@onready var normal_or_label: Label = %NormalOrLabel
@onready var rare_or_label: Label = %RareOrLabel
@onready var or_margin_container: MarginContainer = %OrMarginContainer
@onready var pick_random_card_button: Button = %PickRandomCardButton

#var pause_menu_scene = preload("res://scenes/Ui/PauseMenu.tscn")
#var blur_vignette_scene = preload("res://scenes/Ui/blur_vignette.tscn")
#var pausing_not_possible = false
var player:Player
var healing_cooldown:int = 0
var arena_stats_manager:ArenaStatsManager
var base_heal_amount:int = 1
var upgrades_on_screen:Array[AbilityUpgrade]

func _ready() -> void:
	#for child in card_container.get_children():
		#child.queue_free()
	if(arena_stats_manager != null):
		healing_cooldown = arena_stats_manager.healing_cooldown
	MusicPlayer.volume_db -= 5
	MenuManager._add_menu_to_list(self)
	heal_button.pressed.connect(on_heal_button_pressed)
	do_nothing_button.pressed.connect(on_do_nothing_button_pressed)
	pick_random_card_button.pressed.connect(on_pick_random_card_button_pressed)
	do_nothing_button.text = tr("DO_NOTHING_BUTTON") + " :)"
	player = get_tree().get_first_node_in_group("player")
		
	set_heal_button_availability()
	%AnimationPlayer.play("fade in")
	await %AnimationPlayer.animation_finished
	
func _set_ability_upgrades(upgrades:Array[AbilityUpgrade]) -> void:
	var enter_delay = 0
	if(upgrades.size() != 0):
		normal_or_label.visible = true
		or_margin_container.visible = true
		pick_random_card_button.visible = true
		upgrades_on_screen.clear()
		for ability_upgrade in upgrades:
			var card_instance = upgrade_card_scene.instantiate()
			upgrades_on_screen.append(ability_upgrade)
			card_container.add_child(card_instance)
			card_instance._set_ability_upgrade(ability_upgrade)
			card_instance.play_enter_animation(enter_delay)
			card_instance.upgrade_selected.connect(on_upgrade_selected.bind(ability_upgrade))
			enter_delay += 0.4
	# If there are no upgrade cards left	
	# Fix bug where card can be selected and in down time with animation healing can be spammed	
	else:
		normal_or_label.visible = false
		or_margin_container.visible = false
		pick_random_card_button.visible = false
		player = get_tree().get_first_node_in_group("player")
		if(player != null and player.health_component.is_at_max_health() == false):
			rare_or_label.visible = true
		else:
			rare_or_label.visible = false	
	set_pick_random_card_button_availability()

func set_pending_levels_up_label(amount:int) -> void:
	%PendingLevelUpsLabel.text = str(amount) + " PENDING_CHOICES_LABEL";

func set_heal_button_availability() -> void:
	player = get_tree().get_first_node_in_group("player")
	if(player != null && healing_cooldown == 0):
		# If the player is at max health, other call is not necessary, but in the future may be
		if(player.health_component.is_at_max_health() == true or ModifierManager.get_can_player_heal_this_run() == false):
			heal_button.visible = false
		else:	
		# Otherwise
			heal_button.visible = true
			heal_button.disabled = false
		heal_button.text = tr("HEAL_LABEL").format({"amount_of_hp": base_heal_amount})
	else:
		heal_button.visible = true
		heal_button.disabled = true
		#var end_part_of_string = " level ups"
		#if(healing_cooldown == 1):
			#end_part_of_string = " level up"
		heal_button.text = tr("HEAL_COOLDOWN_MESSAGE_LABEL").format({"healing_cooldown_left": healing_cooldown})
		# Making sure the healing_cooldown can't go below 0 after reducing it by one
		arena_stats_manager.set_healing_cooldown(max(healing_cooldown-1,0))

func set_pick_random_card_button_availability() -> void:
	# If there are no upgrades available, hide otherwise show
	if(card_container.get_children().size() <= 0):
		pick_random_card_button.visible = false
	else:
		pick_random_card_button.visible = true	
		
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("pause_game") and pausing_not_possible == false:
		#add_child(blur_vignette_scene.instantiate())
		#add_child(Fpause_menu_scene.instantiate())
		#get_tree().root.set_input_as_handled()
		#MusicPlayer.volume_db -= 5

func fade_out_all_cards() -> void:
	# Fade out the other cards code here
	get_tree().call_group("upgrade_card", "play_discard_animation")
	var card = get_tree().get_first_node_in_group("upgrade_card")
	if(card != null):
		await card.animation_player.animation_finished
	else:
		await get_tree().create_timer(0.50).timeout

func fade_out_upgrade_screen() -> void:
	%AnimationPlayer.play("fade out")
	await %AnimationPlayer.animation_finished
	MenuManager._remove_menu_from_list(self)
	MusicPlayer.volume_db += 5
	queue_free()	

func on_heal_button_pressed() -> void:
	heal_button.disabled = true
	arena_stats_manager.times_do_nothing_button_was_pressed_this_run_consecutively = 0
	# Disabling cooldown for now since it disturbs the gameplay.
	#arena_stats_manager.set_healing_cooldown(1)
	# If the player exists, heal them for 1 hp
	player.health_component.heal(base_heal_amount)
	arena_stats_manager.add_to_player_healing_count(base_heal_amount)
	fade_out_all_cards()
	fade_out_upgrade_screen()
	
func on_do_nothing_button_pressed() -> void:
	arena_stats_manager.increment_do_nothing_button_pressed_count_by(1)
	fade_out_all_cards()
	fade_out_upgrade_screen()

func _exit_tree():
	MenuManager._remove_menu_from_list(self)

func on_pick_random_card_button_pressed() -> void:
	# Get all upgrade cards from the container
	var upgrade_cards = card_container.get_children()
	
	# Extra check, just to be safe
	if upgrade_cards.size() > 0:
		# Pick a random card
		var random_index = randi() % upgrade_cards.size()
		#var ability_upgrade = upgrades_on_screen[random_index]
		
		# Let the player know what upgrade was picked by playing the click animation of the card
		upgrade_cards[random_index].select_card()
	
func on_upgrade_selected(ability_upgrade:AbilityUpgrade) -> void:
	#pausing_not_possible = true
	arena_stats_manager.times_do_nothing_button_was_pressed_this_run_consecutively = 0
	upgrade_selected.emit(ability_upgrade)
	fade_out_upgrade_screen()
	# Start invincible frames
	GameEvents.emit_invincible_frames_started()
