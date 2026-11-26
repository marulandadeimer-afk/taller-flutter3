import '../errors/failures.dart';

/// Resultado de una operación de dominio.
///
/// Es un tipo propio (sin `dartz` ni `fpdart`) para cumplir la regla del
/// taller: la capa de dominio no depende de paquetes externos.
///
/// Uso:
/// ```dart
/// final resultado = await crearEvento(params);
/// resultado.fold(
///   onOk: (evento) => mostrarEvento(evento),
///   onErr: (failure) => mostrarError(failure.message),
/// );
/// ```
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;

  bool get isErr => this is Err<T>;

  /// Valor en caso de éxito; `null` si hubo un fallo.
  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  /// Fallo en caso de error; `null` si la operación fue exitosa.
  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final failure) => failure,
  };

  /// Reduce el resultado a un único valor.
  R fold<R>({
    required R Function(T value) onOk,
    required R Function(Failure failure) onErr,
  }) {
    return switch (this) {
      Ok<T>(:final value) => onOk(value),
      Err<T>(:final failure) => onErr(failure),
    };
  }
}

/// Operación exitosa.
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  String toString() => 'Ok($value)';
}

/// Operación fallida.
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  String toString() => 'Err($failure)';
}
