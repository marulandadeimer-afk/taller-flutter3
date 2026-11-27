import '../models/categoria_model.dart';

/// Caché local de categorías.
abstract interface class CategoriaLocalDataSource {
  Future<List<CategoriaModel>?> leerCache(int usuarioId);

  Future<void> guardarCache(int usuarioId, List<CategoriaModel> categorias);

  Future<void> invalidarCache(int usuarioId);

  Future<void> invalidarTodo();
}

/// Implementación en memoria de [CategoriaLocalDataSource].
class CategoriaLocalDataSourceEnMemoria implements CategoriaLocalDataSource {
  final Map<int, List<CategoriaModel>> _cache = {};

  @override
  Future<List<CategoriaModel>?> leerCache(int usuarioId) async {
    return _cache[usuarioId];
  }

  @override
  Future<void> guardarCache(
    int usuarioId,
    List<CategoriaModel> categorias,
  ) async {
    _cache[usuarioId] = List<CategoriaModel>.unmodifiable(categorias);
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
