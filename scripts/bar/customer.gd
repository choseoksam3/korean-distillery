extends Node2D
## 손님 NPC. 바에서 자리에 앉아 주문하고 서빙을 기다림.

enum State { ENTERING, SEATED, ORDERING, WAITING, DRINKING, LEAVING }

var current_state: State = State.ENTERING
var seat_index: int = -1
var seat_position: Vector2 = Vector2.ZERO
var customer_data: Resource = null
var order: Dictionary = {}
var satisfaction: float = 0.0
var served: bool = false

@onready var body: Polygon2D = $Body
@onready var head: Polygon2D = $Head
@onready var speech_bubble: Label = $SpeechBubble


func _ready() -> void:
	if customer_data:
		body.color = customer_data.sprite_color
		head.color = customer_data.sprite_color.lightened(0.2)


func setup(data: Resource, idx: int, target_pos: Vector2) -> void:
	customer_data = data
	seat_index = idx
	seat_position = target_pos
	order = data.preferred_flavors.duplicate()
	position = Vector2(-80, target_pos.y)


func enter_bar() -> void:
	current_state = State.ENTERING
	var tween = create_tween()
	tween.tween_property(self, "position", seat_position, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(_on_seated)


func _on_seated() -> void:
	current_state = State.SEATED
	await get_tree().create_timer(0.3).timeout
	_place_order()


func _place_order() -> void:
	current_state = State.ORDERING
	var flavor_text: String = ""
	var flavors: Array = customer_data.preferred_flavors.keys()
	if flavors.size() > 0:
		var top_flavor: String = flavors[0]
		var top_val: float = 0.0
		for f in flavors:
			if customer_data.preferred_flavors[f] > top_val:
				top_val = customer_data.preferred_flavors[f]
				top_flavor = f
		flavor_text = _get_flavor_korean(top_flavor)
	speech_bubble.text = flavor_text + "?"
	speech_bubble.visible = true
	current_state = State.WAITING
	SignalBus.customer_order_placed.emit(seat_index, order)


func serve_whisky(whisky: Resource) -> float:
	if current_state != State.WAITING:
		return 0.0
	current_state = State.DRINKING
	speech_bubble.visible = false
	satisfaction = _calculate_satisfaction(whisky)
	served = true

	if satisfaction >= 0.7:
		speech_bubble.text = "!!"
	elif satisfaction >= 0.4:
		speech_bubble.text = "!"
	else:
		speech_bubble.text = "..."
	speech_bubble.visible = true

	SignalBus.whisky_served.emit(seat_index, satisfaction)
	SignalBus.customer_served.emit(satisfaction)

	await get_tree().create_timer(1.0).timeout
	leave()
	return satisfaction


func _calculate_satisfaction(whisky: Resource) -> float:
	var whisky_flavors: Dictionary = whisky.flavor_profile if whisky.flavor_profile else {}
	var whisky_quality: float = whisky.quality if "quality" in whisky else 0.5
	var whisky_age: int = whisky.age_months if "age_months" in whisky else 0

	var flavor_match: float = 0.0
	var total_weight: float = 0.0
	for flavor_key in customer_data.preferred_flavors:
		var pref_val: float = customer_data.preferred_flavors[flavor_key]
		var whisky_val: float = whisky_flavors.get(flavor_key, 0.0)
		flavor_match += minf(whisky_val, pref_val)
		total_weight += pref_val
	if total_weight > 0.0:
		flavor_match /= total_weight
	else:
		flavor_match = 0.5

	var quality_match: float = 1.0
	if customer_data.min_quality > 0.0:
		if whisky_quality >= customer_data.min_quality:
			quality_match = 1.0
		else:
			quality_match = whisky_quality / customer_data.min_quality

	var age_match: float = 1.0
	if customer_data.min_age_months > 0:
		if whisky_age >= customer_data.min_age_months:
			age_match = 1.0
		else:
			age_match = float(whisky_age) / float(customer_data.min_age_months)

	return flavor_match * 0.4 + quality_match * 0.3 + age_match * 0.3


func leave() -> void:
	current_state = State.LEAVING
	speech_bubble.visible = false
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(170, position.y), 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(queue_free)


func force_leave() -> void:
	if current_state == State.LEAVING:
		return
	leave()


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
