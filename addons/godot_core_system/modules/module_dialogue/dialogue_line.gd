extends RefCounted
class_name DialogueLine


enum DialogueType {
	TEXT,
	CALLABLE,
	TIMER,
}

var dialogue_type: DialogueType
var dialogue_data: Dictionary[StringName, Variant]


func _init() -> void:
	dialogue_data = {
		"text": "",
		"callable": Callable(),
		"await": false,
		"auto_advance": false,
		"wait_time": 0.0,
	}


func get_text() -> String:
	return dialogue_data.get("text", "")
