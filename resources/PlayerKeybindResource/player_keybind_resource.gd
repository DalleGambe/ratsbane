extends Resource
class_name PlayerKeybindResource

const MOVE_LEFT : String = "move_left"
const MOVE_RIGHT : String = "move_right"
const MOVE_UP : String = "move_up"
const MOVE_DOWN : String = "move_down"
const PAUSE_GAME : String = "pause_game"

@export var DEFAULT_MOVE_LEFT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_RIGHT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_UP_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_DOWN_KEY = InputEventKey.new()
@export var DEFAULT_PAUSE_GAME_KEY = InputEventKey.new()

var move_left_key = InputEventKey.new()
var move_right_key = InputEventKey.new()
var move_up_key = InputEventKey.new()
var move_down_key = InputEventKey.new()
var pause_game_key = InputEventKey.new()
