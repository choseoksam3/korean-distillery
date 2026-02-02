extends CanvasLayer
## HUD: 날짜/시간, 상호작용 힌트, 프로덕션 상태, 돈 표시.

@onready var day_label: Label = $DayLabel
@onready var interact_hint: Label = $InteractHint
@onready var production_hud: VBoxContainer = $ProductionHUD
@onready var money_label: Label = $MoneyLabel


func _ready() -> void:
	SignalBus.day_changed.connect(_on_day_changed)
	SignalBus.time_phase_changed.connect(_on_phase_changed)
	SignalBus.money_changed.connect(_on_money_changed)
	_update_day_display()
	_update_money_display()
	interact_hint.visible = false


func _process(_delta: float) -> void:
	if GameManager.is_paused:
		interact_hint.visible = false
		return
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


func _update_money_display() -> void:
	money_label.text = "%d원" % Economy.money


func _on_money_changed(_amount: int) -> void:
	_update_money_display()
