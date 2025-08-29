extends HSlider

func _slider_changed(fps: float):
	var fps_int: int = int(fps)
	MonitorSettings._set_monitor_fps(fps_int)
	
func _ready() -> void:
	value_changed.connect(_slider_changed)
