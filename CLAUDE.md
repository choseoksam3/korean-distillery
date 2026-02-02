# 한국의 증류소 (Korean Distillery)

위스키 증류소 경영 시뮬레이션 게임. Godot 4.3+, GDScript, 2D 픽셀아트 (16x16 타일).

## 게임 컨셉

한국의 지역에서 보리를 재배/구매하고, 위스키를 증류하고, 오크통에서 숙성하고, 바(Bar)에서 손님에게 서빙하며 증류소를 성장시키는 경영 시뮬레이션.

- 레퍼런스: 데이브 더 다이버 (낮-밤 이중 루프) + 스타듀밸리 (농사, 계절, 마을) + 흑백요리사 (대회)
- 시점: 탑다운 2D
- 아트: 픽셀아트 16x16 타일

## 핵심 게임 루프

```
오전(재료 확보) → 오후(증류소 작업) → 저녁(바 운영) → 밤(정산/숙성 경과)
```

- 하루 사이클이 핵심. 각 시간대에 할 수 있는 행동이 다름.
- 게임 내 1일 = 위스키 숙성 1개월

## 위스키 제조 파이프라인

보리 → 몰팅(싹 틔우기) → 매싱(당분 추출) → 발효(효모) → 증류(Pot Still) → 숙성(오크통) → 블렌딩 → 병입/판매

각 단계에서 플레이어의 선택이 최종 위스키 풍미 프로필에 영향:
- 이탄 사용량 → 스모키향 강도
- 효모 종류 → 과일향/꽃향
- 증류 컷 포인트 → 순도/캐릭터
- 오크통 종류 → 바닐라/캐러멜/셰리
- 숙성 연수 → 깊이/가치

## 한국 지역 시스템

게임 시작 시 지역 선택. 각 지역은 기후, 수원, 특산물이 달라 위스키 캐릭터가 달라짐:

| 지역 | 기후 특성 | 보너스 | 패널티 |
|------|----------|--------|--------|
| 강원도 횡성 | 한랭, 청정 수원 | 증발량 -30%, 물 품질↑ | 보리 재배 시즌 짧음, 물류비↑ |
| 부산 기장 | 온난 해양성, 항구 | 수입 재료 -40%, 이탄 채집 가능 | 증발량 +20%, 곰팡이 리스크 |
| 전남 영광 | 온난, 비옥 토양 | 보리 성장 +50%, 수확량 +30% | 채집 포인트 적음, 이탄 없음 |
| 대구 팔공산 | 고온 분지 | 숙성 속도 2배, 바 매출↑ | 증발량 +50%, 품질 변동 |
| 제주도 | 아열대, 화산 | 물 품질 최상, 보태니컬 가능 | 물류비 최고, 태풍 리스크 |

## 기술 설정

- 엔진: Godot 4.3+
- 언어: GDScript
- 해상도: 320x180 (게임), 1280x720 (윈도우) — 4배 스케일링
- 타일: 16x16 픽셀
- 스트레치 모드: canvas_items
- 스트레치 어스펙트: keep

## 프로젝트 구조

```
korean-distillery/
├── project.godot
├── CLAUDE.md
├── scenes/
│   ├── main.tscn                # 메인 씬 (씬 전환 관리)
│   ├── ui/                      # UI 씬들
│   │   ├── hud.tscn
│   │   ├── inventory_ui.tscn
│   │   └── day_summary.tscn
│   ├── world/                   # 월드 맵 씬들
│   │   ├── distillery.tscn      # 증류소 내부
│   │   ├── bar.tscn             # 바 내부
│   │   ├── farm.tscn            # 보리밭
│   │   └── market.tscn          # 시장
│   ├── characters/
│   │   ├── player.tscn
│   │   └── customer.tscn
│   └── minigames/
│       ├── distilling.tscn      # 증류 미니게임
│       └── serving.tscn         # 서빙 미니게임
├── scripts/
│   ├── autoload/                # 싱글톤 (Autoload)
│   │   ├── game_manager.gd      # 날짜, 시간대, 게임 상태
│   │   ├── signal_bus.gd        # 전역 시그널 허브
│   │   ├── inventory.gd         # 인벤토리 (재료, 위스키)
│   │   └── economy.gd           # 돈, 가격, 거래
│   ├── player/
│   │   └── player.gd            # 플레이어 이동, 인터랙션
│   ├── brewing/                 # 위스키 제조 관련
│   │   ├── recipe.gd            # 레시피 데이터
│   │   ├── barrel.gd            # 오크통 (숙성 관리)
│   │   ├── still.gd             # Pot Still (증류)
│   │   └── whisky.gd            # 위스키 데이터 클래스
│   ├── bar/                     # 바 운영 관련
│   │   ├── customer.gd          # 손님 NPC
│   │   └── serving.gd           # 서빙 시스템
│   └── world/
│       └── interactable.gd      # 인터랙션 가능 오브젝트 베이스
├── data/                        # JSON 데이터 파일
│   ├── recipes.json             # 위스키 레시피
│   ├── items.json               # 아이템 정의
│   ├── regions.json             # 지역 데이터
│   └── customers.json           # 손님 타입
├── assets/
│   ├── sprites/                 # 스프라이트 이미지
│   │   ├── player/
│   │   ├── tiles/
│   │   ├── objects/
│   │   ├── ui/
│   │   └── characters/
│   ├── audio/
│   │   ├── sfx/
│   │   └── bgm/
│   └── fonts/
└── resources/                   # Godot Resource 파일 (.tres)
    ├── items/
    └── themes/
```

