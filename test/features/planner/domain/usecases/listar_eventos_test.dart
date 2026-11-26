import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/failures.dart';
import 'package:gestor_agenda/features/planner/domain/entities/estado_evento.dart';
import 'package:gestor_agenda/features/planner/domain/entities/evento.dart';
import 'package:gestor_agenda/features/planner/domain/usecases/listar_eventos.dart';

import '../fakes/fake_evento_repository.dart';

Evento _evento({
  required String titulo,
  required DateTime inicio,
  int usuarioId = 1,
  int categoriaId = 1,
  EstadoEvento estado = EstadoEvento.pendiente,
}) => Evento(
  titulo: titulo,
  fechaInicio: inicio,
  fechaFin: inicio.add(const Duration(hours: 1)),
  usuarioId: usuarioId,
  categoriaId: categoriaId,
  estado: estado,
);

void main() {
  late FakeEventoRepository repository;
  late ListarEventos listarEventos;

  setUp(() {
    repository = FakeEventoRepository([
      _evento(titulo: 'Evento A', inicio: DateTime(2026, 11, 26, 8)),
      _evento(
        titulo: 'Evento B',
        inicio: DateTime(2026, 11, 27, 8),
        categoriaId: 2,
        estado: EstadoEvento.completado,
      ),
      _evento(
        titulo: 'Evento de otro usuario',
        inicio: DateTime(2026, 11, 26, 8),
        usuarioId: 2,
      ),
    ]);
    listarEventos = ListarEventos(repository);
  });

  test('lista solo los eventos del usuario indicado', () async {
    final resultado = await listarEventos(
      const ListarEventosParams(usuarioId: 1),
    );

    expect(resultado.isOk, isTrue);
    expect(resultado.valueOrNull, hasLength(2));
    expect(
      resultado.valueOrNull?.map((evento) => evento.titulo),
      isNot(contains('Evento de otro usuario')),
    );
  });

  test('ordena los eventos por fecha de inicio', () async {
    final resultado = await listarEventos(
      const ListarEventosParams(usuarioId: 1),
    );

    expect(
      resultado.valueOrNull?.map((evento) => evento.titulo).toList(),
      ['Evento A', 'Evento B'],
    );
  });

  test('filtra por rango de fechas', () async {
    final resultado = await listarEventos(
      ListarEventosParams(
        usuarioId: 1,
        desde: DateTime(2026, 11, 27),
        hasta: DateTime(2026, 11, 28),
      ),
    );

    expect(resultado.valueOrNull?.single.titulo, 'Evento B');
  });

  test('filtra por categoría y estado', () async {
    final porCategoria = await listarEventos(
      const ListarEventosParams(usuarioId: 1, categoriaId: 2),
    );
    final porEstado = await listarEventos(
      const ListarEventosParams(
        usuarioId: 1,
        estado: EstadoEvento.completado,
      ),
    );

    expect(porCategoria.valueOrNull?.single.titulo, 'Evento B');
    expect(porEstado.valueOrNull?.single.titulo, 'Evento B');
  });

  test('rechaza un usuario inválido', () async {
    final resultado = await listarEventos(
      const ListarEventosParams(usuarioId: 0),
    );

    expect(resultado.failureOrNull, isA<ValidationFailure>());
  });

  test('rechaza un rango de fechas invertido', () async {
    final resultado = await listarEventos(
      ListarEventosParams(
        usuarioId: 1,
        desde: DateTime(2026, 11, 28),
        hasta: DateTime(2026, 11, 27),
      ),
    );

    expect(resultado.failureOrNull, isA<ValidationFailure>());
    expect(resultado.failureOrNull?.message, contains('rango de fechas'));
  });

  test('devuelve una lista vacía cuando el usuario no tiene eventos', () async {
    final resultado = await listarEventos(
      const ListarEventosParams(usuarioId: 3),
    );

    expect(resultado.valueOrNull, isEmpty);
  });
}
