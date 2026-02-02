extends "res://scripts/brewing/station_base.gd"
## 증류기: 발효액 → 미니게임 → 증류원액

var minigame_scene: PackedScene = preload("res://scenes/minigames/distilling.tscn")
var minigame_instance: Node = null
var waiting_for_minigame: bool = false


func _ready() -> void:
	station_name = "증류기"
	super._ready()
	SignalBus.minigame_completed.connect(_on_minigame_completed)


func interact() -> void:
	if waiting_for_minigame:
		return
	match state:
		StationState.IDLE:
			_try_start_production()
		StationState.COMPLETE:
			_collect_output()


func _try_start_production() -> void:
	if not Inventory.has_item("wash", 1):
		return
	Inventory.remove_item("wash", 1)
	# 미니게임 시작
	waiting_for_minigame = true
	state = StationState.PROCESSING
	_update_visuals()
	_start_minigame()


func _start_minigame() -> void:
	var main_node := get_tree().root.get_node("Main")
	if not main_node:
		return
	minigame_instance = minigame_scene.instantiate()
	main_node.add_child(minigame_instance)
	minigame_instance.start_minigame()


func _on_minigame_completed(minigame_type: String, _result: Dictionary) -> void:
	if minigame_type != "distilling" or not waiting_for_minigame:
		return
	waiting_for_minigame = false
	# 미니게임 인스턴스 제거
	if minigame_instance and is_instance_valid(minigame_instance):
		minigame_instance.queue_free()
		minigame_instance = null
	state = StationState.COMPLETE
	_on_production_complete()


func _collect_output() -> void:
	Inventory.add_item("new_make_spirit", 1)
	state = StationState.IDLE
	_update_visuals()


func _on_production_complete() -> void:
	SignalBus.production_completed.emit(station_name, "new_make_spirit")
	_update_visuals()
