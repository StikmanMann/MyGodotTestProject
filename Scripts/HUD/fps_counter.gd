extends Control

@onready var label = $Label

func _process(delta):
	label.text = "FPS: %d" % Performance.get_monitor(Performance.TIME_FPS)
