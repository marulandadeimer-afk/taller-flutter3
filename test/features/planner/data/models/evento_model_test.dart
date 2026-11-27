import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/exceptions.dart';
import 'package:gestor_agenda/features/planner/data/models/evento_model.dart';
import 'package:gestor_agenda/features/planner/domain/entities/estado_evento.dart';

/// Fila tal como la devuelve PostgREST (`snake_case` y fechas ISO-8601).
Map<String, dynamic> _fila() => {
  'id': 5,
  'titulo': 'Reunión',
  'descripcion': 'Detalle del evento',
  'fecha_inicio': '2026-11-26T08:00:00',
  'fecha_fin': '2026-11-26T09:30:00',
  'ubicacion': 'SENA',
  'estado': 'en_progreso',
  'usuario_id': 1,
  'categoria_id': 2,
  'created_at': '2026-11-25T10:00:00',
  'updated_at': '2026-11-25T10:00:00',
};

void main() {
  test('fromJson mapea la fila de Postgres a la entidad', () {
    final modelo = EventoModel.fromJson(_fila());

    expect(modelo.id, 5);
    expect(modelo.titulo, 'Reunión');
    expect(modelo.descripcion, 'Detalle del evento');
    expect(modelo.estado, EstadoEvento.enProgreso);
    expect(modelo.fechaInicio, DateTime(2026, 11, 26, 8));
    expect(modelo.fechaFin, DateTime(2026, 11, 26, 9, 30));
    expect(modelo.usuarioId, 1);
    expect(modelo.categoriaId, 2);
    expect(modelo.createdAt, DateTime(2026, 11, 25, 10));
  });

  test('tolera ids numéricos enviados como texto', () {
    final modelo = EventoModel.fromJson({..._fila(), 'id': '9'});

    expect(modelo.id, 9);
  });

  test('usa estado pendiente cuando el JSON no trae estado', () {
    final json = Map<String, dynamic>.from(_fila())..remove('estado');

    expect(EventoModel.fromJson(json).estado, EstadoEvento.pendiente);
  });

  test('toJson solo envía las columnas editables', () {
    final json = EventoModel.fromJson(_fila()).toJson();

    expect(json['titulo'], 'Reunión');
    expect(json['estado'], 'en_progreso');
    expect(json['usuario_id'], 1);
    expect(json['categoria_id'], 2);
    expect(json['fecha_inicio'], '2026-11-26T08:00:00.000');
    expect(json.containsKey('id'), isFalse);
    expect(json.containsKey('created_at'), isFalse);
    expect(json.containsKey('updated_at'), isFalse);
  });

  test('lanza ValidationException si falta una fecha obligatoria', () {
    final json = Map<String, dynamic>.from(_fila())..remove('fecha_inicio');

    expect(
      () => EventoModel.fromJson(json),
      throwsA(isA<ValidationException>()),
    );
  });

  test('fromEntity copia todos los campos de la entidad', () {
    final modelo = EventoModel.fromJson(_fila());
    final copia = EventoModel.fromEntity(modelo);

    expect(copia, equals(modelo));
  });

  test('fromJson y toJson son reversibles', () {
    final original = EventoModel.fromJson(_fila());
    final reconstruido = EventoModel.fromJson({
      ...original.toJson(),
      'id': original.id,
    });

    expect(reconstruido.titulo, original.titulo);
    expect(reconstruido.fechaInicio, original.fechaInicio);
    expect(reconstruido.fechaFin, original.fechaFin);
    expect(reconstruido.estado, original.estado);
  });
}
