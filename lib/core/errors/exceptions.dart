/// Excepciones puras de Dart que la capa de datos puede lanzar hacia el
/// dominio.
///
/// El dominio no conoce Dio, Postgres ni ninguna librería externa: solo
/// conoce este contrato de errores, que luego se traduce a un `Failure`
/// mediante `mapExceptionToFailure`.
sealed class AppException implements Exception {
  const AppException(this.message, {this.code});

  /// Mensaje legible para el usuario o para el log.
  final String message;

  /// Código opcional (por ejemplo el status HTTP o el `SQLSTATE`).
  final String? code;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

/// Los datos recibidos no cumplen las reglas del dominio (validación).
final class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

/// Falla la comunicación con la API REST.
final class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

/// Falla el almacenamiento local (caché).
final class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

/// Falla la base de datos (Neon / PostgreSQL).
final class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

/// El recurso solicitado no existe.
final class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});
}
