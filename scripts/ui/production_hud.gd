extends VBoxContainer
## 프로덕션 HUD: 진행 중인 생산 상태 인디케이터 표시

var station_labels: Dictionary = {}


func _ready() -> void:
	SignalBus.production_started.connect(_on_production_started)
	SignalBus.production_completed.connect(_on_production_completed)
	_build_indicators()


func _build_indicators() -> void:
	var stations := ["매싱탱크", "발효탱크", "증류기", "숙성대", "병입대"]
	for sname in stations:
		var label := Label.new()
		label.text = "● %s" % sname
		label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		add_child(label)
		station_labels[sname] = label


func _on_production_started(station_name: String, _recipe_id: String) -> void:
	if station_name in station_labels:
		station_labels[station_name].add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))


func _on_production_completed(station_name: String, _output_id: String) -> void:
	if station_name in station_labels:
		station_labels[station_name].add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
	# 잠시 후 회색으로 복귀
	await get_tree().create_timer(2.0).timeout
	if station_name in station_labels:
		station_labels[station_name].add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
