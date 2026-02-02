extends Node
## 전역 시그널 허브. 컴포넌트 간 느슨한 결합을 위해 사용.

# 시간 시스템
signal day_changed(day: int)
signal time_phase_changed(phase: String)

# 경제
signal money_changed(amount: int)

# 인벤토리
signal item_added(item_id: String, quantity: int)

# 위스키
signal whisky_completed(whisky: Resource)

# 바 운영
signal customer_served(satisfaction: float)

# 씬 전환
signal scene_transition_requested(scene_path: String, spawn_point: String)
