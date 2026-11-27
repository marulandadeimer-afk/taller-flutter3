import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/estado_evento.dart';
import '../../domain/entities/evento.dart';
import '../../domain/repositories/evento_repository.dart';
import '../datasources/evento_local_data_source.dart';
import '../datasources/evento_remote_data_source.dart';
import '../models/evento_model.dart';

/// Implementación del contrato [EventoRepository].
///
/// - Lee y escribe en la API REST (Neon/PostgREST).
/// - Guarda la última lista en la caché local y la usa como respaldo cuando la
///   API no responde (modo offline básico).
class EventoRepositoryImpl implements EventoRepository {
  const EventoRepositoryImpl(this._remote, this._local);

  final EventoRemoteDataSource _remote;
  final EventoLocalDataSource _local;

  @override
  Future<List<Evento>> listarEventos({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    EstadoEvento? estado,
  }) async {
    try {
      final eventos = await _remote.listarEventos(
        usuarioId: usuarioId,
        desde: desde,
        hasta: hasta,
        categoriaId: categoriaId,
        estado: estado,
      );
      await _local.guardarCache(usuarioId, eventos);
      return eventos;
    } on ServerException {
      final cache = await _local.leerCache(usuarioId);
      if (cache != null && cache.isNotEmpty) {
        return cache;
      }
      rethrow;
    }
  }

  @override
  Future<Evento> obtenerEventoPorId(int id) async {
    final evento = await _remote.obtenerEventoPorId(id);
    return evento.toEntity();
  }

  @override
  Future<Evento> crearEvento(Evento evento) async {
    final creado = await _remote.crearEvento(EventoModel.fromEntity(evento));
    await _local.invalidarCache(evento.usuarioId);
    return creado.toEntity();
  }

  @override
  Future<Evento> actualizarEvento(Evento evento) async {
    final actualizado = await _remote.actualizarEvento(
      EventoModel.fromEntity(evento),
    );
    await _local.invalidarCache(evento.usuarioId);
    return actualizado.toEntity();
  }

  @override
  Future<void> eliminarEvento(int id) async {
    await _remote.eliminarEvento(id);
    await _local.invalidarTodo();
  }
}
