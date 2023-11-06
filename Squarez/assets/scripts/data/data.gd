extends Node

class_name Data

var _data: Dictionary

func _ready():
	var _list = load_json_file("res://assets/data/shapes.json")
	for item in _list:
		var collection = Collection.new(item)
		_data[collection.name] = collection

func get_collection(_name: String) -> Collection:
	return _data[_name]

func load_json_file(filePath: String) -> Array:
	if FileAccess.file_exists(filePath):
		var data = FileAccess.open(filePath, FileAccess.READ)
		var result = JSON.parse_string(data.get_as_text())
		
		if result is Array:
			return result
		else:
			print("Error reading file")
			
	else:
		print("File doesn't exists!")
	return []
