extends Node
## 메인 씬. 월드 씬 전환과 플레이어 관리를 담당.

const PLAYER_SCENE: PackedScene = preload("res://scenes/characters/player.tscn")
const INITIAL_WORLD: String = "res://scenes/world/distillery.tscn"

var current_world: Node2D = null
var player: CharacterBody2D = null
var is_transitioning: bool = false


func _ready() -> void:
	player = PLAYER_SCENE.instantiate()
	SignalBus.scene_transition_requested.connect(_on_scene_transition)
	_load_world(INITIAL_WORLD, "default")


func _load_world(scene_path: String, spawn_point: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true

	# 기존 월드 제거
	if current_world:
		if player.get_parent() == current_world:
			current_world.remove_child(player)
		current_world.queue_free()
		await current_world.tree_exited

	# 새 월드 로드
	var world_scene: PackedScene = load(scene_path)
	current_world = world_scene.instantiate()
	add_child(current_world)

	# 스폰 포인트에 플레이어 배치
	var spawn: Node2D = current_world.get_node_or_null("SpawnPoints/" + spawn_point)
	if spawn:
		player.global_position = spawn.global_position
	else:
		player.global_position = Vector2.ZERO

	current_world.add_child(player)
	is_transitioning = false


func _on_scene_transition(scene_path: String, spawn_point: String) -> void:
	_load_world(scene_path, spawn_point)
