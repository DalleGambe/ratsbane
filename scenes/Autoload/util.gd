extends Node

func convert_to_time(time_in_seconds:int) -> String:
	var minutes = floor(time_in_seconds/60)
	var remaining_seconds = floor(time_in_seconds - (minutes * 60))
	return str(minutes) + ":" + ("%02d" % remaining_seconds)
	
func convert_to_time_hour(time_in_seconds: int) -> String:
	var hours:int = floor(time_in_seconds / 3600)
	var minutes:int = floor((time_in_seconds % 3600) / 60)
	var remaining_seconds:int = floor(time_in_seconds % 60)
	return str("%02d" % hours) + ":" + ("%02d" % minutes) + ":" + ("%02d" % remaining_seconds)

func format_float_to_string(value: float) -> String:
	if value == int(value):
		return "%d" % value
	else:
		return str(value)
	
func find_smallest_divisor(number:int) -> int: 
	while (number % 2 != 0):
		number -= number
	return number

func get_formatted_date() -> String:
	var current_date_time = Time.get_datetime_dict_from_system()

	return "%02d-%02d-%04d" % [
		current_date_time["day"],
		current_date_time["month"],
		current_date_time["year"]
	]
