class_name ProductionBatchData
extends Resource
## 진행 중인 생산 배치 데이터.

enum BatchState { WAITING, PROCESSING, COMPLETE }

@export var recipe_id: String = ""
@export var station_type: String = ""
@export var state: BatchState = BatchState.WAITING
@export var phases_remaining: int = 0
@export var output_id: String = ""
@export var output_quantity: int = 1
@export var flavor_profile: Dictionary = {}
@export var quality: float = 0.5
