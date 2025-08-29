extends Node
var monitor_fps: int=5
signal monitor_fps_changed(fps:int)

func _set_monitor_fps(fps:int):
	monitor_fps=fps
	monitor_fps_changed.emit(fps)
