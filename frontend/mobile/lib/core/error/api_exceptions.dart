/// Base class for all API exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}

/// Thrown when the request is not authorized (401)
class UnauthorizedException extends ApiException {
  const UnauthorizedException([String message = 'Unauthorized access'])
      : super(message, 401);
}

/// Thrown when access is forbidden (403)
class ForbiddenException extends ApiException {
  const ForbiddenException([String message = 'Access forbidden'])
      : super(message, 403);
}

/// Thrown when a resource is not found (404)
class NotFoundException extends ApiException {
  const NotFoundException([String message = 'Resource not found'])
      : super(message, 404);
}

/// Thrown when the request is malformed (400)
class BadRequestException extends ApiException {
  final Map<String, dynamic>? errors;

  const BadRequestException([String message = 'Bad request', this.errors])
      : super(message, 400);
}

/// Thrown when there's a server error (500+)
class ServerException extends ApiException {
  const ServerException([String message = 'Server error'])
      : super(message, 500);
}

/// Thrown when there's a network error
class NetworkException extends ApiException {
  const NetworkException([super.message = 'Network error']);
}

/// Thrown when a request times out
class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'Request timed out']);
}

/// Thrown when there's an error parsing the response
class FormatException extends ApiException {
  const FormatException([super.message = 'Invalid format']);
}
