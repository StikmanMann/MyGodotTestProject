extends Node3D

@onready var delivery_zone = $DeliveryZone

signal candy_delivered

func _ready():
	delivery_zone.body_entered.connect(_body_entered_candy_area)
	pass

func _body_entered_candy_area(body: Node3D):
	if body is not CandyObjective:
		return
	var candy : CandyObjective = body
	candy_delivered.emit()
	candy.queue_free()
	pass
