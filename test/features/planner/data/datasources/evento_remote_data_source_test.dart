import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/exceptions.dart';
import 'package:gestor_agenda/features/planner/data/datasources/evento_remote_data_source.dart';
import 'package:gestor_agenda/features/planner/data/models/evento_model.dart';
import 'package:gestor_agenda/features/planner/domain/entities/estado_evento.dart';

import '../fakes/fake_api_client.dart';

Map<String, dynamic> _fila({int id = 1}) => {
  'id': id,
  'titulo': 'Reunión',
  'descripcion': null,
  'fecha_inicio': '2026-11-26T08:00:00',
  'fecha_fin': '2026-11-26T09:00:00',
  'ubicacion': null,
  'estado': 'pendiente',
  'usuario_id': 1,
  'categoria_id': 2,
};

void main() {
  late FakeApiClient api;
  late EventoRemoteDataSourceImpl datasource;

  setUp(() {
    api = FakeApiClient();
    datasource = EventoRemoteDataSourceImpl(api);
  });

  group('listarEventos', () {
    test('arma los filtros con la convención de PostgREST', () async {
      api.respuesta = [_fila()];

      final eventos = await datasource.listarEventos(
        usuarioId: 1,
        desde: DateTime(2026, 11, 26),
        hasta: DateTime(2026, 11, 30),
        categoriaId: 2,
        estado: EstadoEvento.pendiente,
      );

      expect(eventos, hasLength(1));
      expect(api.llamadas.single, 'GET /eventos');

      final parametros = api.ultimosParametros!;
      expect(parametros['select'], '*');
      expect(parametros['usuario_id'], 'eq.1');
      expect(parametros['categoria_id'], 'eq.2');
      expect(parametros['estado'], 'eq.pendiente');
      expect(parametros['fecha_inicio'], [
        'gte.2026-11-26T00:00:00.000',
        'lte.2026-11-30T00:00:00.000',
      ]);
      expect(parametros['order'], 'fecha_inicio.asc');
    });

    test('omite los filtros opcionales cuando no se envían', () async {
      api.respuesta = [_fila()];

      await datasource.listarEventos(usuarioId: 7);

      final parametros = api.ultimosParametros!;
      expect(parametros['usuario_id'], 'eq.7');
      expect(parametros.containsKey('categoria_id'), isFalse);
      expect(parametros.containsKey('fecha_inicio'), isFalse);
    });

    test('falla si la API no devuelve una lista', () async {
      api.respuesta = {'detalle': 'error'};

      await expectLater(
        datasource.listarEventos(usuarioId: 1),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('obtenerEventoPorId', () {
    test('acepta una lista de un elemento (formato PostgREST)', () async {
      api.respuesta = [_fila(id: 7)];

      final evento = await datasource.obtenerEventoPorId(7);

      expect(evento.id, 7);
      expect(api.ultimosParametros!['id'], 'eq.7');
      expect(api.ultimosParametros!['limit'], 1);
    });

    test('acepta un objeto suelto (formato FastAPI)', () async {
      api.respuesta = _fila(id: 8);

      expect((await datasource.obtenerEventoPorId(8)).id, 8);
    });

    test('lanza NotFoundException cuando la lista viene vacía', () async {
      api.respuesta = <Object>[];

      await expectLater(
        datasource.obtenerEventoPorId(3),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('escritura', () {
    test('crearEvento envía el cuerpo y lee el registro creado', () async {
      api.respuesta = [_fila(id: 11)];
      final modelo = EventoModel.fromJson({..._fila(), 'id': null});

      final creado = await datasource.crearEvento(modelo);

      expect(creado.id, 11);
      expect(api.llamadas.single, 'POST /eventos');
      final cuerpo = api.ultimoCuerpo! as Map<String, dynamic>;
      expect(cuerpo['titulo'], 'Reunión');
      expect(cuerpo['usuario_id'], 1);
    });

    test('actualizarEvento exige id y usa PATCH con filtro', () async {
      final sinId = EventoModel.fromJson({..._fila(), 'id': null});

      await expectLater(
        datasource.actualizarEvento(sinId),
        throwsA(isA<ValidationException>()),
      );

      api.respuesta = [_fila(id: 4)];
      await datasource.actualizarEvento(EventoModel.fromJson(_fila(id: 4)));

      expect(api.llamadas.last, 'PATCH /eventos');
      expect(api.ultimosParametros!['id'], 'eq.4');
    });

    test('eliminarEvento usa DELETE filtrado por id', () async {
      await datasource.eliminarEvento(9);

      expect(api.llamadas.single, 'DELETE /eventos');
      expect(api.ultimosParametros!['id'], 'eq.9');
    });
  });

  test('propaga los errores del cliente HTTP', () async {
    api.error = const ServerException('sin red');

    await expectLater(
      datasource.listarEventos(usuarioId: 1),
      throwsA(isA<ServerException>()),
    );
  });
}
