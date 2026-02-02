class_name StationBase
extends Area2D
## 제조 스테이션 기본 클래스.
## Area2D 기반, interactable 그룹. 시간 페이즈마다 생산 진행.

enum StationState { IDLE, PROCESSING, COMPLETE }

@export var station_name: String = "스테이션"
@export var station_color: Color = Color(0.5, 0.5, 0.5)

var state: StationState = StationState.IDLE
var phases_remaining: int = 0

@onready var visual: Polygon2D = $Visual
@onready var label_node: Label = $Label
@onready var status_indicator: Polygon2D = $StatusIndicator


func _ready() -> void:
	add_to_group("interactable")
	collision_layer = 4  # Interactables
	collision_mask = 1   # Player
	SignalBus.time_phase_changed.connect(_on_phase_changed)
	_update_visuals()


func interact() -> void:
	match state:
		StationState.IDLE:
			_try_start_production()
		StationState.PROCESSING:
			_show_progress()
		StationState.COMPLETE:
			_collect_output()


func _try_start_production() -> void:
	# 하위 클래스에서 오버라이드
	pass


func _show_progress() -> void:
	# 하위 클래스에서 오버라이드 (기본: 남은 페이즈 표시)
	pass


func _collect_output() -> void:
	# 하위 클래스에서 오버라이드
	pass


func start_processing(duration_phases: int) -> void:
	state = StationState.PROCESSING
	phases_remaining = duration_phases
	SignalBus.production_started.emit(station_name, "")
	_update_visuals()


func _on_phase_changed(_phase: String) -> void:
	if state == StationState.PROCESSING:
		phases_remaining -= 1
		if phases_remaining <= 0:
			state = StationState.COMPLETE
			_on_production_complete()
		_update_visuals()


func _on_production_complete() -> void:
	# 하위 클래스에서 오버라이드
	SignalBus.production_completed.emit(station_name, "")
	_update_visuals()


func _update_visuals() -> void:
	if not is_inside_tree():
		return
	if status_indicator:
		match state:
			StationState.IDLE:
				status_indicator.color = Color(0.4, 0.4, 0.4)  # 회색
			StationState.PROCESSING:
				status_indicator.color = Color(0.9, 0.8, 0.2)  # 노란색
			StationState.COMPLETE:
				status_indicator.color = Color(0.3, 0.8, 0.3)  # 초록색
