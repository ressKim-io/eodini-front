/// 앱 전역 상수
class AppConstants {
  // 앱 정보
  static const String appName = 'Eodini';
  static const String appVersion = '1.0.0';

  // 로컬 스토리지 키
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';

  // 실시간 갱신 간격 (초)
  static const int locationUpdateInterval = 10; // 10~30초 권장

  // 페이지네이션
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 사용자 역할
  static const String roleAdmin = 'admin';
  static const String roleDriver = 'driver';
  static const String roleParent = 'parent';
  static const String roleAttendant = 'attendant';

  // 날짜 포맷
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // 에러 메시지
  static const String errorNetwork = '네트워크 연결을 확인해주세요';
  static const String errorUnknown = '알 수 없는 오류가 발생했습니다';
  static const String errorTimeout = '요청 시간이 초과되었습니다';
  static const String errorUnauthorized = '인증이 필요합니다';
  static const String errorForbidden = '권한이 없습니다';
  static const String errorNotFound = '요청한 리소스를 찾을 수 없습니다';
  static const String errorServer = '서버 오류가 발생했습니다';
}
