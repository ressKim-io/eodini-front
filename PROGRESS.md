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

## 🚧 진행 중인 작업

없음

---

## 📋 다음 단계 (우선순위순)

### 1. 차량 관리 기능 🚌
**우선순위: 높음**

- [ ] **데이터 레이어**
  - [ ] `vehicle_repository.dart` - 차량 CRUD API
  - [ ] `vehicle_provider.dart` - 차량 상태 관리

- [ ] **UI 화면**
  - [ ] `vehicles_screen.dart` - 차량 목록 (검색, 필터, 페이지네이션)
  - [ ] `vehicle_detail_screen.dart` - 차량 상세 정보
  - [ ] `vehicle_form_screen.dart` - 차량 등록/수정
  - [ ] `vehicle_card.dart` - 차량 카드 위젯

- [ ] **기능**
  - [ ] 차량 목록 조회 (필터: 상태, 유형)
  - [ ] 차량 상세 정보
  - [ ] 차량 등록
  - [ ] 차량 수정
  - [ ] 차량 삭제 (Soft Delete)
  - [ ] 검색 기능
  - [ ] 무한 스크롤 또는 페이지네이션

---

### 2. 실시간 지도 통합 🗺️
**우선순위: 높음**

- [ ] **지도 라이브러리 선택**
  - [ ] 네이버 지도 (`flutter_naver_map`)
  - [ ] 카카오 지도
  - [ ] Google Maps (`google_maps_flutter`)

- [ ] **WebSocket 연결**
  - [ ] `websocket_service.dart` - WebSocket 클라이언트
  - [ ] 실시간 위치 업데이트 수신
  - [ ] 재연결 로직

- [ ] **UI 화면**
  - [ ] `map_screen.dart` - 지도 화면
  - [ ] 차량 마커 표시
  - [ ] 경로 표시
  - [ ] 정류장 마커
  - [ ] 실시간 위치 업데이트 (10~30초)

- [ ] **기능**
  - [ ] 차량 위치 실시간 추적
  - [ ] 경로 및 정류장 표시
  - [ ] 차량 상태 표시 (운행 중, 대기, 정비)
  - [ ] 지도 줌/이동

---

### 3. 탑승자 관리 기능 👶
**우선순위: 중간**

- [ ] **데이터 레이어**
  - [ ] `passenger_repository.dart`
  - [ ] `passenger_provider.dart`

- [ ] **UI 화면**
  - [ ] `passengers_screen.dart` - 탑승자 목록
  - [ ] `passenger_detail_screen.dart` - 탑승자 상세
  - [ ] `passenger_form_screen.dart` - 탑승자 등록/수정
  - [ ] 보호자 정보 입력
  - [ ] 의료 특이사항 입력

- [ ] **기능**
  - [ ] 탑승자 CRUD
  - [ ] 보호자 정보 관리
  - [ ] 정류장 배정
  - [ ] 의료 특이사항 표시

---

### 4. 운행 관리 기능 📊
**우선순위: 중간**

- [ ] **데이터 레이어**
  - [ ] `trip_repository.dart`
  - [ ] `trip_provider.dart`

- [ ] **UI 화면**
  - [ ] `trips_screen.dart` - 운행 목록
  - [ ] `trip_detail_screen.dart` - 운행 상세
  - [ ] `trip_active_screen.dart` - 현재 운행 중
  - [ ] 탑승/하차 체크리스트

- [ ] **기능**
  - [ ] 운행 시작/완료
  - [ ] 탑승자 탑승/하차 체크
  - [ ] 운행 기록 조회
  - [ ] 운행 취소

---

### 5. 기사 관리 기능 👨‍✈️
**우선순위: 낮음**

- [ ] `driver_repository.dart`
- [ ] `drivers_screen.dart`
- [ ] 기사 CRUD
- [ ] 면허 만료일 알림

---

### 6. 경로/일정 관리 🛣️
**우선순위: 낮음**

- [ ] `route_repository.dart`
- [ ] `schedule_repository.dart`
- [ ] 경로 생성/수정
- [ ] 정류장 관리
- [ ] 일정 템플릿 관리

---

### 7. 알림 기능 🔔
**우선순위: 낮음**

- [ ] FCM 통합 (Firebase Cloud Messaging)
- [ ] 푸시 알림
- [ ] 앱 내 알림
- [ ] 알림 설정

---

### 8. 추가 기능
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
3. 🎯 차량 관리 UI (다음 작업)
4. 🎯 실시간 지도 통합

---

## 🏆 중기 목표 (1개월)

1. 차량, 탑승자, 운행 관리 완성
2. 실시간 위치 추적 안정화
3. 알림 시스템 구현
4. 테스트 코드 작성
5. 성능 최적화

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

**마지막 업데이트**: 2025-11-07
