extends "res://scripts/brewing/station_base.gd"
## 병입대: 숙성 완료 배럴 → 위스키 생성 → 인벤토리에 추가 (즉시)

const WhiskyDataScript = preload("res://scripts/resources/whisky_data.gd")


func _ready() -> void:
	station_name = "병입대"
	super._ready()
	SignalBus.bottling_ui_requested.connect(_on_bottling_requested)


func interact() -> void:
	var mature_indices := Inventory.get_mature_barrel_indices()
	if mature_indices.size() == 0:
		return
	# 첫 번째 숙성 완료 배럴 병입
	_bottle_barrel(mature_indices[0])


func _bottle_barrel(barrel_index: int) -> void:
	var barrel = Inventory.barrels[barrel_index]
	if not barrel.is_filled or not barrel.is_mature():
		return

	# WhiskyData 생성
	var whisky = WhiskyDataScript.new()
	whisky.id = "whisky_%d" % Time.get_ticks_msec()
	whisky.type = "product"
	whisky.age_months = barrel.age_months
	whisky.quality = barrel.distill_quality
	whisky.barrel_type = barrel.get_type_name()
	whisky.yeast_type = barrel.yeast_type
	whisky.flavor_profile = barrel.get_flavor_with_barrel()
	whisky.distill_quality = barrel.distill_quality
	whisky.name = whisky.get_display_name()
	whisky.base_price = whisky.calculate_price()
	whisky.icon_color = Color(0.9, 0.7, 0.2)
	whisky.stackable = false

	# 배럴 비우기
	barrel.is_filled = false
	barrel.age_months = 0
	barrel.flavor_profile = {}
	barrel.distill_quality = 0.5
	barrel.yeast_type = ""
	SignalBus.barrel_emptied.emit(barrel_index)

	# 위스키 인벤토리에 추가
	Inventory.add_whisky(whisky)
	SignalBus.inventory_changed.emit()


func _on_bottling_requested() -> void:
	interact()


# 병입은 즉시 완료이므로 phase 처리 불필요
func _on_phase_changed(_phase: String) -> void:
	pass
