import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/exceptions.dart';
import 'package:gestor_agenda/core/errors/failures.dart';
import 'package:gestor_agenda/features/planner/domain/entities/evento.dart';
import 'package:gestor_agenda/features/planner/domain/usecases/actualizar_evento.dart';

import '../fakes/fake_evento_repository.dart';

Evento _evento({int? id}) => Evento(
  id: id,
  titulo: 'Reunión de equipo',
  fechaInicio: DateTime(2026, 11, 26, 8),
  fechaFin: DateTime(2026, 11, 26, 9),
  usuarioId: 1,
  categoriaId: 1,
);

void main() {
  late FakeEventoRepository repository;
  late ActualizarEvento actualizarEvento;

  setUp(() {
    repository = FakeEventoRepository();
    actualizarEvento = ActualizarEvento(repository);
  });

  test('actualiza un evento existente', () async {
    final creado = await repository.crearEvento(_evento());
    final resultado = await actualizarEvento(
      ActualizarEventoParams(evento: creado.copyWith(titulo: 'Actualizado')),
    );

    expect(resultado.isOk, isTrue);
    expect(resultado.valueOrNull?.titulo, 'Actualizado');
    expect(repository.eventos.single.titulo, 'Actualizado');
  });

  test('falla si el evento no tiene id', () async {
    final resultado = await actualizarEvento(
      ActualizarEventoParams(evento: _evento()),
    );

    expect(resultado.failureOrNull, isA<ValidationFailure>());
    expect(resultado.failureOrNull?.message, contains('id'));
  });

  test('vuelve a validar los datos editados', () async {
    final creado = await repository.crearEvento(_evento());
    final resultado = await actualizarEvento(
      ActualizarEventoParams(evento: creado.copyWith(titulo: ' ')),
    );

    expect(resultado.failureOrNull, isA<ValidationFailure>());
  });

  test('traduce NotFoundException a NotFoundFailure', () async {
    final resultado = await actualizarEvento(
      ActualizarEventoParams(evento: _evento(id: 99)),
    );

    expect(resultado.failureOrNull, isA<NotFoundFailure>());
  });

  test('traduce ServerException a ServerFailure', () async {
    repository.excepcion = const ServerException('API caída');

    final resultado = await actualizarEvento(
      ActualizarEventoParams(evento: _evento(id: 1)),
    );

    expect(resultado.failureOrNull, isA<ServerFailure>());
  });
}
