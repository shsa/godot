extends Node3D

@export var block: PackedScene
@export var data: Data

signal spawn_preview

func _ready():
	var a = Test_class.new()
	a.test()
	print(data.data)
	
#	for x in range(10):
#		for y in range(10):
#			var item = block.instantiate() as Node3D
#			item.position.x = x
#			item.position.z = y
#			item.color = Color(0, 0, 1)
#			$Pivot.add_child(item)

	for x in range(3):
		for y in range(3):
			var item = block.instantiate() as Node3D
			item.position.x = x
			item.position.z = y
			item.color = Color(0, 0, 1)
			$Active.add_child(item)
	
	spawn_preview.emit()

func _input(event):
	print(event)
