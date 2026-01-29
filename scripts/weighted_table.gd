class_name WeightedTable

var items:Array[Dictionary] = []
var weight_sum = 0
	
func add_item(item, weight:int) -> void:
	items.append({"item": item, "weight": weight})
	weight_sum += weight

func remove_item(item_to_remove) -> void:
	items = items.filter(func (item): return item["item"] != item_to_remove) 
	weight_sum = 0
	for item in items:
		weight_sum += item["weight"]
	#if(item_to_remove != null):
		#print("PASSED FIRST")
		#var item_index = items.find(func (item): return item["item"] == item_to_remove)
		#if(item_index >= 0):
			#print("PASSED SECOND")
			#weight_sum -= items[item_index]["weight"]
			#items.remove_at(items.find(item_to_remove))


func pick_item(items_to_exclude_from_pool:Array = []) -> Variant:
	var adjusted_items = []  # Reset at the beginning
	var adjusted_weight_sum = 0
	
	# Exclude items if needed
	for item in items:
		if item["item"] in items_to_exclude_from_pool:
			continue # skip excluded items
		adjusted_items.append(item)
		adjusted_weight_sum += item["weight"]
		#print("Added item:", item["item"], "Weight:", item["weight"])

	#print("Adjusted items size:", adjusted_items.size())
	#print("Adjusted weight sum:", adjusted_weight_sum)

	# If no items are left after exclusion, return null
	if adjusted_items.size() == 0 or adjusted_weight_sum == 0:
		#print("No valid items to pick.")
		return null

	# Pick a random weight threshold based on the total adjusted weight
	var chosen_weight = randf_range(0, adjusted_weight_sum)
	var iteration_sum = 0

	# Iterate over the adjusted items and pick based on weight
	for item in adjusted_items:
		iteration_sum += item["weight"]
		if chosen_weight <= iteration_sum:
			#print("Item picked:", item["item"])
			return item["item"]

	# Fallback in case no item was picked (which shouldn't happen)
	#print("Error: No item was picked.")
	return null
