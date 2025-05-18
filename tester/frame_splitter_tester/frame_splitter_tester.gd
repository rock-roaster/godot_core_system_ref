extends Control


@export_dir var manga_dir: String

var frame_array: Array[String]
var frame_splitter: FrameSplitter = FrameSplitter.new()

@onready var grid_container: GridContainer = $ScrollContainer/GridContainer


func _ready() -> void:
	frame_array = System.resource_manager.get_file_list(manga_dir)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"): _on_accept_pressed()
	if event.is_action_pressed(&"ui_cancel"): _on_cancel_pressed()


func _on_accept_pressed() -> void:
	frame_splitter.process_array(frame_array, add_texture)


func _on_cancel_pressed() -> void:
	frame_splitter.process_array(frame_array, preload_resource)


func preload_resource(path: String) -> void:
	System.resource_manager.preload_resource(path)


func add_texture(path: String) -> void:
	var texture: Texture2D = System.resource_manager.load_resource(path)
	add_texture_rect(texture)


func add_texture_rect(texture: Texture2D) -> void:
	var new_texture_rect: TextureRect = TextureRect.new()
	new_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	new_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	new_texture_rect.custom_minimum_size = Vector2(300, 300)
	new_texture_rect.texture = texture
	grid_container.add_child(new_texture_rect)
