extends Resource
class_name MetaUpgrade

@export var id:String
@export var title:String
@export_multiline var description:String
@export var owned_quantity:int = 0
@export var active_quantity:int = 0
@export var max_quantity:int = 1
@export var experience_cost:int = 1
@export var is_currently_active:bool = owned_quantity > 0
@export var values:Dictionary

func get_translated_description() -> String:
	# If there are any values on the card
	if not (values.is_empty()):
		for value in values.keys():
			pass
		return tr(description).format(values)
	else:
		return 	description				

func update_value(key_of_value: String, new_value) -> void:
	# If there are any values on the card
	if not (values.is_empty()):
		# If a value can be found based on the provided key
		if(values.keys().find(key_of_value) != -1):
			# Update the value associated with that key
			values[key_of_value] = new_value
