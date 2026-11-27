import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/exceptions.dart';
import 'package:gestor_agenda/features/planner/data/datasources/categoria_local_data_source.dart';
import 'package:gestor_agenda/features/planner/data/datasources/categoria_remote_data_source.dart';
import 'package:gestor_agenda/features/planner/data/models/categoria_model.dart';
import 'package:gestor_agenda/features/planner/data/repositories/categoria_repository_impl.dart';

/// Fuente remota controlable.
class _FakeRemote implements CategoriaRemoteDataSource {
  Object? error;
  List<CategoriaModel> respuesta = const [];
  int? idEliminado;

  void _lanzarSiHayError() {
    final fallo = error;
    if (fallo != null) {
      throw fallo;
    }
  }

  @override
  Future<List<CategoriaModel>> listarCategorias(int usuarioId) async {
    _lanzarSiHayError();
    return respuesta;
  }

  @override
  Future<CategoriaModel> obtenerCategoriaPorId(int id) async {
    _lanzarSiHayError();
    for (final categoria in respuesta) {
      if (categoria.id == id) {
        return categoria;
      }
    }
    throw NotFoundException('No existe la categoría $id');
  }

  @override
  Future<CategoriaModel> crearCategoria(CategoriaModel categoria) async {
    _lanzarSiHayError();
    return CategoriaModel.fromEntity(categoria.copyWith(id: 20));
  }

  @override
  Future<CategoriaModel> actualizarCategoria(CategoriaModel categoria) async {
    _lanzarSiHayError();
    return categoria;
  }

  @override
  Future<void> eliminarCategoria(int id) async {
    _lanzarSiHayError();
    idEliminado = id;
  }
}

CategoriaModel _modelo({int id = 1}) =>
    CategoriaModel(id: id, nombre: 'Trabajo', usuarioId: 1);

void main() {
  late _FakeRemote remote;
  late CategoriaLocalDataSourceEnMemoria local;
  late CategoriaRepositoryImpl repository;

  setUp(() {
    remote = _FakeRemote();
    local = CategoriaLocalDataSourceEnMemoria();
    repository = CategoriaRepositoryImpl(remote, local);
  });

  test('listarCategorias guarda la caché', () async {
    remote.respuesta = [_modelo()];

    final categorias = await repository.listarCategorias(1);

    expect(categorias, hasLength(1));
    expect(await local.leerCache(1), hasLength(1));
  });

  test('listarCategorias usa la caché cuando la API falla', () async {
    await local.guardarCache(1, [_modelo()]);
    remote.error = const ServerException('Sin conexión');

    final categorias = await repository.listarCategorias(1);

    expect(categorias.single.nombre, 'Trabajo');
  });

  test('crearCategoria devuelve el id asignado por la API', () async {
    final creada = await repository.crearCategoria(_modelo(id: 0));

    expect(creada.id, 20);
  });

  test('eliminarCategoria limpia la caché y llama a la API', () async {
    await local.guardarCache(1, [_modelo()]);

    await repository.eliminarCategoria(4);

    expect(remote.idEliminado, 4);
    expect(await local.leerCache(1), isNull);
  });
}
