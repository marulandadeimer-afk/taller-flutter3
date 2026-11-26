import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/failures.dart';
import 'package:gestor_agenda/features/planner/domain/entities/evento.dart';
import 'package:gestor_agenda/features/planner/domain/usecases/obtener_evento.dart';

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
  late ObtenerEvento obtenerEvento;

  setUp(() {
    repository = FakeEventoRepository();
    obtenerEvento = ObtenerEvento(repository);
  });

  test('devuelve el evento solicitado', () async {
    final creado = await repository.crearEvento(_evento());

    final resultado = await obtenerEvento(
      ObtenerEventoParams(creado.id!),
    );

    expect(resultado.valueOrNull, equals(creado));
  });

  test('rechaza ids inválidos', () async {
    final resultado = await obtenerEvento(const ObtenerEventoParams(-5));

    expect(resultado.failureOrNull, isA<ValidationFailure>());
  });

  test('devuelve NotFoundFailure cuando el evento no existe', () async {
    final resultado = await obtenerEvento(const ObtenerEventoParams(7));

    expect(resultado.failureOrNull, isA<NotFoundFailure>());
  });
}
