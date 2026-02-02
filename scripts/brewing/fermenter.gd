extends "res://scripts/brewing/station_base.gd"
## 발효탱크: 맥아즙 + 효모 → 발효액 (1 phase)
## 효모 종류에 따라 풍미 프로필이 달라진다.

const YEAST_FLAVORS: Dictionary = {
	"yeast_ale": {"fruity": 20, "sweet": 15},
	"yeast_wine": {"floral": 20, "fruity": 15},
	"yeast_wild": {"spicy": 15, "fruity": 10, "floral": 5},
}

var selected_yeast: String = ""


func _ready() -> void:
	station_name = "발효탱크"
	super._ready()


func _try_start_production() -> void:
	if not Inventory.has_item("wort", 1):
		return
	# 가진 효모 중 첫 번째 사용
	var available_yeast := _find_available_yeast()
	if available_yeast == "":
		return
	selected_yeast = available_yeast
	Inventory.remove_item("wort", 1)
	Inventory.remove_item(selected_yeast, 1)
	start_processing(1)


func _find_available_yeast() -> String:
	for yeast_id in YEAST_FLAVORS:
		if Inventory.has_item(yeast_id, 1):
			return yeast_id
	return ""


func _collect_output() -> void:
	Inventory.add_item("wash", 1)
	# 풍미 프로필을 GameManager에 임시 저장 (다음 단계 증류기에서 사용)
	GameManager.temp_flavor_profile = YEAST_FLAVORS.get(selected_yeast, {}).duplicate()
	GameManager.temp_yeast_type = selected_yeast
	selected_yeast = ""
	state = StationState.IDLE
	_update_visuals()


func _on_production_complete() -> void:
	SignalBus.production_completed.emit(station_name, "wash")
	_update_visuals()
