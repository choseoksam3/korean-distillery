extends Node
## 전역 시그널 허브. 컴포넌트 간 느슨한 결합을 위해 사용.

# 시간 시스템
signal day_changed(day: int)
signal time_phase_changed(phase: String)

# 경제
signal money_changed(amount: int)

# 인벤토리
signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String, quantity: int)
signal inventory_changed()

# 생산
signal production_started(station_name: String, recipe_id: String)
signal production_completed(station_name: String, output_id: String)

# 배럴
signal barrel_filled(barrel_index: int)
signal barrel_aged(barrel_index: int, age_months: int)
signal barrel_emptied(barrel_index: int)

# UI 요청
signal barrel_ui_requested()
signal bottling_ui_requested()

# 미니게임
signal minigame_started(minigame_type: String)
signal minigame_completed(minigame_type: String, result: Dictionary)

# 위스키
signal whisky_completed(whisky: Resource)

# 바 운영
signal customer_served(satisfaction: float)
signal customer_arrived(customer_data: Dictionary)
signal customer_order_placed(seat_index: int, order: Dictionary)
signal whisky_served(seat_index: int, satisfaction: float)
signal bar_session_started()
signal bar_session_ended(earnings: int)
signal day_summary_requested(summary: Dictionary)
signal serving_ui_requested()

# 씬 전환
signal scene_transition_requested(scene_path: String, spawn_point: String)
