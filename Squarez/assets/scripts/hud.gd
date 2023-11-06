extends Control

@export var main: BoardMain

@onready var _scores := $Panel/Scores

func _ready():
	main.logic.connect("updated", _updated)
	pass

func _updated():
	_scores.text = str(main.logic.scores)
	pass
