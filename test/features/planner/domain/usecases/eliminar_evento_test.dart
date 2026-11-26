import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/exceptions.dart';
import 'package:gestor_agenda/core/errors/failures.dart';
import 'package:gestor_agenda/features/planner/domain/entities/evento.dart';
import 'package:gestor_agenda/features/planner/domain/usecases/eliminar_evento.dart';

import '../fakes/fake_evento_repository.dart';

Evento _evento() => Evento(
  titulo: 'Reunión de equipo',
  fechaInicio: DateTime(2026, 11, 26, 8),
  fechaFin: DateTime(2026, 11, 26, 9),
  usuarioId: 1,
  categoriaId: 1,
);

void main() {
  late FakeEventoRepository repository;
  late EliminarEvento eliminarEvento;

  setUp(() {
    repository = FakeEventoRepository();
    eliminarEvento = EliminarEvento(repository);
  });

  test('elimina el evento indicado', () async {
    final creado = await repository.crearEvento(_evento());

    final resultado = await eliminarEvento(
      EliminarEventoParams(creado.id!),
    );

    expect(resultado.isOk, isTrue);
    expect(repository.eventos, isEmpty);
  });

  test('rechaza ids inválidos sin tocar el repositorio', () async {
    await repository.crearEvento(_evento());

    final resultado = await eliminarEvento(const EliminarEventoParams(0));

    expect(resultado.failureOrNull, isA<ValidationFailure>());
    expect(repository.eventos, hasLength(1));
  });

  test('traduce NotFoundException a NotFoundFailure', () async {
    final resultado = await eliminarEvento(const EliminarEventoParams(42));

    expect(resultado.failureOrNull, isA<NotFoundFailure>());
  });

  test('traduce ServerException a ServerFailure', () async {
    repository.excepcion = const ServerException('Sin conexión');

    final resultado = await eliminarEvento(const EliminarEventoParams(1));

    expect(resultado.failureOrNull, isA<ServerFailure>());
  });
}
