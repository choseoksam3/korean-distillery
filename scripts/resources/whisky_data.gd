class_name WhiskyData
extends "res://scripts/resources/item_data.gd"
## 완성된 위스키 데이터.

@export var age_months: int = 0
@export var flavor_profile: Dictionary = {}  # {"smoky": 0, "sweet": 0, "fruity": 0, ...}
@export var quality: float = 0.5  # 0.0 ~ 1.0
@export var base_price: int = 100
@export var barrel_type: String = ""
@export var yeast_type: String = ""
@export var distill_quality: float = 0.5


func get_age_years() -> int:
	@warning_ignore("integer_division")
	return age_months / 12


func get_display_name() -> String:
	var years := get_age_years()
	if years > 0:
		return "%d년산 위스키" % years
	return "숙성 위스키"


func calculate_price() -> int:
	return int((50 + age_months * 2) * (0.5 + quality * 1.5))
