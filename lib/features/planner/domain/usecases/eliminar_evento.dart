import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/evento_repository.dart';
import 'usecase.dart';

/// Parámetros de [EliminarEvento].
final class EliminarEventoParams {
  const EliminarEventoParams(this.id);

  final int id;
}

/// Caso de uso: eliminar un evento de la agenda.
final class EliminarEvento implements UseCase<void, EliminarEventoParams> {
  const EliminarEvento(this._repository);

  final EventoRepository _repository;

  @override
  Future<Result<void>> call(EliminarEventoParams params) async {
    if (params.id <= 0) {
      return const Err(ValidationFailure('El id del evento no es válido.'));
    }

    try {
      await _repository.eliminarEvento(params.id);
      return const Ok<void>(null);
    } catch (error) {
      return Err(mapExceptionToFailure(error));
    }
  }
}
