# 백엔드 구현 필요 목록

**작성일**: 2025-11-08
**목적**: 프론트엔드에서 Mock 데이터로 작동 중인 기능들의 백엔드 API 구현 추적

---

## 📊 현재 상태

### ✅ 백엔드 구현 완료
- 없음 (모든 기능이 Mock 데이터로 작동 중)

### 🔴 백엔드 구현 필요 (우선순위순)

---

## 1. 인증 시스템 🔐

### 1.1 기존 회원가입 (관리자용)
**파일**: `lib/features/auth/providers/auth_provider.dart`
**API**: `POST /api/v1/auth/register`

**Request DTO**: `RegisterDto`
```dart
{
  "email": "admin@example.com",
  "password": "password123",
  "name": "관리자",
  "phone": "010-1234-5678",
  "role": "admin",  // admin, driver, parent, attendant
  "address": "서울시 강남구...",
  "is_public": false
}
```

**Response**:
```json
{
  "success": true,
  "message": "회원가입 성공",
  "data": {
    "access_token": "...",
    "refresh_token": "...",
    "user": { /* User 객체 */ }
  }
}
```

**Mock 위치**: `lib/features/auth/providers/auth_provider.dart:50` (주석 처리됨)

---

### 1.2 보호자 회원가입 ⭐ 신규
**파일**: `lib/features/auth/screens/parent_register_screen.dart`
**API**: `POST /api/v1/auth/register/parent`

**Request DTO**: `ParentRegisterDto`
```dart
{
  // 보호자 정보
  "email": "parent@example.com",
  "password": "password123",
  "guardian_name": "홍길동",
  "guardian_phone": "010-1234-5678",
  "guardian_address": "서울시 강남구...",
  "is_public": false,

  // 자녀 정보
  "child_name": "홍아들",
  "child_birth_year": 2018,
  "child_gender": "male",
  "guardian_relation": "부모",
  "emergency_contact": "010-9876-5432",
  "emergency_relation": "모",
  "medical_notes": "알레르기: 땅콩"
}
```

**백엔드 처리 로직**:
1. User 생성 (role: parent)
2. Passenger 생성 (자녀 정보)
3. User.passenger_id에 생성된 Passenger ID 연결
4. JWT 토큰 발급 및 반환

**Mock 위치**: `lib/features/auth/screens/parent_register_screen.dart:140` (TODO 주석)

---

### 1.3 일반 회원 회원가입 ⭐ 신규
**파일**: `lib/features/auth/screens/passenger_register_screen.dart`
**API**: `POST /api/v1/auth/register/passenger`

**Request DTO**: `PassengerRegisterDto`
```dart
{
  "email": "passenger@example.com",
  "password": "password123",
  "name": "김철수",
  "phone": "010-1111-2222",
  "address": "서울시 서초구...",
  "is_public": false,
  "birth_year": 1990,
  "gender": "male",
  "emergency_contact": "010-3333-4444",
  "emergency_relation": "배우자",
  "medical_notes": "고혈압"
}
```

**백엔드 처리 로직**:
1. User 생성 (role: passenger)
2. Passenger 생성 (본인 정보)
3. User.passenger_id 연결
4. JWT 토큰 발급

**Mock 위치**: `lib/features/auth/screens/passenger_register_screen.dart:103` (TODO 주석)

---

### 1.4 운전자 회원가입 ⭐ 신규
**파일**: `lib/features/auth/screens/driver_register_screen.dart`
**API**: `POST /api/v1/auth/register/driver`

**Request DTO**: `DriverRegisterDto`
```dart
{
  "email": "driver@example.com",
  "password": "password123",
  "name": "이기사",
  "phone": "010-5555-6666",
  "address": "서울시 용산구...",
  "is_public": false,
  "license_number": "11-12-345678-90",
  "license_type": "type_1_regular",  // type_1_regular, type_1_large, type_2_regular
  "license_expiry": "2027-12-31",
  "emergency_contact": "010-7777-8888"
}
```

**백엔드 처리 로직**:
1. User 생성 (role: driver)
2. Driver 생성 (면허 정보 포함)
3. User.driver_id 연결
4. **관리자 승인 대기 상태 설정** (Driver.status = pending)
5. JWT 토큰 발급 (단, 제한된 권한)

**Mock 위치**: `lib/features/auth/screens/driver_register_screen.dart:138` (TODO 주석)

---

## 2. 차량 관리 🚗

### 2.1 차량 목록 조회
**파일**: `lib/core/services/vehicle_repository.dart`
**API**: `GET /api/v1/vehicles`

**Mock 위치**: `lib/core/services/vehicle_repository.dart:52-92` (Mock 데이터 35개)

