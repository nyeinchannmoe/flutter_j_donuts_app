/// Whether the auth stack is registering a new member or signing in.
enum AuthFlowMode {
  register,
  login;

  /// True when OTP may only succeed for an already stored account.
  bool get requiresExistingAccount => this == AuthFlowMode.login;

  /// Parses the go_router `mode` query value; anything else is register.
  static AuthFlowMode fromQuery(String? value) =>
      value == loginQueryValue ? AuthFlowMode.login : AuthFlowMode.register;

  /// Query value written for the log-in path; register omits the param.
  static const String loginQueryValue = 'login';

  String? get queryValue =>
      this == AuthFlowMode.login ? loginQueryValue : null;
}
