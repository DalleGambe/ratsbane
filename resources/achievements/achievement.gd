extends Resource
class_name Achievement

@export var id:String
@export var title:String
@export var current_progress:int = 0
@export var target_goal:int = 1
@export_multiline var description:String
@export var image:Texture2D
@export var started_at:String = "N/A"
@export var completed_on:String = "N/A"
@export var category:achievement_category
@export var target_goal_is_dynamic:bool = false
enum achievement_category {NONE, SHOP, WEAPON, END_GAME}
