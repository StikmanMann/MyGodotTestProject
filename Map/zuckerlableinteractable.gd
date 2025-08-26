extends Label3D


func _interacted():
	self.text = "OMG ICH WURDE INTERAGIERT"

func _ready():
	var parent = self.get_parent()
	if parent is Interactable:
		parent.player_interact.connect(_interacted)
		
