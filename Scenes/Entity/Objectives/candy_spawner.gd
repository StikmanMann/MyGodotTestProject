class_name CandySpawner
extends Node3D

@onready var spawn_location = $SpawnLocation
const CANDY_OBJECTIVE = preload("res://Scenes/Entity/Objectives/candy_objective.tscn")

signal candy_spawned

func _ready():
	_spawn_candy()
	pass

func _spawn_candy():
	candy_spawned.emit()
	var objective = CANDY_OBJECTIVE.instantiate()
	spawn_location.add_child(objective)
