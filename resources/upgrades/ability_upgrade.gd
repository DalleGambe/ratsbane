extends Resource
class_name AbilityUpgrade

enum FLAVOUR_CLASS{
	DEFAULT,
	KNIGHT,
	LUMBERJACK,		
	BOMBER
}

@export var id: String
@export var name: String
@export_multiline var description: String
# The amount of times a non-unique ability can be picked
@export var amount_that_can_be_picked: int
@export var values:Dictionary
@export var flavour_class : FLAVOUR_CLASS

func get_translated_description() -> String:
	# If there are any values on the card
	if not (values.is_empty()):
		#print("TRANSLATING NOW!")
		for value in values.keys():
			#print(value)
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
