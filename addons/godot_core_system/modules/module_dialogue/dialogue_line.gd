extends RefCounted
class_name DialogueLine


enum DialogueType {
	TEXT,
	CALLABLE,
}

var dialogue_type: DialogueType
var dialogue_text: String
var dialogue_callable: Callable
