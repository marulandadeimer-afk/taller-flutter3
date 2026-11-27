import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/features/planner/data/models/categoria_model.dart';

Map<String, dynamic> _fila() => {
  'id': 2,
  'nombre': 'Trabajo',
  'color_hex': '#FF8800',
  'icono': 'work',
  'usuario_id': 1,
  'created_at': '2026-11-25T10:00:00',
  'updated_at': '2026-11-25T10:00:00',
};

void main() {
  test('fromJson mapea la fila de Postgres a la entidad', () {
    final modelo = CategoriaModel.fromJson(_fila());

    expect(modelo.id, 2);
    expect(modelo.nombre, 'Trabajo');
    expect(modelo.colorHex, '#FF8800');
    expect(modelo.icono, 'work');
    expect(modelo.usuarioId, 1);
    expect(modelo.tieneColorValido, isTrue);
  });

  test('usa los valores por defecto del esquema cuando faltan columnas', () {
    final modelo = CategoriaModel.fromJson({
      'id': 3,
      'nombre': 'Personal',
      'usuario_id': 1,
    });

    expect(modelo.colorHex, '#2196F3');
    expect(modelo.icono, 'event');
  });

  test('toJson envía solo las columnas editables', () {
    final json = CategoriaModel.fromJson(_fila()).toJson();

    expect(json['nombre'], 'Trabajo');
    expect(json['color_hex'], '#FF8800');
    expect(json['icono'], 'work');
    expect(json['usuario_id'], 1);
    expect(json.containsKey('id'), isFalse);
  });

  test('fromEntity copia todos los campos', () {
    final modelo = CategoriaModel.fromJson(_fila());

    expect(CategoriaModel.fromEntity(modelo), equals(modelo));
  });
}
