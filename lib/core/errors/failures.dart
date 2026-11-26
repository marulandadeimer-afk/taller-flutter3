/// Errores de negocio que viajan por las capas sin arrastrar detalles de
/// infraestructura.
///
/// Un `Failure` es el resultado esperado de un caso de uso: la aplicación
/// puede mostrarlo al usuario sin exponer una excepción de Dio o de Postgres.
sealed class Failure {
  const Failure(this.message, {this.code});

  /// Mensaje pensado para la interfaz o para el log.
  final String message;

  /// Código opcional (status HTTP, `SQLSTATE`, etc.).
  final String? code;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

/// Los datos no cumplen las reglas del dominio.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// La API REST respondió con un error o no respondió.
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Falla la caché local.
final class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Falla la base de datos.
final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

/// El recurso solicitado no existe.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

/// Error no controlado (programación, formato inesperado, etc.).
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code});
}
