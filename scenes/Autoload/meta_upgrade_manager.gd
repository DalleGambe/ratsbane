extends Node

@export var meta_upgrades: Array[MetaUpgrade]

func _ready() -> void:
	pass

func get_all_meta_upgrade_max_quantity() -> int:
	var total_quantity_count = 0
	for meta_upgrade in meta_upgrades: 
		total_quantity_count += meta_upgrade.max_quantity
	return total_quantity_count	
