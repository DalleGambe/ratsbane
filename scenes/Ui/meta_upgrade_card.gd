extends PanelContainer

@onready var name_label:Label = %NameLabel
@onready var description_label:Label = %"Description Label"
@onready var purchase_button: Button = %PurchaseButton
@onready var progress_label: Label = %ProgressLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var quantity_label: Label = %QuantityLabel
@onready var audio_player: RandomSteamPlayerComponent = $AudioPlayerComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var meta_upgrade: MetaUpgrade

var card_is_disabled = false
var is_card_loading = false

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	purchase_button.pressed.connect(on_purchase_button_pressed)
	
func _set_meta_upgrade(upgrade: MetaUpgrade) -> void:
	meta_upgrade = upgrade
	name_label.text = upgrade.title
	description_label.text = upgrade.get_translated_description()
	update_progress()

func play_enter_animation(delay:float = 0) -> void:
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(delay).timeout
	animation_player.play("enter_screen")
	
func update_progress() -> void:
	var current_quantity = 0
	if MetaProgression.save_data["meta_upgrades"].has(meta_upgrade.id):
		current_quantity = MetaProgression.save_data["meta_upgrades"][meta_upgrade.id]["owned_quantity"]
	var is_sold_out = MetaProgression.is_meta_upgade_sold_out(meta_upgrade)
	var meta_currency = MetaProgression.save_data["meta_upgrade_currency"]
	var progress_percentage:float = min(float(meta_currency) / float(meta_upgrade.experience_cost), 1)
	progress_bar.value = progress_percentage
	purchase_button.disabled = progress_percentage < 1 or is_sold_out == true
	if is_sold_out == true:
		purchase_button.text = "SOLD_OUT_BUTTON"
	progress_label.text = str(meta_currency) + "/" + str(meta_upgrade.experience_cost)
	quantity_label.text = "x%d" % current_quantity

func set_is_being_loading(is_loading:bool) -> void:
		is_card_loading = is_loading

func _on_gui_input(event: InputEvent) -> void:
	if(event.is_action_pressed("left_click") and is_card_loading != true):
		animation_player.play("on_click")

func on_purchase_button_pressed() -> void:
	is_card_loading = true
	if(meta_upgrade == null):
		return
	MetaProgression.add_meta_upgrade(meta_upgrade)
	MetaProgression.handle_payment(meta_upgrade)
	# Get Meta upgrade achievements
	var shop_achievement_ids = MetaProgression.get_achievements_from_category(Achievement.achievement_category.SHOP)
	# for loop
	#print("Size of achievement list: " + str(shop_achievement_ids.size()))
	for shop_achievement_id in shop_achievement_ids:
		#print("Shop Achievement: " + str(shop_achievement_id))
		# Check if completed, if it isn't
		MetaProgression.check_and_update_progress_of(shop_achievement_id, Achievement.achievement_category.SHOP)
		## Recheck if the achievement is now complete
		#if(MetaProgression.is_achievement_completed(shop_achievement_id) == true):
			## if completed handle it 
			#MetaProgression.handle_achievement_completion(shop_achievement_id)
			## send notification
			#var achievement = AchievementManager.get_achievement(shop_achievement_id)
			#NotificationOverlay.add_unlocked_achievement_to_queue(achievement)
			#NotificationOverlay.handle_achievement_unlock()
	MetaProgression.save()
	get_tree().call_group("meta_upgrade_card", "update_progress")
	animation_player.play("purchase")
	await animation_player.animation_finished
	is_card_loading = false
	
