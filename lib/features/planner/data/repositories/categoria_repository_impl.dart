import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/repositories/categoria_repository.dart';
import '../datasources/categoria_local_data_source.dart';
import '../datasources/categoria_remote_data_source.dart';
import '../models/categoria_model.dart';

/// Implementación del contrato [CategoriaRepository].
class CategoriaRepositoryImpl implements CategoriaRepository {
  const CategoriaRepositoryImpl(this._remote, this._local);

  final CategoriaRemoteDataSource _remote;
  final CategoriaLocalDataSource _local;

  @override
  Future<List<Categoria>> listarCategorias(int usuarioId) async {
    try {
      final categorias = await _remote.listarCategorias(usuarioId);
      await _local.guardarCache(usuarioId, categorias);
      return categorias;
    } on ServerException {
      final cache = await _local.leerCache(usuarioId);
      if (cache != null && cache.isNotEmpty) {
        return cache;
      }
      rethrow;
    }
  }

  @override
  Future<Categoria> obtenerCategoriaPorId(int id) async {
    final categoria = await _remote.obtenerCategoriaPorId(id);
    return categoria.toEntity();
  }

  @override
  Future<Categoria> crearCategoria(Categoria categoria) async {
    final creada = await _remote.crearCategoria(
      CategoriaModel.fromEntity(categoria),
    );
    await _local.invalidarCache(categoria.usuarioId);
    return creada.toEntity();
  }

  @override
  Future<Categoria> actualizarCategoria(Categoria categoria) async {
    final actualizada = await _remote.actualizarCategoria(
      CategoriaModel.fromEntity(categoria),
    );
    await _local.invalidarCache(categoria.usuarioId);
    return actualizada.toEntity();
  }

  @override
  Future<void> eliminarCategoria(int id) async {
    await _remote.eliminarCategoria(id);
    await _local.invalidarTodo();
  }
}
