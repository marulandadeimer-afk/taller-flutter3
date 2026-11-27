import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/evento.dart';
import '../repositories/evento_repository.dart';
import 'usecase.dart';

/// Parámetros de [CrearEvento].
final class CrearEventoParams {
  const CrearEventoParams({required this.evento});

  final Evento evento;
}

/// Caso de uso: crear un evento de la agenda.
///
/// Valida la entidad antes de tocar la base de datos y devuelve un [Failure]
/// legible si algo no cumple las reglas del dominio.
final class CrearEvento implements UseCase<Evento, CrearEventoParams> {
  const CrearEvento(this._repository);

  final EventoRepository _repository;

  @override
  Future<Result<Evento>> call(CrearEventoParams params) async {
    final mensajeError = params.evento.validar();
    if (mensajeError != null) {
      return Err(ValidationFailure(mensajeError));
    }

    try {
      final evento = await _repository.crearEvento(params.evento);
      return Ok(evento);
    } catch (error) {
      return Err(mapExceptionToFailure(error));
    }
  }
}
