/// API 관련 상수 정의
class ApiConstants {
  // 기본 설정
  static const int connectTimeout = 30000; // 30초
  static const int receiveTimeout = 30000; // 30초
  static const int sendTimeout = 30000; // 30초

  // API 엔드포인트
  static const String health = '/health';
  static const String healthReady = '/health/ready';
  static const String healthLive = '/health/live';

  // Auth
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  // Vehicle
  static const String vehicles = '/vehicles';
  static String vehicleById(String id) => '/vehicles/$id';
  static String vehicleLocation(String id) => '/vehicles/$id/location';

  // Driver
  static const String drivers = '/drivers';
  static String driverById(String id) => '/drivers/$id';

  // Passenger
  static const String passengers = '/passengers';
  static String passengerById(String id) => '/passengers/$id';

  // Route
  static const String routes = '/routes';
  static String routeById(String id) => '/routes/$id';
  static String routeStops(String id) => '/routes/$id/stops';

  // Trip
  static const String trips = '/trips';
  static String tripById(String id) => '/trips/$id';
  static String tripStart(String id) => '/trips/$id/start';
  static String tripComplete(String id) => '/trips/$id/complete';
  static String tripCancel(String id) => '/trips/$id/cancel';

  // Schedule
  static const String schedules = '/schedules';
  static String scheduleById(String id) => '/schedules/$id';

  // HTTP 헤더
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String applicationJson = 'application/json';
  static String bearerToken(String token) => 'Bearer $token';
}
