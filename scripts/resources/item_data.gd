class_name ItemData
extends Resource
## 아이템 기본 데이터.

@export var id: String = ""
@export var name: String = ""
@export var type: String = "material"  # material, product, tool
@export var icon_color: Color = Color.WHITE
@export var description: String = ""
@export var stackable: bool = true
@export var max_stack: int = 99
