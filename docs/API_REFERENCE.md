# API Reference

백엔드 API 문서 ([eodini](https://github.com/ressKim-io/eodini) 기반)

## Base URL

```
Development: http://localhost:8080/api/v1
Production: https://api.eodini.io/api/v1
```

---

## 인증 (Authentication)

### 1. 로그인

```http
POST /auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "로그인 성공",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1...",
    "refresh_token": "eyJhbGciOiJIUzI1...",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "role": "driver"
    }
  }
}
```

### 2. 회원가입

```http
POST /auth/register
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "홍길동",
  "phone": "010-1234-5678",
  "role": "driver"
}
```

### 3. 토큰 갱신

```http
POST /auth/refresh
```

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1..."
}
```

---

## 차량 (Vehicles)

### 1. 차량 목록 조회

```http
GET /vehicles
```

**Query Parameters:**
- `page` (int): 페이지 번호 (기본값: 1)
- `page_size` (int): 페이지당 항목 수 (기본값: 20)
- `status` (string): 차량 상태 필터 (active, maintenance, inactive)
- `vehicle_type` (string): 차량 유형 필터 (van, bus, mini_bus, sedan)

**Response:**
```json
{
  "success": true,
  "message": "조회 성공",
  "data": [
    {
      "id": "uuid",
      "plate_number": "12가3456",
      "model": "그랜드스타렉스",
      "manufacturer": "현대",
      "vehicle_type": "van",
      "capacity": 12,
      "year": 2023,
      "color": "흰색",
      "status": "active",
      "insurance_expiry": "2025-12-31T00:00:00Z",
      "inspection_expiry": "2025-06-30T00:00:00Z",
      "last_maintenance_at": "2025-01-15T10:00:00Z",
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

### 2. 차량 상세 조회

```http
GET /vehicles/:id
```

### 3. 차량 등록

```http
POST /vehicles
```

**Request Body:**
```json
{
  "plate_number": "12가3456",
  "model": "그랜드스타렉스",
  "manufacturer": "현대",
  "vehicle_type": "van",
  "capacity": 12,
  "year": 2023,
  "color": "흰색"
}
```

### 4. 차량 수정

```http
PUT /vehicles/:id
```

### 5. 차량 삭제

```http
DELETE /vehicles/:id
```

---

## 기사 (Drivers)

### 1. 기사 목록 조회

```http
GET /drivers
```

**Query Parameters:**
- `page`, `page_size` (페이지네이션)
- `status` (active, on_leave, inactive)

**Response:**
```json
{
  "success": true,
  "message": "조회 성공",
  "data": [
    {
      "id": "uuid",
      "name": "김기사",
      "phone": "010-1111-2222",
      "email": "driver@example.com",
      "status": "active",
      "license_number": "11-12-345678-90",
      "license_type": "type_1_regular",
      "license_expiry": "2027-12-31T00:00:00Z",
      "hire_date": "2023-01-01T00:00:00Z",
      "created_at": "2023-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

### 2. 기사 등록

```http
POST /drivers
```

---

## 탑승자 (Passengers)

### 1. 탑승자 목록 조회

```http
GET /passengers
```

**Response:**
```json
{
  "success": true,
  "message": "조회 성공",
  "data": [
    {
      "id": "uuid",
      "name": "홍길동",
      "age": 7,
      "gender": "male",
      "status": "active",
      "assigned_route_id": "route-uuid",
      "assigned_stop_id": "stop-uuid",
      "stop_order": 3,
      "guardian_name": "홍아빠",
      "guardian_phone": "010-2222-3333",
      "guardian_email": "parent@example.com",
      "medical_notes": "알레르기: 땅콩",
      "created_at": "2024-03-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

---

## 경로 (Routes)

### 1. 경로 목록 조회

```http
GET /routes
```

**Response:**
```json
{
  "success": true,
  "message": "조회 성공",
  "data": [
    {
      "id": "uuid",
      "name": "A코스",
      "description": "오전 등원 A코스",
      "status": "active",
      "estimated_time": 45,
      "total_distance": 15000,
      "stops": [
        {
          "id": "stop-uuid",
          "route_id": "uuid",
          "name": "OO아파트 정문",
          "address": "서울시 강남구 ...",
          "order": 1,
          "latitude": 37.5665,
          "longitude": 126.9780,
          "estimated_arrival_time": 5,
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

### 2. 경로별 정류장 조회

```http
GET /routes/:id/stops
```

---

## 운행 (Trips)

### 1. 운행 목록 조회

```http
GET /trips
```

**Query Parameters:**
- `date` (string): 날짜 필터 (YYYY-MM-DD)
- `status` (string): 상태 필터 (pending, in_progress, completed, cancelled)
- `vehicle_id` (string): 차량 ID 필터

**Response:**
```json
{
  "success": true,
  "message": "조회 성공",
  "data": [
    {
      "id": "uuid",
      "schedule_id": "schedule-uuid",
      "date": "2025-11-07",
      "status": "in_progress",
      "vehicle_id": "vehicle-uuid",
      "assigned_driver_id": "driver-uuid",
      "started_at": "2025-11-07T08:00:00Z",
      "started_by": "driver:uuid",
      "actual_start_location": {
        "latitude": 37.5665,
        "longitude": 126.9780,
        "timestamp": "2025-11-07T08:00:00Z"
      },
      "trip_passengers": [
        {
          "id": "tp-uuid",
          "trip_id": "uuid",
          "passenger_id": "passenger-uuid",
          "stop_id": "stop-uuid",
          "is_boarded": true,
          "is_alighted": false,
          "boarded_at": "2025-11-07T08:05:00Z"
        }
      ],
      "created_at": "2025-11-06T00:00:00Z",
      "updated_at": "2025-11-07T08:05:00Z"
    }
  ]
}
```

### 2. 운행 시작

```http
POST /trips/:id/start
```

**Request Body:**
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

### 3. 운행 완료

```http
POST /trips/:id/complete
```

**Request Body:**
```json
{
  "location": {
    "latitude": 37.5665,
    "longitude": 126.9780,
    "timestamp": "2025-11-07T09:00:00Z"
  }
}
```

### 4. 운행 취소

```http
POST /trips/:id/cancel
```

**Request Body:**
```json
{
  "reason": "차량 고장"
}
```

---

## 일정 (Schedules)

### 1. 일정 목록 조회

```http
GET /schedules
```

**Response:**
```json
{
  "success": true,
  "message": "조회 성공",
  "data": [
    {
      "id": "uuid",
      "name": "오전 8시 A코스",
      "description": "매일 오전 등원",
      "status": "active",
      "start_time": "08:00",
      "time_slot": "morning",
      "days_of_week": [1, 2, 3, 4, 5],
      "route_id": "route-uuid",
      "vehicle_id": "vehicle-uuid",
      "default_driver_id": "driver-uuid",
      "valid_from": "2025-01-01T00:00:00Z",
      "valid_to": "2025-12-31T00:00:00Z",
      "created_at": "2024-12-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

---

## 에러 코드

| 코드 | 상태 | 설명 |
|-----|------|------|
| `AUTH_001` | 401 | 인증 토큰 없음 |
| `AUTH_002` | 401 | 토큰 만료 |
| `AUTH_003` | 403 | 권한 없음 |
| `VALIDATION_001` | 400 | 입력값 검증 실패 |
| `NOT_FOUND_001` | 404 | 리소스 없음 |
| `DUPLICATE_001` | 409 | 중복 데이터 |
| `SERVER_001` | 500 | 서버 내부 오류 |

---

## 실시간 통신 (WebSocket)

### 연결

```
ws://localhost:8080/ws
```

### 이벤트

#### 1. 차량 위치 업데이트

**Event:** `location_update`

```json
{
  "vehicle_id": "uuid",
  "latitude": 37.5665,
  "longitude": 126.9780,
  "timestamp": "2025-11-07T08:00:00Z",
  "speed": 45,
  "heading": 90
}
```

#### 2. 차량 상태 변경

**Event:** `status_change`

```json
{
  "vehicle_id": "uuid",
  "status": "maintenance",
  "timestamp": "2025-11-07T10:00:00Z"
}
```

#### 3. 운행 상태 변경

**Event:** `trip_status_change`

```json
{
  "trip_id": "uuid",
  "status": "in_progress",
  "timestamp": "2025-11-07T08:00:00Z"
}
```
