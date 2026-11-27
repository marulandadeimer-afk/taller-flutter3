import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/exceptions.dart';
import 'package:gestor_agenda/features/planner/data/datasources/categoria_remote_data_source.dart';
import 'package:gestor_agenda/features/planner/data/models/categoria_model.dart';

import '../fakes/fake_api_client.dart';

Map<String, dynamic> _fila({int id = 1}) => {
  'id': id,
  'nombre': 'Trabajo',
  'color_hex': '#2196F3',
  'icono': 'event',
  'usuario_id': 1,
};

void main() {
  late FakeApiClient api;
  late CategoriaRemoteDataSourceImpl datasource;

  setUp(() {
    api = FakeApiClient();
    datasource = CategoriaRemoteDataSourceImpl(api);
  });

  test('listarCategorias filtra por usuario y ordena por nombre', () async {
    api.respuesta = [_fila(), _fila(id: 2)];

    final categorias = await datasource.listarCategorias(1);

    expect(categorias, hasLength(2));
    expect(api.llamadas.single, 'GET /categorias');
    expect(api.ultimosParametros!['usuario_id'], 'eq.1');
    expect(api.ultimosParametros!['order'], 'nombre.asc');
  });

  test('listarCategorias falla si la API no devuelve una lista', () async {
    api.respuesta = 'error';

    await expectLater(
      datasource.listarCategorias(1),
      throwsA(isA<ServerException>()),
    );
  });

  test('obtenerCategoriaPorId devuelve NotFoundException si no existe',
      () async {
    api.respuesta = <Object>[];

    await expectLater(
      datasource.obtenerCategoriaPorId(99),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('crearCategoria envía el cuerpo y lee la categoría creada', () async {
    api.respuesta = [_fila(id: 4)];
    final modelo = CategoriaModel.fromJson({..._fila(), 'id': null});

    final creada = await datasource.crearCategoria(modelo);

    expect(creada.id, 4);
    expect((api.ultimoCuerpo! as Map<String, dynamic>)['nombre'], 'Trabajo');
  });

  test('actualizarCategoria exige id', () async {
    final sinId = CategoriaModel.fromJson({..._fila(), 'id': null});

    await expectLater(
      datasource.actualizarCategoria(sinId),
      throwsA(isA<ValidationException>()),
    );
  });

  test('eliminarCategoria usa DELETE filtrado por id', () async {
    await datasource.eliminarCategoria(5);

    expect(api.llamadas.single, 'DELETE /categorias');
    expect(api.ultimosParametros!['id'], 'eq.5');
  });
}
