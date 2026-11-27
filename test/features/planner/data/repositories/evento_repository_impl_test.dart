import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/exceptions.dart';
import 'package:gestor_agenda/features/planner/data/datasources/evento_local_data_source.dart';
import 'package:gestor_agenda/features/planner/data/datasources/evento_remote_data_source.dart';
import 'package:gestor_agenda/features/planner/data/models/evento_model.dart';
import 'package:gestor_agenda/features/planner/data/repositories/evento_repository_impl.dart';
import 'package:gestor_agenda/features/planner/domain/entities/estado_evento.dart';

/// Fuente remota controlable.
class _FakeRemote implements EventoRemoteDataSource {
  Object? error;
  List<EventoModel> respuesta = const [];
  EventoModel? eventoEnviado;
  int? idEliminado;

  void _lanzarSiHayError() {
    final fallo = error;
    if (fallo != null) {
      throw fallo;
    }
  }

  @override
  Future<List<EventoModel>> listarEventos({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    EstadoEvento? estado,
  }) async {
    _lanzarSiHayError();
    return respuesta;
  }

  @override
  Future<EventoModel> obtenerEventoPorId(int id) async {
    _lanzarSiHayError();
    for (final evento in respuesta) {
      if (evento.id == id) {
        return evento;
      }
    }
    throw NotFoundException('No existe el evento $id');
  }

  @override
  Future<EventoModel> crearEvento(EventoModel evento) async {
    _lanzarSiHayError();
    return EventoModel.fromEntity(evento.copyWith(id: 10));
  }

  @override
  Future<EventoModel> actualizarEvento(EventoModel evento) async {
    _lanzarSiHayError();
    eventoEnviado = evento;
    return evento;
  }

  @override
  Future<void> eliminarEvento(int id) async {
    _lanzarSiHayError();
    idEliminado = id;
  }
}

EventoModel _modelo({int id = 1}) => EventoModel(
  id: id,
  titulo: 'Reunión',
  fechaInicio: DateTime(2026, 11, 26, 8),
  fechaFin: DateTime(2026, 11, 26, 9),
  usuarioId: 1,
  categoriaId: 2,
);

void main() {
  late _FakeRemote remote;
  late EventoLocalDataSourceEnMemoria local;
  late EventoRepositoryImpl repository;

  setUp(() {
    remote = _FakeRemote();
    local = EventoLocalDataSourceEnMemoria();
    repository = EventoRepositoryImpl(remote, local);
  });

  test('listarEventos guarda el resultado en la caché', () async {
    remote.respuesta = [_modelo()];

    final eventos = await repository.listarEventos(usuarioId: 1);

    expect(eventos, hasLength(1));
    expect(await local.leerCache(1), hasLength(1));
  });

  test('listarEventos devuelve la caché si la API falla', () async {
    await local.guardarCache(1, [_modelo()]);
    remote.error = const ServerException('Sin conexión');

    final eventos = await repository.listarEventos(usuarioId: 1);

    expect(eventos, hasLength(1));
    expect(eventos.single.titulo, 'Reunión');
  });

  test('listarEventos relanza el error si no hay caché', () async {
    remote.error = const ServerException('Sin conexión');

    await expectLater(
      repository.listarEventos(usuarioId: 1),
      throwsA(isA<ServerException>()),
    );
  });

  test('obtenerEventoPorId devuelve la entidad de dominio', () async {
    remote.respuesta = [_modelo(id: 3)];

    final evento = await repository.obtenerEventoPorId(3);

    expect(evento.id, 3);
    expect(evento.usuarioId, 1);
  });

  test('crearEvento envía el modelo y devuelve el id asignado por la API',
      () async {
    final creado = await repository.crearEvento(_modelo());

    expect(creado.id, 10);
  });

  test('actualizarEvento invalida la caché del usuario', () async {
    await local.guardarCache(1, [_modelo()]);

    await repository.actualizarEvento(_modelo());

    expect(await local.leerCache(1), isNull);
    expect(remote.eventoEnviado?.id, 1);
  });

  test('eliminarEvento delega en la fuente remota y limpia la caché',
      () async {
    await local.guardarCache(1, [_modelo()]);

    await repository.eliminarEvento(5);

    expect(remote.idEliminado, 5);
    expect(await local.leerCache(1), isNull);
  });
}
