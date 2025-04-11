extends RefCounted
class_name DialogueLine


enum DialogueType {
	TEXT,
	CALLABLE,
}

var dialogue_type: DialogueType
var dialogue_data: Dictionary


func _init() -> void:
	dialogue_data = {
		"text": "",
		"callable": Callable(),
		"await": false,
		"auto_advance": false,
	}


func get_text() -> String:
	return dialogue_data.get("text", "")
