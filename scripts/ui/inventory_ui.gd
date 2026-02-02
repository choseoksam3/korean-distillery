extends CanvasLayer
## 인벤토리 UI. Tab키로 토글.

@onready var panel: Panel = $Panel
@onready var item_list: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ItemList
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel

var is_open: bool = false


func _ready() -> void:
	panel.visible = false
	SignalBus.inventory_changed.connect(_refresh)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	is_open = !is_open
	panel.visible = is_open
	if is_open:
		_refresh()


func _refresh() -> void:
	if not is_open:
		return
	# 기존 아이템 라벨 제거
	for child in item_list.get_children():
		child.queue_free()

	# 재료 아이템
	if Inventory.items.size() > 0:
		for item_id in Inventory.items:
			var qty: int = Inventory.items[item_id]
			if qty <= 0:
				continue
			var label := Label.new()
			label.text = "%s x%d" % [Inventory.get_item_name(item_id), qty]
			label.add_theme_color_override("font_color", Inventory.get_item_color(item_id))
			item_list.add_child(label)

	# 배럴 상태
	if Inventory.barrels.size() > 0:
		var sep := Label.new()
		sep.text = "--- 배럴 ---"
		sep.add_theme_color_override("font_color", Color(0.6, 0.5, 0.3))
		item_list.add_child(sep)
		for i in Inventory.barrels.size():
			var barrel = Inventory.barrels[i]
			var label := Label.new()
			if barrel.is_filled:
				label.text = "%s: %d개월 숙성" % [barrel.get_type_name(), barrel.age_months]
				label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.3))
			else:
				label.text = "%s: 비어있음" % barrel.get_type_name()
				label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			item_list.add_child(label)

	# 완성 위스키
	if Inventory.whisky_inventory.size() > 0:
		var sep2 := Label.new()
		sep2.text = "--- 위스키 ---"
		sep2.add_theme_color_override("font_color", Color(0.8, 0.65, 0.3))
		item_list.add_child(sep2)
		for whisky in Inventory.whisky_inventory:
			var label := Label.new()
			label.text = "%s (품질:%.0f%% 가격:%d)" % [
				whisky.get_display_name(),
				whisky.quality * 100,
				whisky.calculate_price()
			]
			label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
			item_list.add_child(label)

	# 비어있는 경우
	if item_list.get_child_count() == 0:
		var label := Label.new()
		label.text = "(비어있음)"
		label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		item_list.add_child(label)
