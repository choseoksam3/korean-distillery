extends Node
## 인벤토리 시스템. 아이템, 배럴, 완성 위스키를 관리.

const BarrelDataScript = preload("res://scripts/resources/barrel_data.gd")

# 아이템 정의 데이터 (items.json에서 로드)
var item_definitions: Dictionary = {}

# 보유 아이템: {"item_id": quantity}
var items: Dictionary = {}

# 배럴 목록
var barrels: Array = []

# 완성 위스키 목록
var whisky_inventory: Array = []


func _ready() -> void:
	_load_item_definitions()
	_give_starting_items()


func _load_item_definitions() -> void:
	var file := FileAccess.open("res://data/items.json", FileAccess.READ)
	if not file:
		push_error("items.json 로드 실패")
		return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err != OK:
		push_error("items.json 파싱 실패: " + json.get_error_message())
		return
	item_definitions = json.data


func _give_starting_items() -> void:
	add_item("barley", 10)
	add_item("water", 10)
	add_item("yeast_ale", 5)
	# 시작 배럴 2개
	var barrel1 = BarrelDataScript.new()
	barrel1.barrel_type = 0  # AMERICAN_OAK
	barrels.append(barrel1)
	var barrel2 = BarrelDataScript.new()
	barrel2.barrel_type = 1  # EUROPEAN_OAK
	barrels.append(barrel2)


func add_item(item_id: String, quantity: int = 1) -> void:
	items[item_id] = items.get(item_id, 0) + quantity
	SignalBus.item_added.emit(item_id, quantity)
	SignalBus.inventory_changed.emit()


func remove_item(item_id: String, quantity: int = 1) -> bool:
	if not has_item(item_id, quantity):
		return false
	items[item_id] -= quantity
	if items[item_id] <= 0:
		items.erase(item_id)
	SignalBus.item_removed.emit(item_id, quantity)
	SignalBus.inventory_changed.emit()
	return true


func has_item(item_id: String, quantity: int = 1) -> bool:
	return items.get(item_id, 0) >= quantity


func get_item_count(item_id: String) -> int:
	return items.get(item_id, 0)


func get_item_name(item_id: String) -> String:
	if item_id in item_definitions:
		return item_definitions[item_id]["name"]
	return item_id


func get_item_color(item_id: String) -> Color:
	if item_id in item_definitions:
		var c: Array = item_definitions[item_id]["icon_color"]
		return Color(c[0], c[1], c[2])
	return Color.WHITE


func get_empty_barrel_indices() -> Array:
	var result: Array = []
	for i in barrels.size():
		if not barrels[i].is_filled:
			result.append(i)
	return result


func get_mature_barrel_indices() -> Array:
	var result: Array = []
	for i in barrels.size():
		if barrels[i].is_filled and barrels[i].is_mature():
			result.append(i)
	return result


func get_filled_barrel_indices() -> Array:
	var result: Array = []
	for i in barrels.size():
		if barrels[i].is_filled:
			result.append(i)
	return result


func add_whisky(whisky: Resource) -> void:
	whisky_inventory.append(whisky)
	SignalBus.whisky_completed.emit(whisky)
	SignalBus.inventory_changed.emit()


func remove_whisky(index: int) -> bool:
	if index < 0 or index >= whisky_inventory.size():
		return false
	whisky_inventory.remove_at(index)
	SignalBus.inventory_changed.emit()
	return true