## 아키텍처 패턴

### Autoload (싱글톤)
전역으로 접근 필요한 매니저는 Autoload로 등록:
- `GameManager` — 날짜, 시간대(오전/오후/저녁/밤), 게임 상태
- `SignalBus` — 전역 시그널 허브. 컴포넌트 간 느슨한 결합
- `Inventory` — 재료, 완성 위스키, 돈 관리
- `Economy` — 가격, 거래, 시장 변동

### Signal 기반 통신
노드 간 직접 참조 최소화. SignalBus를 통해 이벤트 전달:
```gdscript
# SignalBus.gd
signal day_changed(day: int)
signal time_phase_changed(phase: String)  # "morning", "afternoon", "evening", "night"
signal money_changed(amount: int)
signal item_added(item_id: String, quantity: int)
signal whisky_completed(whisky: WhiskyData)
signal customer_served(satisfaction: float)
```

### State Machine
NPC, 게임 상태, 제조 공정 등에 State Machine 패턴 사용:
```gdscript
enum State { IDLE, WALKING, INTERACTING, WORKING }
var current_state: State = State.IDLE

func _physics_process(delta):
    match current_state:
        State.IDLE: _idle_state(delta)
        State.WALKING: _walking_state(delta)
        # ...
```

### Resource 기반 데이터
아이템, 레시피 등 데이터는 Godot Resource로 정의:
```gdscript
# whisky.gd
class_name WhiskyData
extends Resource

@export var name: String
@export var age_months: int          # 숙성 개월 수
@export var flavor_profile: Dictionary  # {"smoky": 30, "sweet": 50, ...}
@export var quality: float            # 0.0 ~ 1.0
@export var base_price: int
```

## 코딩 컨벤션

- 변수/함수: `snake_case`
- 클래스: `PascalCase`
- 상수: `UPPER_SNAKE_CASE`
- 시그널: `snake_case` (과거형 또는 현재형, ex: `day_changed`, `item_added`)
- 파일명: `snake_case.gd`, `snake_case.tscn`
- 주석: 한국어 OK (개인 프로젝트)
- 타입 힌트: 가능하면 항상 사용 (`var speed: float = 80.0`)
- `@export`: 에디터에서 조정할 값에 사용
- `@onready`: `_ready()`에서 노드 참조 시 사용

## 현재 개발 Phase

### Phase 0: 기본 세팅 (현재)
- [x] 프로젝트 생성
- [ ] 프로젝트 설정 (해상도, 스트레치 등)
- [ ] 플레이어 캐릭터 (이동, 애니메이션)
- [ ] 증류소 내부 타일맵
- [ ] 씬 전환 (증류소 ↔ 외부)
- [ ] 카메라 팔로우

### Phase 1: 위스키 제조 시스템 (다음)
- [ ] 인벤토리 시스템
- [ ] 제조 파이프라인 (매싱 → 발효 → 증류)
- [ ] 증류 미니게임
- [ ] 숙성 시스템 (오크통)
- [ ] 병입 & 위스키 완성

### Phase 2: 바 운영 (그 다음)
- [ ] 바 씬 + 손님 NPC
- [ ] 주문 & 서빙 시스템
- [ ] 만족도 & 매출
- [ ] 하루 사이클 완성
- [ ] 돈 & 경제 시스템

## 자주 사용하는 명령어

```bash
# Godot 프로젝트 실행 (에디터 없이)
godot --path . --debug

# GDScript 문법 검증
godot --path . --check-only --script scripts/player/player.gd --headless --quit

# 웹 빌드 (나중에)
godot --path . --export-release "Web" builds/web/index.html
```

## 주의사항

- .tscn/.tres 파일은 Godot의 직렬화 포맷. GDScript 문법과 다름
- .tscn에서는 preload() 사용 불가 → ExtResource("id") 사용
- TileMap은 에디터에서 편집하는 게 효율적 (코드로 생성 복잡)
- @export 변수는 에디터에서 값 설정 가능
- Autoload 등록은 Project Settings > Autoload에서 수동으로 해야 함
