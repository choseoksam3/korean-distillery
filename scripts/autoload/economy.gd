extends Node
## 경제 시스템. 돈 관리, 수입/지출 통계.

var money: int = 0
var total_earned: int = 0
var total_spent: int = 0


func add_money(amount: int) -> void:
	money += amount
	total_earned += amount
	SignalBus.money_changed.emit(money)


func spend_money(amount: int) -> bool:
	if money < amount:
		return false
	money -= amount
	total_spent += amount
	SignalBus.money_changed.emit(money)
	return true
