# 백엔드 개발 요구사항

**작성일**: 2025-11-07
**프론트엔드 진행률**: 약 80% 완료
**목적**: 프론트엔드가 백엔드보다 빠르게 진행됨에 따라 필요한 API 명세를 정리

---

## 📋 목차

1. [개요](#개요)
2. [우선순위별 API 목록](#우선순위별-api-목록)
3. [필수 API 상세 명세](#필수-api-상세-명세)
4. [데이터 모델 요구사항](#데이터-모델-요구사항)
5. [실시간 기능 요구사항](#실시간-기능-요구사항)
6. [보안 및 인증](#보안-및-인증)
7. [알림 시스템 (Kafka + FCM)](#알림-시스템)
8. [성능 요구사항](#성능-요구사항)

---

## 개요

### 프론트엔드 현재 상태
- ✅ 인증 (로그인/회원가입) UI 완료
- ✅ 차량 관리 CRUD UI 완료
- ✅ 탑승자 관리 CRUD UI 완료
- ✅ 운행 관리 UI 완료
- ✅ 실시간 지도 UI 완료
- ⏳ Mock API 사용 중 → 실제 백엔드 연동 필요

### 기술 스택
- **프론트엔드**: Flutter 3.x, Dart 3.0+, Riverpod
- **HTTP 클라이언트**: Dio 5.4+
- **예상 백엔드**: Go (Gin/Echo), PostgreSQL
- **실시간**: HTTP Polling (10-30초 간격) - WebSocket은 선택사항
- **알림**: Kafka + FCM 예정

---

## 우선순위별 API 목록

### 🔴 최우선 (P0) - 즉시 필요

#### 1. 인증 API
- `POST /api/v1/auth/login` - 로그인
- `POST /api/v1/auth/register` - 회원가입
- `POST /api/v1/auth/refresh` - 토큰 갱신
- `GET /api/v1/auth/me` - 현재 사용자 정보

#### 2. 차량 관리 API
- `GET /api/v1/vehicles` - 차량 목록 (페이지네이션, 필터)
- `GET /api/v1/vehicles/:id` - 차량 상세
- `POST /api/v1/vehicles` - 차량 등록
- `PUT /api/v1/vehicles/:id` - 차량 수정
- `DELETE /api/v1/vehicles/:id` - 차량 삭제

#### 3. 탑승자 관리 API
- `GET /api/v1/passengers` - 탑승자 목록
- `GET /api/v1/passengers/:id` - 탑승자 상세
- `POST /api/v1/passengers` - 탑승자 등록
- `PUT /api/v1/passengers/:id` - 탑승자 수정
- `DELETE /api/v1/passengers/:id` - 탑승자 삭제

### 🟡 높음 (P1) - 1주일 내 필요

#### 4. 운행 관리 API
- `GET /api/v1/trips` - 운행 목록
- `GET /api/v1/trips/:id` - 운행 상세
- `POST /api/v1/trips/:id/start` - 운행 시작
- `POST /api/v1/trips/:id/complete` - 운행 완료
- `POST /api/v1/trips/:id/cancel` - 운행 취소
- `POST /api/v1/trips/:id/passengers/:passenger_id/board` - 탑승 체크
- `POST /api/v1/trips/:id/passengers/:passenger_id/alight` - 하차 체크

#### 5. 경로 관리 API
- `GET /api/v1/routes` - 경로 목록
- `GET /api/v1/routes/:id` - 경로 상세
- `GET /api/v1/routes/:id/stops` - 경로별 정류장 목록
- `POST /api/v1/routes` - 경로 생성
- `PUT /api/v1/routes/:id` - 경로 수정

#### 6. **실시간 위치 API** (중요!)
- `GET /api/v1/locations` - 모든 차량 위치 조회 (10-30초마다 호출)
- `GET /api/v1/vehicles/:id/location` - 특정 차량 위치
- `POST /api/v1/vehicles/:id/location` - 위치 업데이트 (드라이버 앱에서)

### 🟢 중간 (P2) - 2주일 내 필요

#### 7. 기사 관리 API
- `GET /api/v1/drivers` - 기사 목록
- `GET /api/v1/drivers/:id` - 기사 상세
- `POST /api/v1/drivers` - 기사 등록
- `PUT /api/v1/drivers/:id` - 기사 수정

#### 8. 일정 관리 API
- `GET /api/v1/schedules` - 일정 목록
- `POST /api/v1/schedules` - 일정 생성

### ⚪ 낮음 (P3) - 추후 구현

#### 9. 알림 API
- `GET /api/v1/notifications` - 알림 목록
- `PUT /api/v1/notifications/:id/read` - 알림 읽음 처리

---

## 필수 API 상세 명세

### 1. 인증 API

#### `POST /api/v1/auth/login`

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "로그인 성공",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "홍길동",
      "role": "driver",  // admin, driver, parent, attendant
      "phone": "010-1234-5678",
      "address": "서울시 강남구...",
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  }
}
```

**Error (401):**
```json
{
  "success": false,
  "message": "이메일 또는 비밀번호가 올바르지 않습니다",
  "error_code": "AUTH_001"
}
```

#### `POST /api/v1/auth/register`

**Request:**
```json
{
  "email": "newuser@example.com",
  "password": "password123",
  "name": "김철수",
  "phone": "010-9876-5432",
  "role": "parent",
  "address": "서울시 서초구..."
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "회원가입 성공",
  "data": {
    "access_token": "...",
    "refresh_token": "...",
    "user": { /* 사용자 정보 */ }
  }
}
```

#### `POST /api/v1/auth/refresh`

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "new_access_token...",
    "refresh_token": "new_refresh_token..."
  }
}
```

---

### 2. 차량 관리 API

#### `GET /api/v1/vehicles`

**Query Parameters:**
- `page` (int, default: 1) - 페이지 번호
- `page_size` (int, default: 20, max: 100) - 페이지 크기
- `status` (string, optional) - 상태 필터: `active`, `maintenance`, `inactive`
- `vehicle_type` (string, optional) - 타입 필터: `van`, `bus`, `mini_bus`, `sedan`
- `search` (string, optional) - 검색어 (차량번호, 모델, 제조사)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "plate_number": "12가3456",
      "model": "그랜드스타렉스",
      "manufacturer": "현대",
      "vehicle_type": "van",  // van, bus, mini_bus, sedan
      "capacity": 12,
      "year": 2023,
      "color": "흰색",
      "status": "active",  // active, maintenance, inactive
      "insurance_expiry": "2025-12-31T00:00:00Z",
      "inspection_expiry": "2025-06-30T00:00:00Z",
      "last_maintenance_at": "2025-01-15T10:00:00Z",
      "notes": "정기 점검 필요",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2025-01-15T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total_items": 50,
    "total_pages": 3
  }
}
```

#### `POST /api/v1/vehicles`

**Request:**
```json
{
  "plate_number": "12가3456",
  "model": "그랜드스타렉스",
  "manufacturer": "현대",
  "vehicle_type": "van",
  "capacity": 12,
  "year": 2023,
  "color": "흰색",
  "insurance_expiry": "2025-12-31",
  "inspection_expiry": "2025-06-30"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "차량이 등록되었습니다",
  "data": { /* 생성된 차량 정보 */ }
}
```

**Error (409) - 중복:**
```json
{
  "success": false,
  "message": "이미 등록된 차량번호입니다",
  "error_code": "DUPLICATE_001"
}
```

---

### 3. 탑승자 관리 API

#### `GET /api/v1/passengers`

**Query Parameters:**
- `page`, `page_size` - 페이지네이션
- `status` - 상태 필터: `active`, `inactive`
- `route_id` - 경로별 필터
- `search` - 검색어 (이름, 보호자명, 연락처)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "홍길동",
      "age": 7,
      "gender": "male",
      "address": "서울시 강남구...",
      "status": "active",
      "assigned_route_id": "route-uuid",
      "assigned_stop_id": "stop-uuid",
      "stop_order": 3,
      "guardian_name": "홍아빠",
      "guardian_phone": "010-1111-2222",
      "guardian_email": "parent@example.com",
      "guardian_relation": "부",
      "emergency_contact": "010-3333-4444",
      "emergency_relation": "모",
      "medical_notes": "알레르기: 땅콩",
      "notes": "조용한 성격",
      "created_at": "2024-03-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  ],
  "pagination": { /* ... */ }
}
```

---

### 4. 운행 관리 API

#### `GET /api/v1/trips`

**Query Parameters:**
- `page`, `page_size`
- `status` - `pending`, `in_progress`, `completed`, `cancelled`
- `vehicle_id` - 차량별 필터
- `driver_id` - 기사별 필터
- `date` - 날짜 필터 (YYYY-MM-DD)
- `start_date`, `end_date` - 기간 필터

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "schedule_id": "schedule-uuid",
      "date": "2025-11-07",
      "status": "in_progress",  // pending, in_progress, completed, cancelled
      "vehicle_id": "vehicle-uuid",
      "assigned_driver_id": "driver-uuid",
      "assigned_attendant_id": "attendant-uuid",
      "started_at": "2025-11-07T08:00:00Z",
      "started_by": "driver:uuid",
      "completed_at": null,
      "cancelled_at": null,
      "cancel_reason": null,
      "actual_start_location": {
        "latitude": 37.5665,
        "longitude": 126.9780,
        "timestamp": "2025-11-07T08:00:00Z"
      },
      "actual_end_location": null,
      "total_distance": 0,
      "trip_passengers": [
        {
          "id": "tp-uuid",
          "trip_id": "uuid",
          "passenger_id": "passenger-uuid",
          "stop_id": "stop-uuid",
          "is_boarded": true,
          "is_alighted": false,
          "boarded_at": "2025-11-07T08:05:00Z",
          "alighted_at": null,
          "boarded_location": {
            "latitude": 37.5665,
            "longitude": 126.9780
          },
          "alighted_location": null
        }
      ],
      "created_at": "2025-11-06T00:00:00Z",
      "updated_at": "2025-11-07T08:05:00Z"
    }
  ],
  "pagination": { /* ... */ }
}
```

#### `POST /api/v1/trips/:id/start`

**Request:**
```json
{
  "started_by": "driver:uuid",
  "location": {
    "latitude": 37.5665,
    "longitude": 126.9780,
    "timestamp": "2025-11-07T08:00:00Z"
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "운행이 시작되었습니다",
  "data": { /* 업데이트된 운행 정보 */ }
}
```

#### `POST /api/v1/trips/:trip_id/passengers/:passenger_id/board`

**Request:**
```json
{
  "location": {
    "latitude": 37.5665,
    "longitude": 126.9780
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "탑승 처리되었습니다",
  "data": {
    "trip_passenger": { /* 업데이트된 탑승자 정보 */ }
  }
}
```

---

### 5. 실시간 위치 API ⭐ 중요!

#### `GET /api/v1/locations`

**프론트엔드에서 10-30초마다 Polling으로 호출합니다.**

**Query Parameters:**
- `vehicle_ids` (optional) - 콤마로 구분된 차량 ID 목록
- `status` (optional) - 운행중인 차량만: `active`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "vehicle_id": "uuid",
      "latitude": 37.5665,
      "longitude": 126.9780,
      "timestamp": "2025-11-07T08:00:00Z",
      "speed": 45.5,  // km/h
      "heading": 90.0  // 방향 (0-360도)
    }
  ]
}
```

#### `POST /api/v1/vehicles/:id/location`

**드라이버 앱에서 GPS 위치를 전송합니다 (5-10초마다).**

**Request:**
```json
{
  "latitude": 37.5665,
  "longitude": 126.9780,
  "speed": 45.5,
  "heading": 90.0,
  "timestamp": "2025-11-07T08:00:00Z"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "위치가 업데이트되었습니다"
}
```

---

### 6. 경로 관리 API

#### `GET /api/v1/routes`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "A코스",
      "description": "오전 등원 A코스",
      "status": "active",
      "estimated_time": 45,  // 분
      "total_distance": 15000,  // 미터
      "stops": [
        {
          "id": "stop-uuid",
          "route_id": "uuid",
          "name": "OO아파트 정문",
          "address": "서울시 강남구...",
          "order": 1,
          "latitude": 37.5665,
          "longitude": 126.9780,
          "estimated_arrival_time": 5,  // 출발 후 5분
          "notes": "정문 앞 대기",
          "created_at": "2024-01-01T00:00:00Z",
          "updated_at": "2025-01-01T00:00:00Z"
        }
      ],
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

---

## 데이터 모델 요구사항

### Enum 타입

```go
// 사용자 역할
type UserRole string
const (
    UserRoleAdmin     UserRole = "admin"      // 관리자
    UserRoleDriver    UserRole = "driver"     // 기사
    UserRoleParent    UserRole = "parent"     // 학부모
    UserRoleAttendant UserRole = "attendant"  // 동승자
)

// 차량 상태
type VehicleStatus string
const (
    VehicleStatusActive      VehicleStatus = "active"      // 운행중
    VehicleStatusMaintenance VehicleStatus = "maintenance" // 정비중
    VehicleStatusInactive    VehicleStatus = "inactive"    // 비활성
)

// 차량 타입
type VehicleType string
const (
    VehicleTypeVan     VehicleType = "van"      // 승합차
    VehicleTypeBus     VehicleType = "bus"      // 버스
    VehicleTypeMiniBus VehicleType = "mini_bus" // 소형버스
    VehicleTypeSedan   VehicleType = "sedan"    // 승용차
)

// 운행 상태
type TripStatus string
const (
    TripStatusPending    TripStatus = "pending"     // 대기중
    TripStatusInProgress TripStatus = "in_progress" // 운행중
    TripStatusCompleted  TripStatus = "completed"   // 완료
    TripStatusCancelled  TripStatus = "cancelled"   // 취소
)

// 탑승자 상태
type PassengerStatus string
const (
    PassengerStatusActive   PassengerStatus = "active"   // 활동중
    PassengerStatusInactive PassengerStatus = "inactive" // 비활성
)

// 경로 상태
type RouteStatus string
const (
    RouteStatusActive   RouteStatus = "active"   // 사용중
    RouteStatusInactive RouteStatus = "inactive" // 미사용
)
```

### 공통 응답 형식

모든 API는 다음 형식을 따라야 합니다:

**성공 응답:**
```json
{
  "success": true,
  "message": "작업 설명",
  "data": { /* 실제 데이터 */ }
}
```

**에러 응답:**
```json
{
  "success": false,
  "message": "에러 메시지 (사용자에게 표시)",
  "error_code": "ERROR_CODE",
  "details": { /* 추가 에러 정보 (선택) */ }
}
```

### 에러 코드

| 코드 | HTTP Status | 설명 |
|-----|------------|------|
| `AUTH_001` | 401 | 인증 토큰 없음 |
| `AUTH_002` | 401 | 토큰 만료 |
| `AUTH_003` | 403 | 권한 없음 |
| `AUTH_004` | 401 | 잘못된 로그인 정보 |
| `VALIDATION_001` | 400 | 입력값 검증 실패 |
| `NOT_FOUND_001` | 404 | 리소스 없음 |
| `DUPLICATE_001` | 409 | 중복 데이터 |
| `SERVER_001` | 500 | 서버 내부 오류 |

---

## 실시간 기능 요구사항

### 현재 구현: HTTP Polling (권장)

프론트엔드에서 **10-30초 간격**으로 `GET /api/v1/locations`를 호출합니다.

**백엔드 요구사항:**
- Redis/Memcached에 최신 위치 정보 캐싱 (5초 TTL)
- DB 조회 최소화
- 응답 시간 < 200ms 목표

**데이터 흐름:**
```
드라이버 앱 (5-10초마다)
    ↓ POST /vehicles/:id/location
백엔드 API
    ↓ 저장
Redis Cache + PostgreSQL
    ↑ 조회 (10-30초마다)
관리자 앱 (Flutter)
```

### 선택사항: WebSocket (나중에)

실시간성이 더 중요해지면 WebSocket 구현 고려:
- `ws://api.eodini.io/ws`
- Event: `location_update`, `status_change`, `trip_status_change`

**현재는 구현하지 않아도 됩니다.**

---

## 보안 및 인증

### JWT 토큰

**Access Token:**
- 유효기간: 15분
- Payload: `user_id`, `email`, `role`

**Refresh Token:**
- 유효기간: 7일
- HTTP-only 쿠키 또는 Response Body

### 인증 헤더

```
Authorization: Bearer {access_token}
```

### 권한 체크

| Role | 권한 |
|------|-----|
| `admin` | 모든 리소스 접근 가능 |
| `driver` | 자신의 운행만 시작/완료 가능 |
| `parent` | 자녀의 탑승 정보만 조회 가능 |
| `attendant` | 동승 운행의 탑승자 체크 가능 |

### CORS 설정

```
Access-Control-Allow-Origin: *  (개발), https://app.eodini.io (프로덕션)
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Authorization, Content-Type
```

---

## 알림 시스템

### 아키텍처 (향후 구현)

```
백엔드 API
    ↓ Produce Events
Kafka Topic: notifications
    ↓ Consume
알림 서비스 (Go/Python Worker)
    ↓ Send
FCM (Firebase Cloud Messaging)
    ↓ Push
Flutter 앱 (관리자, 학부모)
```

### Kafka Topic 설계

**Topic: `eodini.notifications`**

**Event 타입:**
1. `trip.started` - 운행 시작
2. `passenger.boarded` - 탑승 완료
3. `passenger.alighted` - 하차 완료
4. `trip.completed` - 운행 완료
5. `vehicle.maintenance_due` - 정비 필요
6. `insurance.expiry_warning` - 보험 만료 임박

**이벤트 형식:**
```json
{
  "event_type": "passenger.boarded",
  "timestamp": "2025-11-07T08:05:00Z",
  "payload": {
    "trip_id": "uuid",
    "passenger_id": "uuid",
    "passenger_name": "홍길동",
    "guardian_user_id": "uuid",
    "location": {
      "latitude": 37.5665,
      "longitude": 126.9780
    }
  }
}
```

### FCM 알림 형식

**알림 Consumer가 FCM으로 변환:**
```json
{
  "notification": {
    "title": "탑승 완료",
    "body": "홍길동 학생이 탑승했습니다"
  },
  "data": {
    "type": "passenger.boarded",
    "trip_id": "uuid",
    "passenger_id": "uuid"
  },
  "token": "FCM_DEVICE_TOKEN"
}
```

---

## 성능 요구사항

### 응답 시간

| 엔드포인트 | 목표 | 최대 |
|----------|-----|-----|
| `GET /api/v1/locations` | < 200ms | < 500ms |
| `POST /api/v1/vehicles/:id/location` | < 100ms | < 300ms |
| 일반 CRUD | < 500ms | < 1s |
| 페이지네이션 조회 | < 1s | < 2s |

### 동시 접속

- 드라이버 앱: 최대 100대 차량 (동시 위치 업데이트)
- 관리자 앱: 최대 50명
- 학부모 앱: 최대 500명

### 데이터 볼륨

- 차량: ~100대
- 탑승자: ~1,000명
- 운행 기록: 일 200건, 월 6,000건
- 위치 로그: 일 100,000건 (차량 100대 × 10초 간격 × 운행시간)

---

## 배포 환경

### API Base URL

- **개발**: `http://localhost:8080/api/v1`
- **스테이징**: `https://api-staging.eodini.io/api/v1`
- **프로덕션**: `https://api.eodini.io/api/v1`

### 환경 변수 (프론트엔드 `.env`)

```env
API_BASE_URL=http://localhost:8080/api/v1
WS_BASE_URL=ws://localhost:8080/ws
```

---

## 개발 우선순위 타임라인

### Week 1 (즉시)
- ✅ 인증 API
- ✅ 차량 관리 API
- ✅ 탑승자 관리 API

### Week 2
- ✅ 운행 관리 API
- ✅ 경로 관리 API
- ⭐ **실시간 위치 API** (중요!)

### Week 3
- 기사 관리 API
- 일정 관리 API

### Week 4+
- WebSocket (선택)
- Kafka + FCM 알림
- 통계/리포트 API

---

## 테스트 지원

### Mock 서버 지원 요청

현재 프론트엔드는 Mock 데이터로 작동 중입니다.
백엔드 개발 전에 **Postman Mock Server** 또는 **json-server**로 임시 API를 제공해주시면 통합 테스트가 가능합니다.

### Postman Collection

프론트엔드에서 필요한 모든 API를 Postman Collection으로 공유 가능합니다.

---

## 질문 및 문의

**프론트엔드 개발자**: Claude AI
**백엔드 개발자**: TBD
**프로젝트 저장소**: https://github.com/ressKim-io/eodini

**중요 질문:**
1. 위치 데이터는 얼마나 자주 저장하시나요? (5초마다? 10초마다?)
2. Redis 사용 가능한가요? (위치 캐싱용)
3. Kafka 인프라 준비되었나요?
4. FCM 프로젝트 생성되었나요?

---

**마지막 업데이트**: 2025-11-07
**문서 버전**: 1.0
