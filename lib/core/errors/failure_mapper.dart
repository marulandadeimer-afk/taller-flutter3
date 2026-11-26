import 'exceptions.dart';
import 'failures.dart';

/// Traduce una excepción de infraestructura al [Failure] que consume el
/// dominio.
///
/// Se usa en los casos de uso para que la capa de presentación nunca tenga que
/// capturar excepciones de Dio, Postgres o `shared_preferences`.
Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    ValidationException(:final message, :final code) =>
      ValidationFailure(message, code: code),
    ServerException(:final message, :final code) =>
      ServerFailure(message, code: code),
    CacheException(:final message, :final code) =>
      CacheFailure(message, code: code),
    DatabaseException(:final message, :final code) =>
      DatabaseFailure(message, code: code),
    NotFoundException(:final message, :final code) =>
      NotFoundFailure(message, code: code),
    Failure() => error,
    _ => UnexpectedFailure(error.toString()),
  };
}
