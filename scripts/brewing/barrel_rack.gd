extends "res://scripts/brewing/station_base.gd"
## 숙성대: 배럴에 증류원액을 채우고 숙성. day_changed마다 age_months += 1


func _ready() -> void:
	station_name = "숙성대"
	super._ready()
	SignalBus.day_changed.connect(_on_day_changed)


func interact() -> void:
	# 배럴 UI 요청
	SignalBus.barrel_ui_requested.emit()


func _on_day_changed(_day: int) -> void:
	# 하루 = 1개월 숙성
	for i in Inventory.barrels.size():
		var barrel = Inventory.barrels[i]
		if barrel.is_filled:
			barrel.age_months += 1
			SignalBus.barrel_aged.emit(i, barrel.age_months)
	_update_status()


func _update_status() -> void:
	var has_filled := false
	for barrel in Inventory.barrels:
		if barrel.is_filled:
			has_filled = true
			break
	if has_filled:
		state = StationState.PROCESSING
	else:
		state = StationState.IDLE
	_update_visuals()


func fill_barrel(barrel_index: int) -> bool:
	if barrel_index < 0 or barrel_index >= Inventory.barrels.size():
		return false
	var barrel = Inventory.barrels[barrel_index]
	if barrel.is_filled:
		return false
	if not Inventory.has_item("new_make_spirit", 1):
		return false
	Inventory.remove_item("new_make_spirit", 1)
	barrel.is_filled = true
	barrel.age_months = 0
	barrel.flavor_profile = GameManager.temp_flavor_profile.duplicate()
	barrel.distill_quality = GameManager.temp_distill_quality
	barrel.yeast_type = GameManager.temp_yeast_type
	SignalBus.barrel_filled.emit(barrel_index)
	SignalBus.inventory_changed.emit()
	_update_status()
	return true


# StationBase의 phase 처리는 사용하지 않음 (day_changed 사용)
func _on_phase_changed(_phase: String) -> void:
	pass
