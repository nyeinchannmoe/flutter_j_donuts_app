/// Every route location in the app.
abstract final class RoutePaths {
  static const String launch = '/';
  static const String onboarding = '/onboarding';
  static const String authPrefix = '/auth';
  static const String authPhone = '/auth/phone';
  static const String authOtp = '/auth/otp';
  static const String authName = '/auth/name';
  static const String authDob = '/auth/dob';
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String rewards = '/rewards';
  static const String orders = '/orders';
  static const String settings = '/settings';
  static const String product = '/product/:$productIdParam';

  static const String productIdParam = 'id';
  static const String phoneQueryParam = 'phone';
  static const String authPhoneName = 'authPhone';
  static const String authOtpName = 'authOtp';
  static const String authModeParam = 'mode';
  static const String loginMode = 'login';

  static String productDetail(String productId) =>
      '/product/${Uri.encodeComponent(productId)}';

  static String otpFor(String phoneE164) => Uri(
    path: authOtp,
    queryParameters: {phoneQueryParam: phoneE164},
  ).toString();
}
