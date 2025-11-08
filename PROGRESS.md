# Eodini Frontend - 개발 진행 상황

## 📅 프로젝트 타임라인

### 2025-11-07

---

## ✅ 완료된 작업

### 1차: Flutter 프로젝트 초기 셋업 (Commit: 5c2695e)

#### 프로젝트 구조
- ✅ `pubspec.yaml` 설정 (의존성 관리)
- ✅ `.gitignore` 설정
- ✅ `.env.example` 환경 변수 템플릿
- ✅ `analysis_options.yaml` 린트 규칙

#### Core 레이어 구현
- ✅ **API 클라이언트**
  - `api_client.dart` - Dio HTTP 클라이언트
  - `api_interceptor.dart` - 인증/로깅 인터셉터
  - `api_response.dart` - 표준 API 응답 모델

- ✅ **상수 정의**
  - `api_constants.dart` - API 엔드포인트
  - `app_constants.dart` - 앱 설정 상수

- ✅ **데이터 모델** (백엔드 Go 구조체 기반)
  - `vehicle.dart` - 차량 모델
  - `driver.dart` - 기사 모델
  - `passenger.dart` - 탑승자 모델
  - `route.dart` - 경로/정류장 모델
  - `trip.dart` - 운행 기록 모델
  - `schedule.dart` - 운행 일정 모델

#### 문서화
- ✅ `README.md` - 프로젝트 전체 가이드
- ✅ `docs/API_REFERENCE.md` - 백엔드 API 문서

#### 기술 스택
- Flutter 3.x + Dart 3.0+
- Riverpod (상태 관리)
- Dio (HTTP 클라이언트)
- freezed + json_serializable (불변 모델)
- Material Design 3

---

### 2차: 로그인/인증 기능 구현 (Commit: 9b94a8d)

#### 인증 시스템
- ✅ **데이터 모델**
  - `user.dart` - 사용자 모델
  - `LoginDto/Response` - 로그인
  - `RegisterDto` - 회원가입
  - `RefreshTokenDto/Response` - 토큰 갱신
  - `UserRole` enum (admin, driver, parent, attendant)

- ✅ **서비스 레이어**
  - `token_storage_service.dart` - JWT 토큰 암호화 저장 (flutter_secure_storage)
  - `auth_repository.dart` - 인증 API 통신 (로그인, 회원가입, 토큰 갱신)

- ✅ **상태 관리**
  - `auth_provider.dart` - Riverpod StateNotifier
  - 자동 로그인 기능
  - 토큰 자동 갱신 (401 에러 처리)

#### 라우팅 & 네비게이션
- ✅ `app_router.dart` - go_router 통합
- ✅ AuthGuard 구현 (인증 보호)
- ✅ 자동 리다이렉트 (로그인 ↔ 홈)

#### UI 화면
- ✅ **LoginScreen** - 로그인 화면
  - 이메일/비밀번호 입력
  - 폼 검증
  - 로딩 인디케이터
  - 에러 메시지 표시
  - 비밀번호 가시성 토글

- ✅ **RegisterScreen** - 회원가입 화면
  - 이름, 이메일, 전화번호, 역할, 주소 입력
  - 비밀번호 확인
  - 역할 선택 (드롭다운)
  - 자동 로그인

- ✅ **HomeScreen** - 홈 화면
  - 사용자 정보 표시
  - 프로필 아바타
  - 로그아웃 기능

#### 보안 기능
- ✅ JWT Bearer Token 인증
- ✅ flutter_secure_storage로 토큰 암호화
- ✅ AuthInterceptor로 자동 헤더 추가
- ✅ 토큰 자동 갱신

---

### 3차: 차량 관리 기능 구현 (Commit: 50414e1)

#### 데이터 레이어
- ✅ **VehicleRepository** (`vehicle_repository.dart`)
  - CRUD API 통신 (조회, 생성, 수정, 삭제)
  - 페이지네이션 지원
  - 검색 기능 (차량번호, 모델, 제조사)
  - 필터 기능 (상태, 차량 타입)
  - Mock 데이터 지원 (35개 차량)

- ✅ **VehicleProvider** (`vehicle_provider.dart`)
  - `VehicleListNotifier` - 목록 상태 관리
  - `VehicleNotifier` - 개별 차량 상태 관리
  - `VehicleActions` - CRUD 액션

