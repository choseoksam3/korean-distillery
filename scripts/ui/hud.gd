extends CanvasLayer
## HUD: 날짜/시간, 상호작용 힌트 표시.

@onready var day_label: Label = $DayLabel
@onready var interact_hint: Label = $InteractHint


func _ready() -> void:
	SignalBus.day_changed.connect(_on_day_changed)
	SignalBus.time_phase_changed.connect(_on_phase_changed)
	_update_day_display()
	interact_hint.visible = false


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and "nearest_interactable" in player:
		interact_hint.visible = player.nearest_interactable != null
	else:
		interact_hint.visible = false


func _update_day_display() -> void:
	day_label.text = GameManager.get_day_display()


func _on_day_changed(_day: int) -> void:
	_update_day_display()


func _on_phase_changed(_phase: String) -> void:
	_update_day_display()
