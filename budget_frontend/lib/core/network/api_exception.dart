class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get needsVerification => statusCode == 403;

  bool get isUnauthorized => statusCode == 401;
}
