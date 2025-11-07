# Changelog

프로젝트의 모든 주요 변경 사항이 이 파일에 문서화됩니다.

---

## [Unreleased]

### 계획된 기능
- 차량 관리 UI
- 실시간 지도 통합
- 탑승자 관리
- 운행 관리

---

## [0.2.0] - 2025-11-07

### 🎉 Added (추가됨)
- **인증 시스템**
  - 로그인 화면 (이메일/비밀번호)
  - 회원가입 화면 (이름, 이메일, 전화번호, 역할, 주소)
  - 자동 로그인 기능
  - 로그아웃 기능
  - JWT 토큰 관리 (Access + Refresh)

- **데이터 모델**
  - `User` - 사용자 모델
  - `UserRole` enum - 관리자, 운전자, 학부모, 동승자
  - `LoginDto/Response` - 로그인 DTO
  - `RegisterDto` - 회원가입 DTO
  - `RefreshTokenDto/Response` - 토큰 갱신 DTO

- **서비스 레이어**
  - `TokenStorageService` - JWT 토큰 암호화 저장
  - `AuthRepository` - 인증 API 통신
  - `AuthProvider` - Riverpod 상태 관리

- **라우팅**
  - `app_router.dart` - go_router 통합
  - AuthGuard 구현 (인증 보호)
  - 자동 리다이렉트 (로그인 ↔ 홈)

- **UI 화면**
  - `LoginScreen` - 로그인 화면
  - `RegisterScreen` - 회원가입 화면
  - `HomeScreen` - 홈 화면 (사용자 정보 표시)

### 🔒 Security (보안)
- flutter_secure_storage로 JWT 토큰 암호화 저장
- AuthInterceptor로 자동 Bearer Token 헤더 추가
- 토큰 자동 갱신 (401 에러 시)
- 비밀번호 가시성 토글

### 🎨 Changed (변경됨)
- `main.dart` - go_router 통합으로 변경
- MaterialApp → MaterialApp.router

---

## [0.1.0] - 2025-11-07

### 🎉 Added (추가됨)
- **프로젝트 초기 셋업**
  - Flutter 프로젝트 구조 생성
  - `pubspec.yaml` 의존성 설정
  - `.gitignore` 설정
  - `.env.example` 환경 변수 템플릿

- **Core 레이어**
  - `api_client.dart` - Dio HTTP 클라이언트
  - `api_interceptor.dart` - 인증/로깅 인터셉터
  - `api_response.dart` - 표준 API 응답 모델
  - `api_constants.dart` - API 엔드포인트 상수
  - `app_constants.dart` - 앱 설정 상수

- **데이터 모델** (백엔드 Go 구조체 기반)
  - `vehicle.dart` - 차량 모델 (Vehicle, VehicleType, VehicleStatus)
  - `driver.dart` - 기사 모델 (Driver, DriverStatus, LicenseType)
  - `passenger.dart` - 탑승자 모델 (Passenger, PassengerStatus)
  - `route.dart` - 경로/정류장 모델 (RouteModel, Stop, RouteStatus)
  - `trip.dart` - 운행 기록 모델 (Trip, TripStatus, Location, TripPassenger)
  - `schedule.dart` - 운행 일정 모델 (Schedule, ScheduleStatus, TimeSlot)

- **문서화**
  - `README.md` - 프로젝트 가이드
  - `docs/API_REFERENCE.md` - 백엔드 API 문서

### 🛠️ Tech Stack
- Flutter 3.x + Dart 3.0+
- Riverpod 2.4+ (상태 관리)
- Dio 5.4+ (HTTP 클라이언트)
- freezed + json_serializable (불변 모델)
- go_router 12.1+ (라우팅)
- flutter_secure_storage (보안 저장소)
- Material Design 3

---

## Legend (범례)

### 아이콘
- 🎉 Added - 새로운 기능
- 🔒 Security - 보안 관련
- 🐛 Fixed - 버그 수정
- 🎨 Changed - 변경 사항
- 🗑️ Deprecated - 더 이상 사용되지 않음
- 🔥 Removed - 제거됨
- ⚡ Performance - 성능 개선
- 📚 Docs - 문서 업데이트

### 버전 형식
- MAJOR.MINOR.PATCH (예: 1.0.0)
- MAJOR: 호환되지 않는 API 변경
- MINOR: 하위 호환되는 기능 추가
- PATCH: 하위 호환되는 버그 수정

---

**참고**: 이 프로젝트는 [Semantic Versioning](https://semver.org/)을 따릅니다.
