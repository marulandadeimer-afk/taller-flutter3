import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/exceptions.dart';
import 'package:gestor_agenda/core/errors/failures.dart';
import 'package:gestor_agenda/features/planner/data/datasources/evento_local_data_source.dart';
import 'package:gestor_agenda/features/planner/data/datasources/evento_remote_data_source.dart';
import 'package:gestor_agenda/features/planner/data/repositories/evento_repository_impl.dart';
import 'package:gestor_agenda/features/planner/domain/entities/evento.dart';
import 'package:gestor_agenda/features/planner/domain/usecases/crear_evento.dart';
import 'package:gestor_agenda/features/planner/domain/usecases/listar_eventos.dart';

import 'fakes/fake_api_client.dart';

/// Prueba de integración de la capa de datos: recorre el camino completo
/// (caso de uso → repositorio → datasource → JSON de la API → entidad) sin
/// tocar la red.
Map<String, dynamic> _fila({
  int id = 1,
  String titulo = 'Reunión',
}) => {
  'id': id,
  'titulo': titulo,
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
  late EventoRepositoryImpl repositorio;

  setUp(() {
    api = FakeApiClient();
    repositorio = EventoRepositoryImpl(
      EventoRemoteDataSourceImpl(api),
      EventoLocalDataSourceEnMemoria(),
    );
  });

  test('crear un evento desde el caso de uso hasta el POST de la API',
      () async {
    api.respuesta = [_fila(id: 1)];
    final crearEvento = CrearEvento(repositorio);

    final resultado = await crearEvento(
      CrearEventoParams(
        evento: Evento(
          titulo: 'Reunión',
          fechaInicio: DateTime(2026, 11, 26, 8),
          fechaFin: DateTime(2026, 11, 26, 9),
          usuarioId: 1,
          categoriaId: 2,
        ),
      ),
    );

    expect(resultado.isOk, isTrue);
    expect(resultado.valueOrNull?.id, 1);
    expect(api.llamadas.single, 'POST /eventos');
    final cuerpo = api.ultimoCuerpo! as Map<String, dynamic>;
    expect(cuerpo['titulo'], 'Reunión');
    expect(cuerpo['usuario_id'], 1);
    expect(cuerpo['categoria_id'], 2);
  });

  test('listar eventos con conexión y luego sin conexión (caché)',
      () async {
    api.respuesta = [_fila(id: 1), _fila(id: 2, titulo: 'Entrega')];
    final listarEventos = ListarEventos(repositorio);

    final conRed = await listarEventos(const ListarEventosParams(usuarioId: 1));
    expect(conRed.valueOrNull, hasLength(2));

    api.error = const ServerException('Sin conexión');
    final sinRed = await listarEventos(const ListarEventosParams(usuarioId: 1));

    expect(sinRed.isOk, isTrue);
    expect(sinRed.valueOrNull, hasLength(2));
    expect(sinRed.valueOrNull?.last.titulo, 'Entrega');
  });

  test('un 404 de la API llega al dominio como NotFoundFailure', () async {
    api.respuesta = <Object>[];
    final listarEventos = ListarEventos(repositorio);
    api.error = const NotFoundException('No existe');

    final resultado = await listarEventos(
      const ListarEventosParams(usuarioId: 1),
    );

    expect(resultado.failureOrNull, isA<NotFoundFailure>());
  });
}
