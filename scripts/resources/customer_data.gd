extends Resource
## 손님 데이터 리소스.

@export var customer_name: String = ""
@export var preferred_flavors: Dictionary = {}
@export var min_quality: float = 0.0
@export var min_age_months: int = 0
@export var patience: float = 1.0
@export var tip_multiplier: float = 1.0
@export var sprite_color: Color = Color(0.6, 0.6, 0.8)


static func from_dict(data: Dictionary) -> Resource:
	var script = load("res://scripts/resources/customer_data.gd")
	var cd = script.new()
	cd.customer_name = data.get("name", "손님")
	cd.min_quality = data.get("min_quality", 0.0)
	cd.min_age_months = data.get("min_age", 0)
	cd.patience = data.get("patience", 1.0)
	cd.tip_multiplier = data.get("tip_mult", 1.0)
	var c: Array = data.get("color", [0.6, 0.6, 0.8])
	cd.sprite_color = Color(c[0], c[1], c[2])
	cd.preferred_flavors = _generate_preferred_flavors(data.get("id", "casual"))
	return cd


static func _generate_preferred_flavors(type_id: String) -> Dictionary:
	match type_id:
		"casual":
			return {"sweet": 0.5, "fruity": 0.5}
		"connoisseur":
			return {"smoky": 0.7, "vanilla": 0.6, "caramel": 0.5}
		"tourist":
			return {"sweet": 0.6, "fruity": 0.4, "floral": 0.3}
		"critic":
			return {"smoky": 0.8, "vanilla": 0.7, "caramel": 0.6, "fruity": 0.4}
		"regular":
			return {"sweet": 0.4, "smoky": 0.3, "vanilla": 0.4}
		_:
			return {"sweet": 0.5}
