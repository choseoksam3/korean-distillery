extends Node
## 바 세션 관리. 손님 스폰, 서빙 결과 수집, 정산.

const CUSTOMER_SCENE: PackedScene = preload("res://scenes/characters/customer.tscn")
const CustomerDataScript = preload("res://scripts/resources/customer_data.gd")

var customer_types: Array = []
var active_customers: Array = []
var session_active: bool = false
var session_earnings: int = 0
var session_tips: int = 0
var session_served: int = 0
var session_satisfaction_sum: float = 0.0
var seats: Array = []
var occupied_seats: Dictionary = {}


func _ready() -> void:
	_load_customer_types()
	SignalBus.time_phase_changed.connect(_on_phase_changed)
	SignalBus.whisky_served.connect(_on_whisky_served)
	call_deferred("_find_seats")


func _find_seats() -> void:
	var seats_parent = get_parent().get_node_or_null("Seats")
	if seats_parent:
		for child in seats_parent.get_children():
			if child is Marker2D:
				seats.append(child)


func _load_customer_types() -> void:
	var file = FileAccess.open("res://data/customers.json", FileAccess.READ)
	if not file:
		push_error("customers.json 로드 실패")
		return
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	if err != OK:
		push_error("customers.json 파싱 실패: " + json.get_error_message())
		return
	customer_types = json.data


func _on_phase_changed(phase: String) -> void:
	if phase == "evening":
		start_session()
	elif phase == "night":
		end_session()


func start_session() -> void:
	if session_active:
		return
	session_active = true
	session_earnings = 0
	session_tips = 0
	session_served = 0
	session_satisfaction_sum = 0.0
	active_customers.clear()
	occupied_seats.clear()
	SignalBus.bar_session_started.emit()
	_spawn_customers()


func _spawn_customers() -> void:
	if customer_types.is_empty():
		return
	var count: int = randi_range(3, mini(5, seats.size()))
	for i in count:
		var timer = get_tree().create_timer(0.5 + i * 0.8)
		timer.timeout.connect(_spawn_one_customer.bind(i))


func _spawn_one_customer(index: int) -> void:
	if not session_active:
		return
	if index >= seats.size():
		return
	var type_data: Dictionary = customer_types[randi() % customer_types.size()]
	var cdata = CustomerDataScript.from_dict(type_data)

	var customer: Node2D = CUSTOMER_SCENE.instantiate()
	get_parent().add_child(customer)
	customer.setup(cdata, index, seats[index].global_position)
	customer.enter_bar()

	active_customers.append(customer)
	occupied_seats[index] = customer
	SignalBus.customer_arrived.emit({
		"name": cdata.customer_name,
		"seat_index": index,
		"preferred_flavors": cdata.preferred_flavors,
	})


func _on_whisky_served(seat_index: int, satisfaction: float) -> void:
	session_satisfaction_sum += satisfaction
	session_served += 1
	if seat_index in occupied_seats:
		occupied_seats.erase(seat_index)


func get_waiting_customers() -> Array:
	var waiting: Array = []
	for customer in active_customers:
		if is_instance_valid(customer) and customer.current_state == customer.State.WAITING:
			waiting.append(customer)
	return waiting


func get_customer_at_seat(seat_index: int) -> Node2D:
	if seat_index in occupied_seats:
		var c = occupied_seats[seat_index]
		if is_instance_valid(c):
			return c
	return null


func add_earnings(base: int, tip: int) -> void:
	session_earnings += base
	session_tips += tip
	Economy.add_money(base + tip)


func end_session() -> void:
	if not session_active:
		return
	session_active = false
	for customer in active_customers:
		if is_instance_valid(customer):
			customer.force_leave()
	var avg_satisfaction: float = 0.0
	if session_served > 0:
		avg_satisfaction = session_satisfaction_sum / session_served
	var summary: Dictionary = {
		"day": GameManager.current_day,
		"served": session_served,
		"earnings": session_earnings,
		"tips": session_tips,
		"avg_satisfaction": avg_satisfaction,
		"barrels_aging": Inventory.get_filled_barrel_indices().size(),
	}
	SignalBus.bar_session_ended.emit(session_earnings + session_tips)
	SignalBus.day_summary_requested.emit(summary)
