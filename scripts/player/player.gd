extends CharacterBody2D
## 플레이어 캐릭터. 8방향 이동, 인터랙션 처리.

const SPEED: float = 80.0

enum Facing { DOWN, UP, LEFT, RIGHT }

var facing: Facing = Facing.DOWN
var nearest_interactable: Area2D = null


func _ready() -> void:
	add_to_group("player")


func _physics_process(_delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * SPEED

	if input_dir != Vector2.ZERO:
		_update_facing(input_dir)

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and nearest_interactable:
		if nearest_interactable.has_method("interact"):
			nearest_interactable.interact()


func _update_facing(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		facing = Facing.RIGHT if direction.x > 0 else Facing.LEFT
	else:
		facing = Facing.DOWN if direction.y > 0 else Facing.UP


func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		nearest_interactable = area


func _on_interaction_area_exited(area: Area2D) -> void:
	if area == nearest_interactable:
		nearest_interactable = null
