extends "res://scripts/brewing/station_base.gd"
## 매싱탱크: 보리 + 물 → 맥아즙 (1 phase)


func _ready() -> void:
	station_name = "매싱탱크"
	super._ready()


func _try_start_production() -> void:
	if not Inventory.has_item("barley", 1) or not Inventory.has_item("water", 1):
		return
	Inventory.remove_item("barley", 1)
	Inventory.remove_item("water", 1)
	start_processing(1)


func _show_progress() -> void:
	pass  # 1페이즈라 거의 안 보임


func _collect_output() -> void:
	Inventory.add_item("wort", 1)
	state = StationState.IDLE
	_update_visuals()


func _on_production_complete() -> void:
	SignalBus.production_completed.emit(station_name, "wort")
	_update_visuals()
