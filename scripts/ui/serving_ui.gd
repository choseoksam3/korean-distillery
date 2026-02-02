extends CanvasLayer
## 서빙 UI. 손님 주문 정보 + 위스키 목록 표시, 서빙 처리.

@onready var panel: Panel = $Panel
@onready var customer_info: VBoxContainer = $Panel/CustomerInfo
@onready var whisky_list: VBoxContainer = $Panel/WhiskyList
@onready var result_label: Label = $Panel/ResultLabel
@onready var close_btn: Label = $Panel/CloseHint

var bar_manager: Node = null
var current_customer_index: int = 0
var waiting_customers: Array = []
var is_open: bool = false


func _ready() -> void:
	layer = 12
	visible = false
	SignalBus.serving_ui_requested.connect(_on_serving_requested)


func _on_serving_requested() -> void:
	_find_bar_manager()
	if not bar_manager:
		return
	waiting_customers = bar_manager.get_waiting_customers()
	if waiting_customers.is_empty():
		return
	current_customer_index = 0
	_open()


func _find_bar_manager() -> void:
	# BarManager는 현재 월드 씬의 자식
	var main_node := get_tree().get_first_node_in_group("player")
	if main_node:
		bar_manager = main_node.get_parent().get_node_or_null("BarManager")


func _open() -> void:
	is_open = true
	visible = true
	GameManager.is_paused = true
	result_label.text = ""
	_update_display()


func _close() -> void:
	is_open = false
	visible = false
	GameManager.is_paused = false


func _update_display() -> void:
	# 왼쪽: 손님 정보
	_clear_container(customer_info)
	_clear_container(whisky_list)

	if current_customer_index >= waiting_customers.size():
		_close()
		return

	var customer: Node2D = waiting_customers[current_customer_index]
	if not is_instance_valid(customer) or customer.current_state != customer.State.WAITING:
		current_customer_index += 1
		_update_display()
		return

	# 손님 이름
	var name_label := Label.new()
	name_label.text = customer.customer_data.customer_name
	name_label.add_theme_color_override("font_color", customer.customer_data.sprite_color)
	customer_info.add_child(name_label)

	# 선호 풍미
	var pref_label := Label.new()
	var flavor_text := "선호: "
	for key in customer.customer_data.preferred_flavors:
		flavor_text += _get_flavor_korean(key) + " "
	pref_label.text = flavor_text
	pref_label.add_theme_font_size_override("font_size", 7)
	customer_info.add_child(pref_label)

	# 최소 요구
	if customer.customer_data.min_quality > 0.0 or customer.customer_data.min_age_months > 0:
		var req_label := Label.new()
		var req_parts: Array = []
		if customer.customer_data.min_quality > 0.0:
			req_parts.append("품질 %.0f%%" % (customer.customer_data.min_quality * 100))
		if customer.customer_data.min_age_months > 0:
			req_parts.append("숙성 %d개월+" % customer.customer_data.min_age_months)
		req_label.text = "요구: " + ", ".join(req_parts)
		req_label.add_theme_font_size_override("font_size", 7)
		customer_info.add_child(req_label)

	# 오른쪽: 위스키 목록
	if Inventory.whisky_inventory.is_empty():
		var empty_label := Label.new()
		empty_label.text = "위스키 없음"
		empty_label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.4))
		whisky_list.add_child(empty_label)
	else:
		for i in Inventory.whisky_inventory.size():
			var whisky = Inventory.whisky_inventory[i]
			var btn := Button.new()
			btn.text = "%s (품질%.0f%%)" % [whisky.get_display_name(), whisky.quality * 100]
			btn.add_theme_font_size_override("font_size", 7)
			btn.pressed.connect(_on_serve_pressed.bind(i))
			whisky_list.add_child(btn)


func _on_serve_pressed(whisky_index: int) -> void:
	if whisky_index >= Inventory.whisky_inventory.size():
		return
	if current_customer_index >= waiting_customers.size():
		return

	var customer: Node2D = waiting_customers[current_customer_index]
	if not is_instance_valid(customer):
		current_customer_index += 1
		_update_display()
		return

	var whisky = Inventory.whisky_inventory[whisky_index]

	# 서빙 실행
	var satisfaction: float = await customer.serve_whisky(whisky)

	# 가격/팁 계산
	var base_payment: int = whisky.calculate_price()
	var tip: int = int(base_payment * satisfaction * customer.customer_data.tip_multiplier)
	var total: int = base_payment + tip

	# 정산
	if bar_manager:
		bar_manager.add_earnings(base_payment, tip)

	# 재고 제거
	Inventory.remove_whisky(whisky_index)

	# 결과 표시
	var star := ""
	if satisfaction >= 0.7:
		star = "★★★"
	elif satisfaction >= 0.4:
		star = "★★"
	else:
		star = "★"
	result_label.text = "%s  +%d원 (팁 %d) %s" % [star, total, tip, ""]

	# 다음 손님으로
	current_customer_index += 1
	await get_tree().create_timer(1.2).timeout
	if is_open:
		if current_customer_index < waiting_customers.size():
			_update_display()
		else:
			_close()


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action_pressed("interact"):
		_close()
		get_viewport().set_input_as_handled()


func _clear_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()


func _get_flavor_korean(flavor: String) -> String:
	match flavor:
		"smoky": return "스모키"
		"sweet": return "달콤"
		"fruity": return "과일"
		"vanilla": return "바닐라"
		"caramel": return "캐러멜"
		"floral": return "꽃향"
		"spicy": return "스파이시"
		_: return flavor
