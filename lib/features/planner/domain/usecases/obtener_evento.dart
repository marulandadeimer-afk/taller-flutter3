import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/evento.dart';
import '../repositories/evento_repository.dart';
import 'usecase.dart';

/// Parámetros de [ObtenerEvento].
final class ObtenerEventoParams {
  const ObtenerEventoParams(this.id);

  final int id;
}

/// Caso de uso: obtener el detalle de un evento.
final class ObtenerEvento implements UseCase<Evento, ObtenerEventoParams> {
  const ObtenerEvento(this._repository);

  final EventoRepository _repository;

  @override
  Future<Result<Evento>> call(ObtenerEventoParams params) async {
    if (params.id <= 0) {
      return const Err(ValidationFailure('El id del evento no es válido.'));
    }

    try {
      final evento = await _repository.obtenerEventoPorId(params.id);
      return Ok(evento);
    } catch (error) {
      return Err(mapExceptionToFailure(error));
    }
  }
}
