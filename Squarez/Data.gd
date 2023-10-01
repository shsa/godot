extends Node

class_name Data

var data: Array

func _ready():
	data = load_json_file("res://assets/data/figures.json")

func get_collection(name: String) -> Dictionary:
	return {} 

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
