extends Area2D

func _ready() -> void:
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)

func on_area_entered(area:Area2D):
	if(area.owner == null || area.owner.is_in_group("player")):
		return;
		
	if(area.owner.is_in_group("enemy")):
		area.owner.set_missbox_status(IsInMissBox.IsInMissBoxStatus.INSIDE)
	
func on_area_exited(area:Area2D):
	if(area.owner == null || area.owner.is_in_group("player")):
		return;
		
	if(area.owner.is_in_group("enemy") && area.owner.is_in_miss_box == IsInMissBox.IsInMissBoxStatus.INSIDE):
		GameEvents.emit_near_miss_happened(1000, area.global_position)
	area.owner.set_missbox_status(IsInMissBox.IsInMissBoxStatus.OUTSIDE)
