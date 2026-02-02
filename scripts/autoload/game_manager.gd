extends Node
## 날짜, 시간대, 게임 상태를 관리하는 싱글톤.

enum TimePhase { MORNING, AFTERNOON, EVENING, NIGHT }

const PHASE_NAMES: Dictionary = {
	TimePhase.MORNING: "morning",
	TimePhase.AFTERNOON: "afternoon",
	TimePhase.EVENING: "evening",
	TimePhase.NIGHT: "night",
}

const PHASE_LABELS: Dictionary = {
	TimePhase.MORNING: "오전",
	TimePhase.AFTERNOON: "오후",
	TimePhase.EVENING: "저녁",
	TimePhase.NIGHT: "밤",
}

var current_day: int = 1
var current_phase: TimePhase = TimePhase.MORNING
var is_paused: bool = false

# 스테이션 간 풍미 전달용 임시 변수
var temp_flavor_profile: Dictionary = {}
var temp_yeast_type: String = ""
var temp_distill_quality: float = 0.5


func get_phase_name() -> String:
	return PHASE_NAMES[current_phase]


func get_phase_label() -> String:
	return PHASE_LABELS[current_phase]


func advance_phase() -> void:
	match current_phase:
		TimePhase.MORNING:
			current_phase = TimePhase.AFTERNOON
		TimePhase.AFTERNOON:
			current_phase = TimePhase.EVENING
		TimePhase.EVENING:
			current_phase = TimePhase.NIGHT
		TimePhase.NIGHT:
			current_phase = TimePhase.MORNING
			current_day += 1
			SignalBus.day_changed.emit(current_day)
	SignalBus.time_phase_changed.emit(get_phase_name())
	# EVENING→NIGHT: 바 세션 종료는 BarManager가 time_phase_changed로 처리
	# NIGHT→MORNING은 day_changed로 배럴 숙성 등 처리


func get_day_display() -> String:
	return "Day %d - %s" % [current_day, get_phase_label()]
