extends CanvasLayer
## 배럴 관리 UI: 빈 배럴에 증류원액 채우기, 숙성 상태 확인

@onready var panel: Panel = $Panel
@onready var barrel_list: VBoxContainer = $Panel/MarginContainer/VBoxContainer/BarrelList
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var close_btn: Button = $Panel/MarginContainer/VBoxContainer/CloseButton

var is_open: bool = false


func _ready() -> void:
	panel.visible = false
	SignalBus.barrel_ui_requested.connect(_on_open_requested)
	close_btn.pressed.connect(_close)


func _unhandled_input(event: InputEvent) -> void:
	if is_open and event.is_action_pressed("interact"):
		_close()
		get_viewport().set_input_as_handled()


func _on_open_requested() -> void:
	is_open = true
	panel.visible = true
	GameManager.is_paused = true
	_refresh()


func _close() -> void:
	is_open = false
	panel.visible = false
	GameManager.is_paused = false


func _refresh() -> void:
	for child in barrel_list.get_children():
		child.queue_free()

	if Inventory.barrels.size() == 0:
		var label := Label.new()
		label.text = "배럴이 없습니다"
		barrel_list.add_child(label)
		return

	for i in Inventory.barrels.size():
		var barrel = Inventory.barrels[i]
		var hbox := HBoxContainer.new()

		var info := Label.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if barrel.is_filled:
			var mature_text := " [숙성완료]" if barrel.is_mature() else ""
			info.text = "%s: %d개월%s" % [barrel.get_type_name(), barrel.age_months, mature_text]
			if barrel.is_mature():
				info.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
			else:
				info.add_theme_color_override("font_color", Color(0.8, 0.6, 0.3))
		else:
			info.text = "%s: 비어있음" % barrel.get_type_name()
			info.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

		hbox.add_child(info)

		# 빈 배럴 + 증류원액 보유 시 채우기 버튼
		if not barrel.is_filled and Inventory.has_item("new_make_spirit", 1):
			var btn := Button.new()
			btn.text = "채우기"
			btn.pressed.connect(_on_fill_pressed.bind(i))
			hbox.add_child(btn)

		barrel_list.add_child(hbox)


func _on_fill_pressed(barrel_index: int) -> void:
	# BarrelRack 노드를 찾아서 fill_barrel 호출
	var barrel_rack := _find_barrel_rack()
	if barrel_rack and barrel_rack.fill_barrel(barrel_index):
		_refresh()


func _find_barrel_rack() -> Node:
	var tree := get_tree()
	for node in tree.get_nodes_in_group("interactable"):
		if node.has_method("fill_barrel"):
			return node
	return null
