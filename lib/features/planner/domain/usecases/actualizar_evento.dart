import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/evento.dart';
import '../repositories/evento_repository.dart';
import 'usecase.dart';

/// Parámetros de [ActualizarEvento].
final class ActualizarEventoParams {
  const ActualizarEventoParams({required this.evento});

  final Evento evento;
}

/// Caso de uso: actualizar un evento existente.
///
/// Exige que el evento ya tenga [Evento.id] y vuelve a validar todas las
/// reglas, porque una edición puede dejar los datos en un estado inválido.
final class ActualizarEvento implements UseCase<Evento, ActualizarEventoParams> {
  const ActualizarEvento(this._repository);

  final EventoRepository _repository;

  @override
  Future<Result<Evento>> call(ActualizarEventoParams params) async {
    final evento = params.evento;
    if (!evento.tieneId) {
      return const Err(
        ValidationFailure('El evento debe tener un id para poder actualizarse.'),
      );
    }

    final mensajeError = evento.validar();
    if (mensajeError != null) {
      return Err(ValidationFailure(mensajeError));
    }

    try {
      final actualizado = await _repository.actualizarEvento(evento);
      return Ok(actualizado);
    } catch (error) {
      return Err(mapExceptionToFailure(error));
    }
  }
}