#### UI 화면
- ✅ **VehiclesScreen** - 차량 목록 화면
  - 검색창 (차량번호, 모델명, 제조사)
  - 상태 필터 칩 (운행중, 정비중, 비활성)
  - 차량 타입 필터 칩 (버스, 승합차, 소형버스, 승용차)
  - 페이지네이션 (이전/다음 버튼, 페이지 정보)
  - Pull-to-refresh
  - 차량 카드 (아이콘, 상태 뱃지)

- ✅ **VehicleDetailScreen** - 차량 상세 화면
  - 기본 정보 (차량번호, 제조사, 모델, 연식, 색상, 정원)
  - 정비/보험 정보 (만료일 D-day 표시)
  - 만료 임박 경고 (30일 이내)
  - 시스템 정보 (등록일, 수정일)
  - 수정/삭제 액션

- ✅ **VehicleFormScreen** - 차량 추가/수정 화면
  - 폼 유효성 검사
  - 차량 타입별 기본 정원 자동 설정
  - 날짜 선택기 (보험/검사 만료일)
  - 수정 모드에서 차량번호 변경 불가
  - 상태 변경 (수정 모드만)

#### 라우팅
- ✅ `/vehicles` - 차량 목록
- ✅ `/vehicles/new` - 차량 추가
- ✅ `/vehicles/:id` - 차량 상세
- ✅ `/vehicles/:id/edit` - 차량 수정

#### 홈 화면 개선
- ✅ 사용자 정보 카드
- ✅ 주요 기능 그리드 (차량 관리, 탑승자 관리, 실시간 위치, 운행 관리)
- ✅ 차량 관리 기능으로 네비게이션

---

### 4차: 탑승자 관리 기능 구현 (Commit: 5fd4df9)

#### 데이터 레이어
- ✅ **PassengerRepository** (`passenger_repository.dart`)
  - CRUD API 통신 (조회, 생성, 수정, 삭제)
  - 페이지네이션 지원
  - 검색 기능 (이름, 보호자명, 연락처)
  - 필터 기능 (상태, 경로)
  - Mock 데이터 지원 (50명 탑승자)

- ✅ **PassengerProvider** (`passenger_provider.dart`)
  - `PassengerListNotifier` - 목록 상태 관리
  - `PassengerNotifier` - 개별 탑승자 상태 관리
  - `PassengerActions` - CRUD 액션

#### UI 화면
- ✅ **PassengersScreen** - 탑승자 목록 화면
  - 검색창 (이름, 보호자명, 연락처)
  - 상태 필터 칩 (활동중, 비활성)
  - 페이지네이션 (이전/다음 버튼, 페이지 정보)
  - Pull-to-refresh
  - 의료 특이사항 아이콘 표시
  - 탑승자 아바타 카드

- ✅ **PassengerDetailScreen** - 탑승자 상세 화면
  - 기본 정보 (이름, 나이, 성별, 주소, 배정 경로/정류장)
  - 보호자 정보 (이름, 연락처, 이메일, 관계)
  - 비상 연락처 정보 (별도 섹션)
  - 의료 특이사항 및 메모 (경고 표시)
  - 수정/삭제 액션

- ✅ **PassengerFormScreen** - 탑승자 추가/수정 화면
  - 폼 유효성 검사
  - 기본 정보 입력 섹션
  - 보호자 정보 입력 섹션 (필수)
  - 비상 연락처 입력 섹션 (선택)
  - 의료 특이사항 및 메모 섹션
  - 상태 변경 (수정 모드만)

#### 라우팅
- ✅ `/passengers` - 탑승자 목록
- ✅ `/passengers/new` - 탑승자 추가
- ✅ `/passengers/:id` - 탑승자 상세
- ✅ `/passengers/:id/edit` - 탑승자 수정

#### 홈 화면 개선
- ✅ 탑승자 관리 기능 네비게이션 활성화

---

### 5차: 운행 관리 기능 구현 (Commit: 5219b64)

#### 데이터 레이어
- ✅ **TripRepository** (`trip_repository.dart`)
  - CRUD API 통신 (조회, 시작, 완료, 취소)
  - 페이지네이션 지원
  - 필터 기능 (상태, 차량, 기사, 날짜)
  - 탑승자 탑승/하차 체크 API
  - Mock 데이터 지원 (30개 운행)

