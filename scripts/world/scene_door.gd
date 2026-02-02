extends Area2D
## 씬 전환 트리거. 플레이어가 접촉하면 다른 씬으로 이동.

@export var target_scene: String = ""
@export var target_spawn: String = "default"

var player_inside: bool = false


func _ready() -> void:
	add_to_group("interactable")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func interact() -> void:
	if target_scene != "":
		SignalBus.scene_transition_requested.emit(target_scene, target_spawn)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_inside = true


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_inside = false
