import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/exceptions.dart';
import 'package:gestor_agenda/core/errors/failures.dart';
import 'package:gestor_agenda/features/planner/domain/entities/evento.dart';
import 'package:gestor_agenda/features/planner/domain/usecases/crear_evento.dart';

import '../fakes/fake_evento_repository.dart';

Evento _eventoValido() => Evento(
  titulo: 'Reunión de equipo',
  descripcion: 'Revisión del taller',
  fechaInicio: DateTime(2026, 11, 26, 8),
  fechaFin: DateTime(2026, 11, 26, 9),
  usuarioId: 1,
  categoriaId: 1,
);

void main() {
  late FakeEventoRepository repository;
  late CrearEvento crearEvento;

  setUp(() {
    repository = FakeEventoRepository();
    crearEvento = CrearEvento(repository);
  });

  test('crea el evento y devuelve Ok con el id asignado', () async {
    final resultado = await crearEvento(
      CrearEventoParams(evento: _eventoValido()),
    );

    expect(resultado.isOk, isTrue);
    expect(resultado.valueOrNull?.id, 1);
    expect(repository.eventos, hasLength(1));
  });

  test('devuelve ValidationFailure si el título está vacío', () async {
    final resultado = await crearEvento(
      CrearEventoParams(evento: _eventoValido().copyWith(titulo: '   ')),
    );

    expect(resultado.isErr, isTrue);
    expect(resultado.failureOrNull, isA<ValidationFailure>());
    expect(repository.eventos, isEmpty);
  });

  test('devuelve ValidationFailure si la fecha de fin es anterior al inicio',
      () async {
    final resultado = await crearEvento(
      CrearEventoParams(
        evento: _eventoValido().copyWith(
          fechaFin: DateTime(2026, 11, 26, 7),
        ),
      ),
    );

    expect(resultado.failureOrNull?.message, contains('fecha de fin'));
    expect(repository.eventos, isEmpty);
  });

  test('traduce las excepciones de infraestructura a ServerFailure', () async {
    repository.excepcion = const ServerException('Sin conexión');

    final resultado = await crearEvento(
      CrearEventoParams(evento: _eventoValido()),
    );

    expect(resultado.failureOrNull, isA<ServerFailure>());
  });

  test('fold permite manejar éxito y error con un solo punto de salida',
      () async {
    final resultado = await crearEvento(
      CrearEventoParams(evento: _eventoValido()),
    );

    final mensaje = resultado.fold(
      onOk: (evento) => 'Evento ${evento.id} creado',
      onErr: (failure) => 'Error: ${failure.message}',
    );

    expect(mensaje, 'Evento 1 creado');
  });
}
