import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/features/planner/domain/entities/estado_evento.dart';
import 'package:gestor_agenda/features/planner/domain/entities/evento.dart';

Evento _eventoBase() => Evento(
  titulo: 'Entrega del taller',
  descripcion: 'Subir el tag v0.1.0',
  fechaInicio: DateTime(2026, 11, 26, 8),
  fechaFin: DateTime(2026, 11, 26, 10),
  ubicacion: 'SENA',
  usuarioId: 1,
  categoriaId: 2,
);

void main() {
  group('Evento.validar', () {
    test('devuelve null cuando el evento cumple todas las reglas', () {
      expect(_eventoBase().validar(), isNull);
    });

    test('exige un título no vacío', () {
      final evento = _eventoBase().copyWith(titulo: '   ');

      expect(evento.validar(), 'El título del evento es obligatorio.');
    });

    test('rechaza títulos de más de 150 caracteres', () {
      final evento = _eventoBase().copyWith(titulo: 'a' * 151);

      expect(evento.validar(), contains('150'));
    });

    test('rechaza una fecha de fin anterior al inicio', () {
      final evento = _eventoBase().copyWith(
        fechaFin: DateTime(2026, 11, 26, 7),
      );

      expect(evento.validar(), contains('fecha de fin'));
    });

    test('exige un usuario válido', () {
      final evento = _eventoBase().copyWith(usuarioId: 0);

      expect(evento.validar(), contains('usuario'));
    });

    test('exige una categoría válida', () {
      final evento = _eventoBase().copyWith(categoriaId: -1);

      expect(evento.validar(), contains('categoría'));
    });

    test('rechaza ubicaciones de más de 200 caracteres', () {
      final evento = _eventoBase().copyWith(ubicacion: 'x' * 201);

      expect(evento.validar(), contains('ubicación'));
    });
  });

  group('Evento.copyWith', () {
    test('conserva los campos no indicados', () {
      final original = _eventoBase();
      final copia = original.copyWith(titulo: 'Otro título');

      expect(copia.titulo, 'Otro título');
      expect(copia.fechaInicio, original.fechaInicio);
      expect(copia.descripcion, original.descripcion);
    });

    test('permite limpiar campos opcionales con null', () {
      final copia = _eventoBase().copyWith(descripcion: null, ubicacion: null);

      expect(copia.descripcion, isNull);
      expect(copia.ubicacion, isNull);
    });
  });

  group('Evento (utilidades)', () {
    test('se compara por valor', () {
      expect(_eventoBase(), equals(_eventoBase()));
      expect(_eventoBase().hashCode, _eventoBase().hashCode);
    });

    test('calcula la duración', () {
      expect(_eventoBase().duracion, const Duration(hours: 2));
    });

    test('detecta solapamiento entre eventos', () {
      final otro = _eventoBase().copyWith(
        fechaInicio: DateTime(2026, 11, 26, 9),
        fechaFin: DateTime(2026, 11, 26, 11),
      );

      expect(_eventoBase().seSolapaCon(otro), isTrue);
    });

    test('no marca solapamiento cuando no se cruzan', () {
      final otro = _eventoBase().copyWith(
        fechaInicio: DateTime(2026, 11, 26, 11),
        fechaFin: DateTime(2026, 11, 26, 12),
      );

      expect(_eventoBase().seSolapaCon(otro), isFalse);
    });

    test('estaVigente es falso en estados finales', () {
      expect(_eventoBase().estaVigente, isTrue);
      expect(
        _eventoBase().copyWith(estado: EstadoEvento.cancelado).estaVigente,
        isFalse,
      );
    });
  });
}
