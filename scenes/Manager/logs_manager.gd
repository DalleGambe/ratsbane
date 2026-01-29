extends Node

const log_file_path := "user://shutdown_log.txt"

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST || what == NOTIFICATION_CRASH:
		write_shutdown_log(what)

func write_shutdown_log(what):
	var f = FileAccess.open(log_file_path, FileAccess.READ_WRITE)
	if f:
		f.seek_end()
		f.store_line("=== GAME SHUTDOWN ===")
		f.store_line("Reason: " + str(what))
		f.store_line("Time: " + Time.get_datetime_string_from_system())
		f.store_line("Current Scene: " + str(get_tree().current_scene))
		f.store_line("FPS: " + str(Engine.get_frames_per_second()))
		f.store_line("Memory: " + str(OS.get_static_memory_usage()))
		f.store_line("------------------------------")
		f.close()
		
func _on_engine_error(message, function, file, line, error_type):
	_write_error("ERROR", message, function, file, line, error_type)
func _write_error(kind, message, function, file, line, error_type):
	var f = FileAccess.open(log_file_path, FileAccess.READ_WRITE)
	if f:
		f.seek_end()
		f.store_line("=== " + kind + " ===")
		f.store_line("Time: " + Time.get_datetime_string_from_system())
		f.store_line("Message: " + message)
		f.store_line("Function: " + function)
		f.store_line("File: " + file)
		f.store_line("Line: " + str(line))
		f.store_line("Type: " + str(error_type))
		f.store_line("------------------------------")
		f.close()