- ✅ **TripProvider** (`trip_provider.dart`)
  - `TripListNotifier` - 목록 상태 관리
  - `TripNotifier` - 개별 운행 상태 관리
  - `TripActions` - 운행 시작/완료/취소, 탑승/하차 액션

#### UI 화면
- ✅ **TripsScreen** - 운행 목록 화면
  - 상태 필터 칩 (대기중, 운행중, 완료, 취소)
  - 날짜별 운행 정보 카드
  - 차량/기사 정보 표시
  - 탑승자 현황 (총원, 탑승, 하차)
  - 페이지네이션

- ✅ **TripDetailScreen** - 운행 상세 화면
  - 기본 정보 (운행 ID, 차량, 기사, 동승자)
  - 운행 시간 정보 (시작/종료, 소요시간, 총거리)
  - 운행 액션 (시작/완료/취소)
  - 탑승자 목록 및 탑승/하차 체크
  - 실시간 상태 업데이트

#### 라우팅
- ✅ `/trips` - 운행 목록
- ✅ `/trips/:id` - 운행 상세

#### 홈 화면 개선
- ✅ 운행 관리 기능 네비게이션 활성화

---

### 6차: 실시간 지도 통합 (Commit: c5b76ba)

#### 의존성 추가
- ✅ **Google Maps Flutter** (`google_maps_flutter: ^2.5.0`)
  - 지도 UI 통합
  - 마커 및 폴리라인 지원

- ✅ **WebSocket Channel** (`web_socket_channel: ^2.4.0`)
  - 실시간 양방향 통신
  - 차량 위치 업데이트 수신

