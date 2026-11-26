import '../entities/estado_evento.dart';
import '../entities/evento.dart';

/// Contrato del repositorio de eventos.
///
/// El dominio solo declara **qué** necesita; la implementación real vive en
/// `data/repositories` (Fase 2) y puede usar Neon, PostgREST o una API REST.
///
/// Los métodos lanzan una [AppException] si la infraestructura falla; los casos
/// de uso se encargan de traducirla a un `Failure`.
abstract interface class EventoRepository {
  /// Lista los eventos de un usuario, opcionalmente filtrados.
  Future<List<Evento>> listarEventos({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    EstadoEvento? estado,
  });

  /// Obtiene un evento por id o lanza `NotFoundException`.
  Future<Evento> obtenerEventoPorId(int id);

  /// Persiste un evento nuevo y lo devuelve con el id asignado.
  Future<Evento> crearEvento(Evento evento);

  /// Actualiza un evento existente y devuelve la versión persistida.
  Future<Evento> actualizarEvento(Evento evento);

  /// Elimina el evento indicado.
  Future<void> eliminarEvento(int id);
}
