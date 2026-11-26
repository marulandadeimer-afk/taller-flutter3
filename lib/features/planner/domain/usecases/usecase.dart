import '../../../../core/utils/result.dart';

/// Contrato genérico de un caso de uso.
///
/// [Salida] es el tipo devuelto cuando todo sale bien y [Entrada] el objeto de
/// parámetros que recibe el caso de uso.
abstract interface class UseCase<Salida, Entrada> {
  Future<Result<Salida>> call(Entrada params);
}

/// Parámetros vacíos para casos de uso que no necesitan datos de entrada.
final class NoParams {
  const NoParams();
}