#### 데이터 레이어
- ✅ **WebSocketService** (`websocket_service.dart`)
  - WebSocket 연결 관리 (ws://localhost:8080/ws)
  - 실시간 차량 위치 업데이트 수신
  - 차량 상태 변경 이벤트 처리
  - 자동 재연결 로직 (최대 5회 시도)
  - 하트비트 메커니즘 (30초 간격)
  - Mock 모드 지원

- ✅ **RouteRepository** (`route_repository.dart`)
  - 경로 CRUD API 통신
  - 정류장 조회 기능
  - Mock 데이터 지원 (10개 경로, 각 4-6개 정류장)
  - 서울 주요 지역 좌표 (강남, 서초, 송파, 마포, 용산 등)

- ✅ **MapProvider** (`map_provider.dart`)
  - `MapNotifier` - 지도 상태 관리
  - 차량 위치 맵 관리 (vehicleId -> VehicleMapInfo)
  - 경로 및 정류장 데이터 관리
  - WebSocket 스트림 구독 및 실시간 업데이트
  - 차량/경로 선택 상태 관리

#### UI 화면
- ✅ **MapScreen** - 실시간 지도 화면
  - Google Maps 통합
  - 차량 마커 (상태별 색상 구분)
    - 녹색: 운행중 (active)
    - 주황색: 정비중 (maintenance)
    - 빨강색: 비활성 (inactive)
  - 경로 폴리라인 표시
  - 정류장 마커 (파란색)
  - 필터 버튼 (차량/경로/정류장 토글)
  - 하단 정보 패널
    - 선택된 차량 정보 (차량번호, 모델, 상태, 속도, 시간)
    - 선택된 경로 정보 (이름, 설명, 소요시간, 거리)
  - 실시간 위치 업데이트
  - 새로고침 및 위치 이동 기능

#### 라우팅
- ✅ `/map` - 실시간 지도

#### 홈 화면 개선
- ✅ 실시간 위치 기능 네비게이션 활성화

#### 주요 기능
- ✅ 실시간 차량 위치 추적 (HTTP Polling, 10-30초 간격)
- ✅ 경로 및 정류장 표시
- ✅ 차량 상태별 시각화
- ✅ 필터 기능 (차량/경로/정류장)
- ✅ 차량 선택 시 상세 정보 표시
- ✅ 경로 선택 시 정보 표시
- ✅ Mock API 모드 지원

---

### 7차: 실시간 위치 Polling 리팩토링 + 백엔드 문서화 (Commit: 47b672f)

#### 위치 업데이트 방식 변경
- ✅ **LocationService** (`location_service.dart`)
  - WebSocket → HTTP Polling 전환
  - 10-30초 간격으로 API 호출 (AppConstants.locationUpdateInterval)
  - Timer 기반 주기적 업데이트
  - 일괄 위치 업데이트 (Map<vehicleId, location>)
  - Polling 간격 변경 기능 (5-60초)
  - Mock 위치 데이터 생성

#### 기술 선택 이유
- **Polling이 더 적합한 이유:**
  - 10-30초 간격 업데이트에는 WebSocket이 과함
  - 구현 단순, 서버 리소스 절약
  - 네트워크 재연결 처리 쉬움
  - WebSocket은 1초 이하 실시간이 필요할 때 유용
- **WebSocket은 옵션으로 유지** (향후 긴급 이벤트용)

#### MapProvider 리팩토링
- `MapNotifier`에서 LocationService 사용
- 일괄 위치 업데이트 처리 최적화
- Polling 간격 동적 변경 기능

#### 백엔드 개발 요구사항 문서
- ✅ **BACKEND_REQUIREMENTS.md** 생성
  - 프론트엔드 진행률: 약 80% 완료
  - 백엔드보다 빠르게 진행됨에 따라 문서화

**문서 내용:**
- 우선순위별 API 목록 (P0~P3)
- 필수 API 상세 명세 (Request/Response)
- 데이터 모델 및 Enum 타입 정의
- 실시간 위치 API 요구사항 (Polling 방식)
- Kafka + FCM 알림 아키텍처 제안
- 보안/인증 요구사항 (JWT)
- 성능 요구사항 (응답시간, 동시접속)
- 개발 타임라인 (Week 1-4+)
- 에러 코드 정의

**주요 API 우선순위:**
- **P0 (즉시)**: 인증, 차량, 탑승자 CRUD
- **P1 (1주일)**: 운행 관리, 경로, **실시간 위치 API**
- **P2 (2주일)**: 기사, 일정
- **P3 (추후)**: 알림

**알림 시스템 제안:**
```
백엔드 → Kafka → 알림 Worker → FCM → Flutter 앱
```

---

### 8차: 기사 관리 기능 구현 (Commit: f1e0e17)

#### 데이터 레이어
- ✅ **DriverRepository** (`driver_repository.dart`)
  - CRUD API 통신 (조회, 생성, 수정, 삭제)
  - 페이지네이션 지원
  - 검색 기능 (이름, 전화번호, 이메일)
  - 상태 필터 (활동중, 휴가중, 비활성)
  - Mock 데이터 지원 (20명 기사)
  - 면허 만료일 시뮬레이션 (만료, 만료 임박, 여유)

- ✅ **DriverProvider** (`driver_provider.dart`)
  - `DriverListNotifier` - 목록 상태 관리
  - `DriverNotifier` - 개별 기사 상태 관리
  - `DriverActions` - CRUD 액션

#### UI 화면
- ✅ **DriversScreen** - 기사 목록 화면
  - 검색창 (이름, 전화번호, 이메일)
  - 상태 필터 칩 (활동중, 휴가중, 비활성)
  - 면허 만료일 경고 표시
    - 🔴 만료된 면허 (빨간색)
    - 🟠 30일 이내 만료 예정 (주황색)
  - 페이지네이션
  - Pull-to-refresh

- ✅ **DriverDetailScreen** - 기사 상세 화면
  - 기본 정보 (이름, 전화번호, 이메일, 주소)
  - 면허 정보 (면허번호, 면허 종류, 만료일)
  - 비상 연락처
  - 면허 만료 경고 배너 (만료/임박 시)
  - 수정/삭제 액션

- ✅ **DriverFormScreen** - 기사 추가/수정 화면
  - 폼 유효성 검사
  - 면허 종류 드롭다운 (1종 보통/대형, 2종 보통)
  - 면허 만료일 선택기
  - 수정 모드에서 면허번호 변경 불가
  - 상태 변경 (수정 모드만)

#### 라우팅
- ✅ `/drivers` - 기사 목록
- ✅ `/drivers/new` - 기사 추가
- ✅ `/drivers/:id` - 기사 상세
- ✅ `/drivers/:id/edit` - 기사 수정

#### 홈 화면 개선
- ✅ 기사 관리 기능 네비게이션 활성화 (5번째 카드)

---

### 9차: 경로 관리 기능 구현 (Commit: 93968ab)

#### 데이터 레이어
- ✅ **RouteRepository** - 이미 존재 (지도 기능에서 구현됨)
  - 10개 Mock 경로, 각 4-6개 정류장
  - 서울 주요 지역 좌표

- ✅ **RouteProvider** (`route_provider.dart`)
  - `RouteListNotifier` - 목록 상태 관리
  - `RouteNotifier` - 개별 경로 상태 관리
  - `RouteActions` - CRUD 액션
  - 클라이언트 사이드 검색 필터링

#### UI 화면
- ✅ **RoutesScreen** - 경로 목록 화면
  - 검색바 (경로명, 설명 검색)
  - 상태 필터 칩 (전체, 활성, 비활성)
  - 각 경로 카드 표시:
    - 정류장 개수
    - 거리 (km)
    - 예상 소요시간 (분)
  - 페이지네이션

- ✅ **RouteDetailScreen** - 경로 상세 화면
  - 기본 정보 (정류장 개수, 거리, 예상 소요시간)
  - 정류장 목록
    - 순서대로 번호 표시
    - 🟢 첫 정류장 "출발" 표시
    - 🔴 마지막 정류장 "도착" 표시
    - 좌표 정보
  - 수정/삭제 액션

#### 라우팅
- ✅ `/routes` - 경로 목록
- ✅ `/routes/:id` - 경로 상세

#### 홈 화면 개선
- ✅ 경로 관리 기능 네비게이션 활성화 (6번째 카드)

#### 버그 수정
- ✅ RouteModel 필드명 수정 (Commit: a78cdf9)
  - `stopCount` → `stops?.length`
  - `distance` → `totalDistance` (미터→km 변환)
  - `estimatedDuration` → `estimatedTime`
  - Stop 모델: `sequence` → `order`, `description` → `notes`
  - UpdateStopDto 추가

---

### 10차: 일정 관리 기능 구현 (Commit: 304afad)

#### 데이터 레이어
- ✅ **ScheduleRepository** (`schedule_repository.dart`)
  - CRUD API 통신 (생성, 조회, 수정, 삭제)
  - Mock 데이터 20개 생성
  - 필터링 지원 (상태, 시간대, 경로, 차량)
  - **시간대별 일정:**
    - 🌞 오전 (08:00) - 등교 노선
    - ☁️ 오후 (14:00) - 하교 노선
    - 🌙 저녁 (18:00) - 귀가 노선
  - **요일별 패턴:**
    - 평일 (월~금)
    - 주말 (토~일)
    - 특정 요일 (월/수/금, 화/목)
  - 유효기간 설정 (validFrom, validTo)

- ✅ **ScheduleProvider** (`schedule_provider.dart`)
  - `ScheduleListNotifier` - 목록 상태 관리
  - `ScheduleNotifier` - 개별 일정 상태 관리
  - `ScheduleActions` - CRUD 액션
  - 이중 필터 (상태 + 시간대)

#### UI 화면
- ✅ **SchedulesScreen** - 일정 목록 화면
  - 검색바 (일정명, 설명 검색)
  - **이중 필터:**
    - 상태: 전체/활성/비활성
    - 시간대: 전체/오전/오후/저녁
  - 각 일정 카드 표시:
    - 시간대 아이콘 및 색상 구분
    - 출발 시간 (큰 글씨)
    - 운행 요일 (평일/주말/특정요일)
    - 경로/차량 정보
  - 페이지네이션

- ✅ **ScheduleDetailScreen** - 일정 상세 화면
  - **기본 정보:** 출발 시간, 운행 요일
  - **운행 정보:** 경로, 차량, 기사, 동승자
  - **유효기간 정보:**
    - 시작일/종료일
    - 유효/만료 상태 표시
    - 마지막 업데이트
  - 수정/삭제 액션

#### 라우팅
- ✅ `/schedules` - 일정 목록
- ✅ `/schedules/:id` - 일정 상세

#### 홈 화면 개선
- ✅ 일정 관리 기능 네비게이션 활성화 (7번째 카드)

---

### 버그 수정 (2025-11-08)

#### vehicleRepositoryProvider 누락 (Commit: 72da201, db8756b)
- ✅ `vehicle_repository.dart`에 Provider 추가
- ✅ 필수 import 추가 (flutter_riverpod, api_response, api_constants)
- ✅ map_provider.dart와 location_service.dart에서 사용되는 provider 수정

#### Google Maps 웹 지원 (Commit: e5bcfcc)
- ✅ `web/index.html`에 Google Maps JavaScript API 스크립트 추가
- ✅ 실시간 위치 화면 오류 수정: `Cannot read properties of undefined (reading 'maps')`

#### DateFormat 로케일 오류 (Commit: 17dd4c4)
- ✅ `trips_screen.dart`: 한국어 로케일('ko_KR') 제거
- ✅ `trip_detail_screen.dart`: 한국어 로케일('ko_KR') 제거
- ✅ 운행 관리 화면 오류 수정: `LocaleDataException`

---

### 11차: 역할 기반 UI 분리 - 회원가입 프로세스 개선 (2025-11-08)

#### 데이터 모델 업데이트
- ✅ **User 모델 확장** (`lib/core/models/user.dart`)
  - `UserRole` enum에 `passenger` 추가 (일반 탑승자)
  - `UserType` enum 추가 (회원가입 시 선택: parent, passenger, driver)
  - `isPublic` 필드 추가 (공개/비공개 설정)
  - `passengerId` 필드 추가 (탑승자 연결)
  - `driverId` 필드 추가 (운전자 연결)

- ✅ **회원가입 DTO 추가**
  - `ParentRegisterDto` - 보호자 회원가입 (아동 정보 포함)
  - `PassengerRegisterDto` - 일반 회원(성인 탑승자) 회원가입
  - `DriverRegisterDto` - 운전자 회원가입 (면허 정보 포함)

#### 회원가입 화면 구현
- ✅ **UserTypeSelectionScreen** - 회원 타입 선택 화면
  - 3가지 회원 유형 카드 (보호자, 일반 회원, 운전자)
  - 각 유형별 설명 및 아이콘
  - 로그인 페이지로 돌아가기 링크

- ✅ **ParentRegisterScreen** - 보호자 회원가입 (3단계)
  - **1단계**: 보호자 본인 정보 (이메일, 비밀번호, 이름, 전화번호, 주소)
  - **2단계**: 자녀 정보 (이름, 출생년도, 성별, 보호자 관계, 비상 연락처, 의료 특이사항)
  - **3단계**: 공개/비공개 설정 및 약관 동의
  - 진행 상태 표시 (Progress Indicator)
  - 단계별 유효성 검사

- ✅ **PassengerRegisterScreen** - 일반 회원 회원가입 (2단계)
  - **1단계**: 기본 정보 (이메일, 비밀번호, 이름, 전화번호, 주소, 출생년도, 성별)
  - **2단계**: 추가 정보 & 설정 (비상 연락처, 의료 특이사항, 공개/비공개 설정)
  - 간소화된 회원가입 프로세스

- ✅ **DriverRegisterScreen** - 운전자 회원가입 (3단계)
  - **1단계**: 기본 정보 (이메일, 비밀번호, 이름, 전화번호, 주소)
  - **2단계**: 면허 정보 (면허번호, 면허 종류, 만료일, 비상 연락처)
  - **3단계**: 공개/비공개 설정 및 약관 동의
  - 관리자 승인 필요 안내

#### 공개/비공개 설정 기능
- ✅ **개인정보 공개 설정**
  - 공개 시: 같은 경로의 사용자끼리 연락 가능
  - 비공개 시: 관리자와 운전자만 정보 확인 가능
  - 이메일은 항상 비공개
  - 면허 정보는 항상 비공개 (운전자의 경우)

#### 라우팅 업데이트
- ✅ **app_router.dart** 수정
  - `/register/select` - 회원 타입 선택
  - `/register/parent` - 보호자 회원가입
  - `/register/passenger` - 일반 회원 회원가입
  - `/register/driver` - 운전자 회원가입
  - redirect 로직 업데이트 (새 회원가입 경로 포함)

#### 기존 화면 수정
- ✅ **LoginScreen** 업데이트
  - go_router 사용으로 변경
  - 회원가입 버튼 → 회원 타입 선택 화면으로 이동 (`/register/select`)

#### 주요 기능
- ✅ 역할별 회원가입 플로우 분리
- ✅ 공개/비공개 설정 (개인정보 보호)
- ✅ 단계별 회원가입 프로세스 (UX 개선)
- ✅ 진행 상태 표시
- ✅ 폼 유효성 검사
- ✅ 비밀번호 가시성 토글
- ✅ 약관 동의 안내

#### 다음 단계
- [ ] 백엔드 API 연동 (회원가입 DTO 처리)
- [ ] 역할별 홈 화면 구현
- [ ] 권한 기반 접근 제어 (RBAC)
- [ ] 코드 생성 (build_runner) 실행 필요

---

## 🚧 진행 중인 작업

없음

---

## 📋 다음 단계 (우선순위순)

### 1. 역할 기반 UI 분리 👥
**우선순위: 높음**

현재는 관리자 관점의 화면만 구현되어 있음. 사용자 역할에 따라 UI와 기능을 분리해야 함.

#### 1.1 회원가입 프로세스 개선
- [x] 회원 타입 선택 화면 추가
  - **보호자 회원가입**: 아동(탑승자) 정보 등록
  - **일반 회원가입**: 본인(성인) 정보 등록

- [x] 보호자 회원가입 플로우
  - [x] 보호자 본인 정보 입력 (이름, 연락처, 이메일, 주소)
  - [x] 아동 정보 입력 (이름, 출생년도, 성별)
  - [x] 공개/비공개 설정 (개인정보 공개 여부)
  - [ ] 가입 완료 후 자동 탑승자(passenger) 등록 (백엔드 API 필요)

- [x] 일반 회원가입 플로우 (성인 본인)
  - [x] 본인 정보 입력
  - [x] 공개/비공개 설정
  - [ ] 가입 완료 후 자동 탑승자(passenger) 등록 (백엔드 API 필요)

- [x] 운전자 회원가입 플로우
  - [x] 본인 정보 입력
  - [x] 면허 정보 입력
  - [x] 공개/비공개 설정
  - [ ] 관리자 승인 프로세스 (백엔드 API 필요)

#### 1.2 역할별 홈 화면 구성

**관리자 (Admin)**
- [x] 현재 구현된 모든 관리 기능
  - 차량, 탑승자, 기사, 경로, 일정, 운행, 실시간 위치

**학부모 (Parent)**
- [ ] 자녀 정보 조회
- [ ] 자녀의 운행 일정 조회
- [ ] 자녀의 실시간 위치 추적 (배정된 차량)
- [ ] 자녀의 탑승/하차 기록 조회
- [ ] 알림 설정 (탑승/하차 알림)
- [ ] 자녀 정보 수정 (제한적)

**일반 회원 (성인 탑승자)**
- [ ] 본인 정보 조회
- [ ] 본인의 운행 일정 조회
- [ ] 본인의 실시간 위치 추적 (배정된 차량)
- [ ] 본인의 탑승/하차 기록 조회
- [ ] 알림 설정
- [ ] 본인 정보 수정 (제한적)

**운전기사 (Driver)**
- [ ] 본인에게 배정된 운행 목록 조회
- [ ] 운행 시작/종료
- [ ] 탑승자 탑승/하차 체크
- [ ] 배정된 경로 및 정류장 정보 조회
- [ ] 본인 정보 조회/수정 (제한적)
- [ ] 오늘의 운행 일정

**동승자 (Attendant)**
- [ ] 배정된 운행 목록 조회
- [ ] 탑승자 탑승/하차 체크 지원
- [ ] 배정된 경로 정보 조회
- [ ] 본인 정보 조회

#### 1.3 권한 관리
- [ ] Role-Based Access Control (RBAC) 구현
- [ ] 각 화면별 권한 체크
- [ ] 라우터 가드 개선 (역할별 접근 제어)
- [ ] API 호출 시 권한 검증

#### 1.4 데이터 필터링
- [ ] 학부모: 자녀 데이터만 조회
- [ ] 일반 회원: 본인 데이터만 조회
- [ ] 기사: 본인 배정 데이터만 조회
- [ ] 관리자: 모든 데이터 조회

#### 1.5 개인정보 보호
- [x] 공개/비공개 설정 기능 (UI 완료)
- [ ] 민감 정보 마스킹 (전화번호, 주소 등) - 백엔드 구현 필요
- [ ] 정보 조회 권한 관리 - 백엔드 구현 필요

---

### 2. 알림 기능 🔔
**우선순위: 중간**

- [ ] FCM 통합 (Firebase Cloud Messaging)
- [ ] 푸시 알림
- [ ] 앱 내 알림
- [ ] 알림 설정
- [ ] 역할별 알림 타입
  - 학부모: 자녀 탑승/하차 알림
  - 일반 회원: 본인 탑승/하차 알림
  - 기사: 운행 시작 알림, 긴급 알림
  - 관리자: 시스템 알림

---

### 3. 추가 기능
**우선순위: 낮음**

- [ ] 다크모드 전환 스위치
- [ ] 프로필 편집
- [ ] 비밀번호 변경
- [ ] 언어 설정 (다국어)
- [ ] 오프라인 모드
- [ ] 캐싱 전략

---

## 🐛 알려진 이슈

없음

---

## 📝 메모

### 코드 생성 필수!
모든 모델 파일을 수정하거나 추가한 후에는 반드시 실행:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 환경 변수
- `.env` 파일 생성 필수
- 백엔드 URL 설정: `API_BASE_URL`
- 에뮬레이터별 localhost 주소 다름

### API 의존성
- 모든 기능은 백엔드 API가 구현되어야 작동
- 백엔드 저장소: https://github.com/ressKim-io/eodini

---

## 🎯 단기 목표 (1주일)

1. ✅ 프로젝트 초기 셋업
2. ✅ 인증 기능 구현
3. ✅ 차량 관리 기능 구현
4. ✅ 탑승자 관리 기능 구현
5. ✅ 운행 관리 기능 구현
6. ✅ 실시간 지도 통합
7. ✅ 기사 관리 기능 구현
8. ✅ 경로 관리 기능 구현
9. ✅ 일정 관리 기능 구현

---

## 🏆 중기 목표 (1개월)

1. ✅ 차량, 탑승자, 운행 관리 완성
2. ✅ 실시간 위치 추적 구현
3. ✅ 기사 관리 기능 구현
4. ✅ 경로 관리 기능 구현
5. ✅ 일정 관리 기능 구현
6. ✅ **핵심 기능 완성** (인증, 차량, 탑승자, 기사, 경로, 운행, 일정, 실시간 지도)
7. 🎯 알림 시스템 구현 (다음 단계)
8. 테스트 코드 작성
9. 성능 최적화

---

## 📚 참고 자료

- [Flutter 공식 문서](https://flutter.dev/docs)
- [Riverpod 가이드](https://riverpod.dev/)
- [go_router 문서](https://pub.dev/packages/go_router)
- [Dio 문서](https://pub.dev/packages/dio)
- [Material Design 3](https://m3.material.io/)

---

## 🤝 기여자

- Claude AI - 초기 개발

---

**마지막 업데이트**: 2025-11-08

## 📊 현재 진행률

### 완성된 화면 (100%)
1. ✅ 로그인/회원가입
2. ✅ 홈 화면 (7개 기능 카드)
3. ✅ 차량 관리 (목록/상세/추가/수정)
4. ✅ 탑승자 관리 (목록/상세/추가/수정)
5. ✅ 기사 관리 (목록/상세/추가/수정)
6. ✅ 경로 관리 (목록/상세)
7. ✅ 일정 관리 (목록/상세)
8. ✅ 운행 관리 (목록/상세)
9. ✅ 실시간 위치 추적 (Google Maps)

### Mock 데이터 현황
- 차량: 35개
- 탑승자: 50명
- 기사: 20명
- 경로: 10개 (각 4-6개 정류장)
- 일정: 20개
- 운행: 30개

### 주요 기능
- ✅ JWT 인증 (자동 로그인, 토큰 갱신)
- ✅ CRUD 완전 구현 (모든 엔티티)
- ✅ 검색 및 필터링
- ✅ 페이지네이션
- ✅ 실시간 위치 업데이트 (HTTP Polling)
- ✅ 상태 관리 (Riverpod)
- ✅ 라우팅 (go_router)

### 다음 단계
- 🎯 FCM 푸시 알림
- 🎯 테스트 코드 작성
- 🎯 성능 최적화
