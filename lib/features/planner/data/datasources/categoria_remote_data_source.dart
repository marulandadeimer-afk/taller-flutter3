import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/categoria_model.dart';

/// Acceso remoto a las categorías sobre la API REST de Neon.
abstract interface class CategoriaRemoteDataSource {
  Future<List<CategoriaModel>> listarCategorias(int usuarioId);

  Future<CategoriaModel> obtenerCategoriaPorId(int id);

  Future<CategoriaModel> crearCategoria(CategoriaModel categoria);

  Future<CategoriaModel> actualizarCategoria(CategoriaModel categoria);

  Future<void> eliminarCategoria(int id);
}

/// Implementación sobre [ApiClient] con la convención de PostgREST.
class CategoriaRemoteDataSourceImpl implements CategoriaRemoteDataSource {
  const CategoriaRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<CategoriaModel>> listarCategorias(int usuarioId) async {
    final datos = await _apiClient.get(
      ApiConstants.categorias,
      queryParameters: {
        'select': '*',
        'usuario_id': 'eq.$usuarioId',
        'order': 'nombre.asc',
      },
    );

    if (datos is! List) {
      throw const ServerException(
        'La API no devolvió una lista de categorías.',
      );
    }
    return datos.map(_aModelo).toList();
  }

  @override
  Future<CategoriaModel> obtenerCategoriaPorId(int id) async {
    final datos = await _apiClient.get(
      ApiConstants.categorias,
      queryParameters: {'select': '*', 'id': 'eq.$id', 'limit': 1},
    );

    final categoria = _aModeloUnico(datos);
    if (categoria == null) {
      throw NotFoundException('No existe una categoría con id $id.');
    }
    return categoria;
  }

  @override
  Future<CategoriaModel> crearCategoria(CategoriaModel categoria) async {
    final datos = await _apiClient.post(
      ApiConstants.categorias,
      data: categoria.toJson(),
    );

    final creada = _aModeloUnico(datos);
    if (creada == null) {
      throw const ServerException('La API no devolvió la categoría creada.');
    }
    return creada;
  }

  @override
  Future<CategoriaModel> actualizarCategoria(CategoriaModel categoria) async {
    final id = categoria.id;
    if (id == null) {
      throw const ValidationException(
        'No se puede actualizar una categoría que no tiene id.',
      );
    }

    final datos = await _apiClient.patch(
      ApiConstants.categorias,
      queryParameters: {'id': 'eq.$id'},
      data: categoria.toJson(),
    );

    final actualizada = _aModeloUnico(datos);
    if (actualizada == null) {
      throw NotFoundException('No existe una categoría con id $id.');
    }
    return actualizada;
  }

  @override
  Future<void> eliminarCategoria(int id) async {
    await _apiClient.delete(
      ApiConstants.categorias,
      queryParameters: {'id': 'eq.$id'},
    );
  }

  CategoriaModel _aModelo(Object? item) {
    if (item is Map<String, dynamic>) {
      return CategoriaModel.fromJson(item);
    }
    throw const ServerException(
      'Formato de categoría inválido en la respuesta.',
    );
  }

  CategoriaModel? _aModeloUnico(Object? datos) {
    if (datos is List) {
      if (datos.isEmpty) {
        return null;
      }
      return _aModelo(datos.first);
    }
    if (datos == null) {
      return null;
    }
    return _aModelo(datos);
  }
}
