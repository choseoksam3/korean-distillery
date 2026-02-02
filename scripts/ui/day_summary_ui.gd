extends CanvasLayer
## 일일 정산 UI. 밤 전환 시 하루 실적 표시.

@onready var panel: Panel = $Panel
@onready var content: VBoxContainer = $Panel/Content
@onready var close_hint: Label = $Panel/CloseHint

var is_open: bool = false


func _ready() -> void:
	layer = 20
	visible = false
	SignalBus.day_summary_requested.connect(_on_summary_requested)


func _on_summary_requested(summary: Dictionary) -> void:
	_show_summary(summary)


func _show_summary(summary: Dictionary) -> void:
	is_open = true
	visible = true
	GameManager.is_paused = true

	# 기존 내용 제거
	for child in content.get_children():
		child.queue_free()

	# 제목
	var title := Label.new()
	title.text = "%d일차 정산" % summary.get("day", 1)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	content.add_child(title)

	# 구분선
	var sep := HSeparator.new()
	content.add_child(sep)

	# 서빙 정보
	var served_label := Label.new()
	served_label.text = "서빙한 위스키: %d잔" % summary.get("served", 0)
	served_label.add_theme_font_size_override("font_size", 7)
	content.add_child(served_label)

	# 매출
	var earnings: int = summary.get("earnings", 0)
	var tips: int = summary.get("tips", 0)
	var total: int = earnings + tips

	var earnings_label := Label.new()
	earnings_label.text = "매출: %d원" % earnings
	earnings_label.add_theme_font_size_override("font_size", 7)
	content.add_child(earnings_label)

	var tips_label := Label.new()
	tips_label.text = "팁: %d원" % tips
	tips_label.add_theme_font_size_override("font_size", 7)
	content.add_child(tips_label)

	var total_label := Label.new()
	total_label.text = "총 수입: %d원" % total
	total_label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))
	total_label.add_theme_font_size_override("font_size", 7)
	content.add_child(total_label)

	# 만족도
	var avg_sat: float = summary.get("avg_satisfaction", 0.0)
	var sat_label := Label.new()
	if summary.get("served", 0) > 0:
		sat_label.text = "평균 만족도: %.0f%%" % (avg_sat * 100)
	else:
		sat_label.text = "손님 서빙 없음"
	sat_label.add_theme_font_size_override("font_size", 7)
	content.add_child(sat_label)

	# 숙성 현황
	var barrels: int = summary.get("barrels_aging", 0)
	if barrels > 0:
		var barrel_label := Label.new()
		barrel_label.text = "숙성중인 배럴: %d개" % barrels
		barrel_label.add_theme_font_size_override("font_size", 7)
		barrel_label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.3))
		content.add_child(barrel_label)

	# 보유 자금
	var money_label := Label.new()
	money_label.text = "보유 자금: %d원" % Economy.money
	money_label.add_theme_font_size_override("font_size", 7)
	money_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	content.add_child(money_label)


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action_pressed("interact"):
		_close()
		get_viewport().set_input_as_handled()


func _close() -> void:
	is_open = false
	visible = false
	GameManager.is_paused = false
