import '../models/evento_model.dart';

/// Caché local de eventos.
///
/// La versión en memoria cubre la Fase 2; en la Fase 3 se puede reemplazar por
/// `shared_preferences` o `hive` sin tocar el repositorio.
abstract interface class EventoLocalDataSource {
  Future<List<EventoModel>?> leerCache(int usuarioId);

  Future<void> guardarCache(int usuarioId, List<EventoModel> eventos);

  Future<void> invalidarCache(int usuarioId);

  Future<void> invalidarTodo();
}

/// Implementación en memoria de [EventoLocalDataSource].
class EventoLocalDataSourceEnMemoria implements EventoLocalDataSource {
  final Map<int, List<EventoModel>> _cache = {};

  @override
  Future<List<EventoModel>?> leerCache(int usuarioId) async {
    return _cache[usuarioId];
  }

  @override
  Future<void> guardarCache(int usuarioId, List<EventoModel> eventos) async {
    _cache[usuarioId] = List<EventoModel>.unmodifiable(eventos);
  }

  @override
  Future<void> invalidarCache(int usuarioId) async {
    _cache.remove(usuarioId);
  }

  @override
  Future<void> invalidarTodo() async {
    _cache.clear();
  }
}
