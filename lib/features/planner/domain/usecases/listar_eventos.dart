import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/estado_evento.dart';
import '../entities/evento.dart';
import '../repositories/evento_repository.dart';
import 'usecase.dart';

/// Parámetros de [ListarEventos].
///
/// Todos los filtros son opcionales salvo [usuarioId]: la agenda siempre se
/// consulta en el contexto de un usuario.
final class ListarEventosParams {
  const ListarEventosParams({
    required this.usuarioId,
    this.desde,
    this.hasta,
    this.categoriaId,
    this.estado,
  });

  final int usuarioId;
  final DateTime? desde;
  final DateTime? hasta;
  final int? categoriaId;
  final EstadoEvento? estado;
}

/// Caso de uso: listar los eventos de un usuario.
final class ListarEventos implements UseCase<List<Evento>, ListarEventosParams> {
  const ListarEventos(this._repository);

  final EventoRepository _repository;

  @override
  Future<Result<List<Evento>>> call(ListarEventosParams params) async {
    if (params.usuarioId <= 0) {
      return const Err(ValidationFailure('El usuario no es válido.'));
    }

    final desde = params.desde;
    final hasta = params.hasta;
    if (desde != null && hasta != null && hasta.isBefore(desde)) {
      return const Err(
        ValidationFailure(
          'El rango de fechas no es válido: "hasta" es anterior a "desde".',
        ),
      );
    }

    try {
      final eventos = await _repository.listarEventos(
        usuarioId: params.usuarioId,
        desde: desde,
        hasta: hasta,
        categoriaId: params.categoriaId,
        estado: params.estado,
      );
      return Ok(eventos);
    } catch (error) {
      return Err(mapExceptionToFailure(error));
    }
  }
}