**Query Parameters**:
- `page`, `page_size` (페이지네이션)
- `status` (active, maintenance, inactive)
- `vehicle_type` (van, bus, mini_bus, sedan)
- `search` (차량번호, 모델, 제조사)

---

### 2.2 차량 생성/수정/삭제
**API**:
- `POST /api/v1/vehicles`
- `PUT /api/v1/vehicles/:id`
- `DELETE /api/v1/vehicles/:id`

**Mock 위치**:
- 생성: `lib/core/services/vehicle_repository.dart:104`
- 수정: `lib/core/services/vehicle_repository.dart:121`
- 삭제: `lib/core/services/vehicle_repository.dart:138`

---

## 3. 탑승자 관리 👶

### 3.1 탑승자 목록 조회
**파일**: `lib/core/services/passenger_repository.dart`
**API**: `GET /api/v1/passengers`

**Mock 위치**: `lib/core/services/passenger_repository.dart:52-118` (Mock 데이터 50명)

**Query Parameters**:
- `page`, `page_size`
- `status` (active, inactive)
- `route_id` (경로별 필터)
- `search` (이름, 보호자명, 연락처)

---

### 3.2 탑승자 생성/수정/삭제
**API**:
- `POST /api/v1/passengers`
- `PUT /api/v1/passengers/:id`
- `DELETE /api/v1/passengers/:id`

**Mock 위치**:
- 생성: `lib/core/services/passenger_repository.dart:130`
- 수정: `lib/core/services/passenger_repository.dart:147`
- 삭제: `lib/core/services/passenger_repository.dart:164`

---

## 4. 기사 관리 👨‍✈️

### 4.1 기사 목록 조회
**파일**: `lib/core/services/driver_repository.dart`
**API**: `GET /api/v1/drivers`

**Mock 위치**: `lib/core/services/driver_repository.dart:52-103` (Mock 데이터 20명)

---

### 4.2 기사 생성/수정/삭제
**API**:
- `POST /api/v1/drivers`
- `PUT /api/v1/drivers/:id`
- `DELETE /api/v1/drivers/:id`

**Mock 위치**:
- 생성: `lib/core/services/driver_repository.dart:115`
- 수정: `lib/core/services/driver_repository.dart:132`
- 삭제: `lib/core/services/driver_repository.dart:149`

---

## 5. 경로 관리 🗺️

### 5.1 경로 목록 조회
**파일**: `lib/core/services/route_repository.dart`
**API**: `GET /api/v1/routes`

**Mock 위치**: `lib/core/services/route_repository.dart:31-154` (Mock 데이터 10개 경로, 각 4-6개 정류장)

**특징**: 서울 주요 지역 실제 좌표 사용

---

### 5.2 경로 생성/수정/삭제
**API**:
- `POST /api/v1/routes`
- `PUT /api/v1/routes/:id`
- `DELETE /api/v1/routes/:id`

**Mock 위치**:
- 생성: `lib/core/services/route_repository.dart:166`
- 수정: `lib/core/services/route_repository.dart:183`
- 삭제: `lib/core/services/route_repository.dart:200`

---

## 6. 일정 관리 📅

### 6.1 일정 목록 조회
**파일**: `lib/core/services/schedule_repository.dart`
**API**: `GET /api/v1/schedules`

**Mock 위치**: `lib/core/services/schedule_repository.dart:31-109` (Mock 데이터 20개)

**특징**:
- 시간대별 (오전/오후/저녁)
- 요일별 패턴 (평일/주말/특정요일)
- 유효기간 설정

---

### 6.2 일정 생성/수정/삭제
**API**:
- `POST /api/v1/schedules`
- `PUT /api/v1/schedules/:id`
- `DELETE /api/v1/schedules/:id`

**Mock 위치**:
- 생성: `lib/core/services/schedule_repository.dart:121`
- 수정: `lib/core/services/schedule_repository.dart:138`
- 삭제: `lib/core/services/schedule_repository.dart:155`

---

## 7. 운행 관리 🚌

### 7.1 운행 목록 조회
**파일**: `lib/core/services/trip_repository.dart`
**API**: `GET /api/v1/trips`

**Mock 위치**: `lib/core/services/trip_repository.dart:31-166` (Mock 데이터 30개)

---

### 7.2 운행 시작/완료/취소
**API**:
- `POST /api/v1/trips/:id/start`
- `POST /api/v1/trips/:id/complete`
- `POST /api/v1/trips/:id/cancel`

**Mock 위치**:
- 시작: `lib/core/services/trip_repository.dart:178`
- 완료: `lib/core/services/trip_repository.dart:195`
- 취소: `lib/core/services/trip_repository.dart:212`

