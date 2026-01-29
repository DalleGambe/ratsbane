extends Node2D
class_name BloodSplatterComponent

@export var health_component: HealthComponent
var damage_taken: float

@onready var base_amount_of_blood = %GPUParticles2D.amount

func _ready() -> void:
	if(health_component != null):
		health_component.health_amount_changed.connect(on_health_changed)

func on_health_changed(was_damaged:bool) -> void:
	#var sfx_contains_name = "blood_splatter_regular"
	var amount_of_blood = base_amount_of_blood + damage_taken * 0.2
	#if(amount_of_blood >= 64):
		#sfx_contains_name = "blood_splatter_heavy"
			
	%GPUParticles2D.amount = amount_of_blood
	%GPUParticles2D.emitting = true
	%RandomSfxPlayerComponent.play_random_audio()
	
