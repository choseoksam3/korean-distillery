extends Area2D
## 서빙대. 플레이어가 E키로 상호작용하면 서빙 UI 열림.

func _ready() -> void:
	add_to_group("interactable")


func interact() -> void:
	var bar_manager = _get_bar_manager()
	if not bar_manager:
		return
	var waiting: Array = bar_manager.get_waiting_customers()
	if waiting.is_empty():
		return
	SignalBus.serving_ui_requested.emit()


func _get_bar_manager() -> Node:
	return get_parent().get_node_or_null("BarManager")
