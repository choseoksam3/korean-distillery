class_name BarrelData
extends Resource
## 배럴(오크통) 상태 데이터.

enum BarrelType { AMERICAN_OAK, EUROPEAN_OAK, SHERRY_CASK }

const BARREL_TYPE_NAMES: Dictionary = {
	BarrelType.AMERICAN_OAK: "아메리칸 오크",
	BarrelType.EUROPEAN_OAK: "유러피안 오크",
	BarrelType.SHERRY_CASK: "셰리 캐스크",
}

const BARREL_FLAVOR_BONUS: Dictionary = {
	BarrelType.AMERICAN_OAK: {"vanilla": 20, "sweet": 15},
	BarrelType.EUROPEAN_OAK: {"spicy": 20, "woody": 15},
	BarrelType.SHERRY_CASK: {"fruity": 20, "sweet": 10},
}

@export var barrel_type: BarrelType = BarrelType.AMERICAN_OAK
@export var is_filled: bool = false
@export var age_months: int = 0
@export var flavor_profile: Dictionary = {}
@export var distill_quality: float = 0.5
@export var yeast_type: String = ""


func get_type_name() -> String:
	return BARREL_TYPE_NAMES[barrel_type]


func get_flavor_with_barrel() -> Dictionary:
	var result := flavor_profile.duplicate()
	var bonus: Dictionary = BARREL_FLAVOR_BONUS[barrel_type]
	for key in bonus:
		result[key] = result.get(key, 0) + bonus[key]
	return result


func is_mature() -> bool:
	return age_months >= 12