---

### 7.3 탑승자 탑승/하차 체크
**API**:
- `POST /api/v1/trips/:trip_id/passengers/:passenger_id/board`
- `POST /api/v1/trips/:trip_id/passengers/:passenger_id/alight`

**Mock 위치**:
- 탑승: `lib/core/services/trip_repository.dart:229`
- 하차: `lib/core/services/trip_repository.dart:246`

---

## 8. 실시간 위치 📍

### 8.1 전체 차량 위치 조회 (Polling용)
**파일**: `lib/core/services/location_service.dart`
**API**: `GET /api/v1/locations`

**Mock 위치**: `lib/core/services/location_service.dart:68-106` (랜덤 위치 생성)

**특징**: 10-30초 간격으로 호출됨

---

### 8.2 차량 위치 업데이트 (드라이버 앱)
**API**: `POST /api/v1/vehicles/:id/location`

**Request**:
```json
{
  "latitude": 37.5665,
  "longitude": 126.9780,
  "speed": 45.5,
  "heading": 90.0,
  "timestamp": "2025-11-08T10:00:00Z"
}
```

**백엔드 구현 요구사항**:
- Redis 캐싱 (5초 TTL)
- PostgreSQL 로그 저장
- 응답시간 < 200ms

---

## 📋 구현 우선순위

### P0 - 즉시 필요 (1주일)
1. ✅ 인증 API (login, register)
2. 🔴 **신규 회원가입 API** (parent, passenger, driver)
3. 🔴 차량 관리 CRUD
4. 🔴 탑승자 관리 CRUD

### P1 - 높음 (2주일)
5. 🔴 운행 관리 (시작/완료/취소)
6. 🔴 탑승자 탑승/하차 체크
7. 🔴 **실시간 위치 API** (중요!)
8. 🔴 경로 관리 CRUD

### P2 - 중간 (3주일)
9. 🔴 기사 관리 CRUD
10. 🔴 일정 관리 CRUD

### P3 - 낮음 (추후)
11. ⚪ 알림 시스템 (Kafka + FCM)
12. ⚪ 통계/리포트 API

---

## 🔧 백엔드 개발 가이드

### User 모델 확장 필요
```go
type User struct {
    ID           string    `json:"id"`
    Email        string    `json:"email"`
    Name         string    `json:"name"`
    Phone        string    `json:"phone"`
    Role         UserRole  `json:"role"` // admin, driver, parent, attendant, passenger
    Address      *string   `json:"address,omitempty"`
    ProfileImage *string   `json:"profile_image,omitempty"`

    // 신규 필드
    IsPublic     bool      `json:"is_public"`      // 공개/비공개 설정
    PassengerID  *string   `json:"passenger_id,omitempty"`  // 탑승자 연결
    DriverID     *string   `json:"driver_id,omitempty"`     // 운전자 연결

    CreatedAt    time.Time `json:"created_at"`
    UpdatedAt    time.Time `json:"updated_at"`
}
```

### 회원가입 API 엔드포인트 제안
```
POST /api/v1/auth/register/parent     # 보호자 회원가입
POST /api/v1/auth/register/passenger  # 일반 회원 회원가입
POST /api/v1/auth/register/driver     # 운전자 회원가입
```

---

## 📝 Mock 데이터 정보

### 생성 규칙
- **ID**: UUID v4 형식 시뮬레이션
- **날짜**: 현재 시간 기준 상대 날짜
- **좌표**: 서울 주요 지역 실제 좌표 사용
- **이름**: 한국어 이름 랜덤 생성

### Mock 데이터 개수
- 차량: 35개
- 탑승자: 50명
- 기사: 20명
- 경로: 10개 (각 4-6개 정류장)
- 일정: 20개
- 운행: 30개

---

## 🚨 주의사항

### 실시간 위치 API 성능
- **응답시간**: < 200ms (목표), < 500ms (최대)
- **Redis 캐싱 필수**: TTL 5초
- **동시 접속**: 드라이버 100대, 관리자 50명

### 보안
- JWT Access Token: 15분
- JWT Refresh Token: 7일
- 비밀번호: bcrypt 해싱
- 이메일은 항상 비공개
- 면허 정보는 항상 비공개

### 권한 관리
- `admin`: 모든 리소스 접근
- `driver`: 본인 배정 운행만
- `parent`: 자녀 정보만
- `passenger`: 본인 정보만
- `attendant`: 배정된 운행만

---

**마지막 업데이트**: 2025-11-08
**관련 문서**: `BACKEND_REQUIREMENTS.md`, `PROGRESS.md`
