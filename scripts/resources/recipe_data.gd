class_name RecipeData
extends Resource
## 제조 레시피 데이터.

@export var id: String = ""
@export var name: String = ""
@export var inputs: Dictionary = {}   # {"item_id": quantity, ...}
@export var output_id: String = ""
@export var output_quantity: int = 1
@export var duration_phases: int = 1  # 소요 페이즈 수
@export var station_type: String = ""  # mash_tun, fermenter, pot_still
