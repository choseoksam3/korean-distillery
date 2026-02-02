extends CanvasLayer
## 증류 미니게임: 컷 포인트 선택
## 인디케이터가 0~1 사이를 왕복, E키 2번으로 시작/끝점 선택
## Hearts 구간(0.3~0.7)을 정확히 잡을수록 고품질

const HEARTS_START: float = 0.3
const HEARTS_END: float = 0.7
const SWEET_SPOT_START: float = 0.4
const SWEET_SPOT_END: float = 0.6
const INDICATOR_SPEED: float = 0.8  # 초당 이동량

@onready var bg: ColorRect = $BG
@onready var bar_bg: ColorRect = $BarBG
@onready var foreshots_bar: ColorRect = $ForeshotsBar
@onready var heads_bar: ColorRect = $HeadsBar
@onready var hearts_bar: ColorRect = $HeartsBar
@onready var tails_bar: ColorRect = $TailsBar
@onready var indicator: ColorRect = $Indicator
@onready var cut_start_marker: ColorRect = $CutStartMarker
@onready var instruction_label: Label = $InstructionLabel
@onready var result_label: Label = $ResultLabel

var indicator_pos: float = 0.0
var direction: float = 1.0
var cut_start: float = -1.0
var cut_end: float = -1.0
var cuts_made: int = 0
var is_active: bool = false
var bar_x: float = 40.0
var bar_width: float = 240.0
var bar_y: float = 80.0
var bar_height: float = 20.0


func _ready() -> void:
	visible = false
	set_process(false)


func start_minigame() -> void:
	visible = true
	is_active = true
	cuts_made = 0
	cut_start = -1.0
	cut_end = -1.0
	indicator_pos = 0.0
	direction = 1.0
	cut_start_marker.visible = false
	result_label.visible = false
	instruction_label.text = "[E] 시작점 선택"
	set_process(true)
	SignalBus.minigame_started.emit("distilling")
	GameManager.is_paused = true


func _process(delta: float) -> void:
	if not is_active:
		return
	# 인디케이터 왕복 이동
	indicator_pos += direction * INDICATOR_SPEED * delta
	if indicator_pos >= 1.0:
		indicator_pos = 1.0
		direction = -1.0
	elif indicator_pos <= 0.0:
		indicator_pos = 0.0
		direction = 1.0
	# 인디케이터 위치 업데이트
	indicator.position.x = bar_x + indicator_pos * bar_width - 1


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if cuts_made == 0:
			# 첫 번째 컷: 시작점
			cut_start = indicator_pos
			cuts_made = 1
			cut_start_marker.visible = true
			cut_start_marker.position.x = bar_x + cut_start * bar_width - 1
			instruction_label.text = "[E] 끝점 선택"
		elif cuts_made == 1:
			# 두 번째 컷: 끝점
			cut_end = indicator_pos
			cuts_made = 2
			is_active = false
			set_process(false)
			_calculate_result()


func _calculate_result() -> void:
	# 시작/끝 정렬
	var start := minf(cut_start, cut_end)
	var end := maxf(cut_start, cut_end)

	# Hearts 구간과 겹치는 비율 계산
	var overlap_start := maxf(start, HEARTS_START)
	var overlap_end := minf(end, HEARTS_END)
	var overlap := maxf(0.0, overlap_end - overlap_start)
	var hearts_length := HEARTS_END - HEARTS_START
	var cut_length := maxf(end - start, 0.01)

	# 정밀도: 선택 영역 중 hearts에 해당하는 비율
	var precision := overlap / cut_length
	# 커버리지: hearts 영역 중 선택한 비율
	var coverage := overlap / hearts_length

	# 스위트스팟 보너스
	var sweet_overlap_start := maxf(start, SWEET_SPOT_START)
	var sweet_overlap_end := minf(end, SWEET_SPOT_END)
	var sweet_overlap := maxf(0.0, sweet_overlap_end - sweet_overlap_start)
	var sweet_length := SWEET_SPOT_END - SWEET_SPOT_START
	var sweet_bonus := sweet_overlap / sweet_length * 0.3

	# 최종 품질 = hearts 겹침도 70% + 스위트스팟 보너스 30%
	var quality := (precision * coverage) * 0.7 + sweet_bonus
	quality = clampf(quality, 0.0, 1.0)

	# 결과 표시
	result_label.visible = true
	result_label.text = "품질: %.0f%%" % (quality * 100)
	instruction_label.text = "[E] 확인"

	# 잠시 후 완료 처리
	await get_tree().create_timer(1.5).timeout
	_finish(quality)


func _finish(quality: float) -> void:
	var result := {"quality": quality, "flavor_profile": GameManager.temp_flavor_profile.duplicate()}
	GameManager.temp_distill_quality = quality
	visible = false
	GameManager.is_paused = false
	SignalBus.minigame_completed.emit("distilling", result)
