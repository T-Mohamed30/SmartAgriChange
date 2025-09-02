import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.stackTrace]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.stackTrace]);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.stackTrace]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access', super.stackTrace]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found', super.stackTrace]);
}

class BadRequestFailure extends Failure {
  final Map<String, dynamic>? errors;
  
  const BadRequestFailure(String message, {this.errors, StackTrace? stackTrace})
      : super(message, stackTrace);
}
