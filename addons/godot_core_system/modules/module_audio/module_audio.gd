extends "../module_base.gd"


const AUDIO_BUSES: Array[StringName] = [&"Music", &"Sound", &"Voice"]

## 通道映射
var _bus_index: Dictionary[StringName, int]
## 音量设置
var _bus_volume: Dictionary[StringName, float]

## 音频资源缓存
var _preloaded_audio: Array[String] = []
## 音频播放器池
var _audio_players: Dictionary[StringName, Array] = {}

## 音频节点根节点
var _audio_node_root: Node = null
## 当前的音乐播放器
var _current_music: AudioStreamPlayer = null


func _init() -> void:
	# 设置默认值
	_setup_audio_buses()


func _exit() -> void:
	if _audio_node_root != null:
		_current_root.remove_child(_audio_node_root)
		_audio_node_root.queue_free()


## 设置音频扬声器
func _setup_audio_buses():
	_bus_index[&"Master"] = 0
	_bus_volume[&"Master"] = 1.0
	_audio_players[&"Master"] = []
	for bus_name in AUDIO_BUSES: add_bus(bus_name)


func add_bus(bus_name: String, bus_volume: float = 1.0) -> void:
	if AudioServer.get_bus_index(bus_name) != -1: return
	var bus_index: int = AudioServer.get_bus_count()
	bus_volume = clampf(bus_volume, 0.0, 1.0)
	AudioServer.add_bus()
	AudioServer.set_bus_name(bus_index, bus_name)
	AudioServer.set_bus_volume_linear(bus_index, bus_volume)
	_bus_index[bus_name] = bus_index
	_bus_volume[bus_name] = bus_volume
	_audio_players[bus_name] = []


## 设置音量
## [param type] 音频类型
## [param volume] 音量
func set_volume(bus_name: String, bus_volume: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index == -1: return
	bus_volume = clampf(bus_volume, 0.0, 1.0)
	AudioServer.set_bus_volume_linear(bus_index, bus_volume)
	_bus_volume[bus_name] = bus_volume


## 预加载音频资源
## [param path] 音频路径
## [param type] 音频类型
func preload_audio(path: String) -> void:
	_preloaded_audio.append(path)
	_system.resource_manager.preload_resource(path)


func unload_audio(path: String) -> void:
	if !_preloaded_audio.has(path): return
	var ready_to_unload: Array[String] = []
	if path.is_empty():
		ready_to_unload = _preloaded_audio
	else:
		ready_to_unload = [path]

	for audio_path in ready_to_unload:
		_preloaded_audio.erase(audio_path)
		_system.resource_manager.unload_resource(audio_path)


## 获取音频资源
## [param path] 音频路径
## [return] 音频资源
func _get_audio_resource(path: String) -> AudioStream:
	return _system.resource_manager.get_resource(path)


func play_audio(
	path: String,
	bus_name: StringName,
	volume: float = 1.0,
	) -> AudioStreamPlayer:

	var audio_player: AudioStreamPlayer = null
	var audio_resource: AudioStream = _get_audio_resource(path)
	if audio_resource:
		audio_player = _get_audio_player(bus_name)
		audio_player.stream = audio_resource
		audio_player.volume_linear = volume
		audio_player.play()
	return audio_player


## 获取音频播放器
## [param type] 音频类型
## [return] 音频播放器
func _get_audio_player(bus_name: StringName) -> AudioStreamPlayer:
	# 查找空闲的播放器
	for player in _audio_players[bus_name]:
		if not player.playing:
			return player

	if _audio_node_root == null:
		_audio_node_root = Node.new()
		_audio_node_root.set_name("AudioNodeRoot")
		_system.add_child(_audio_node_root)

	# 创建新的播放器
	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	new_player.bus = bus_name
	new_player.volume_linear = 1.0
	_audio_node_root.add_child(new_player)
	_audio_players[bus_name].append(new_player)
	return new_player


## 播放音效
## [param path] 音频路径
## [param volume] 音量
## [return] 音频播放器
func play_sound(path: String, volume: float = 1.0) -> AudioStreamPlayer:
	return play_audio(path, &"Sound", volume)


## 播放语音
## [param path] 音频路径
## [param volume] 音量
## [return] 音频播放器
func play_voice(path: String, volume: float = 1.0) -> AudioStreamPlayer:
	return play_audio(path, &"Voice", volume)


## 播放音乐
## [param path] 音频路径
## [param fade_duration] 淡出持续时间
## [param loop] 是否循环
func play_music(path: String, fade_duration: float = 1.0) -> void:
	if _current_music and _current_music.playing:
		_fade_out_music(fade_duration)

	_current_music = play_audio(path, &"Music")

	if fade_duration > 0:
		_fade_in_music(fade_duration)


## 淡出音乐
## [param duration] 淡出持续时间
func _fade_out_music(duration: float) -> void:
	if _current_music:
		var tween: Tween = _audio_node_root.create_tween()
		tween.tween_property(_current_music, ^"volume_linear", 0.0, duration)
		tween.tween_callback(_current_music.stop)


## 淡入音乐
## [param duration] 淡入持续时间
func _fade_in_music(duration: float) -> void:
	if _current_music:
		_current_music.volume_linear = 0.0
		var tween: Tween = _audio_node_root.create_tween()
		tween.tween_property(_current_music, ^"volume_linear", 1.0, duration)


## 停止所有音频
func stop_all() -> void:
	if _current_music:
		_current_music.stop()

	for bus in _audio_players:
		for player in _audio_players[bus]:
			player.stop()
