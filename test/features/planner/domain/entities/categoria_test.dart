import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/features/planner/domain/entities/categoria.dart';

Categoria _categoriaBase() => const Categoria(nombre: 'Trabajo', usuarioId: 1);

void main() {
  group('Categoria.validar', () {
    test('acepta una categoría válida', () {
      expect(_categoriaBase().validar(), isNull);
    });

    test('exige un nombre no vacío', () {
      final categoria = _categoriaBase().copyWith(nombre: '   ');

      expect(categoria.validar(), contains('nombre'));
    });

    test('rechaza nombres de más de 80 caracteres', () {
      final categoria = _categoriaBase().copyWith(nombre: 'a' * 81);

      expect(categoria.validar(), contains('80'));
    });

    test('rechaza colores que no son #RRGGBB', () {
      expect(
        _categoriaBase().copyWith(colorHex: 'azul').validar(),
        contains('#RRGGBB'),
      );
      expect(_categoriaBase().copyWith(colorHex: '#12345').tieneColorValido, isFalse);
      expect(_categoriaBase().copyWith(colorHex: '#12345').validar(), isNotNull);
    });

    test('acepta colores válidos en mayúsculas y minúsculas', () {
      expect(_categoriaBase().copyWith(colorHex: '#ff8800').validar(), isNull);
      expect(_categoriaBase().copyWith(colorHex: '#FF8800').validar(), isNull);
    });

    test('exige un ícono no vacío', () {
      final categoria = _categoriaBase().copyWith(icono: ' ');

      expect(categoria.validar(), contains('ícono'));
    });

    test('exige un usuario válido', () {
      final categoria = _categoriaBase().copyWith(usuarioId: 0);

      expect(categoria.validar(), contains('usuario'));
    });
  });

  group('Categoria.copyWith', () {
    test('conserva los valores no indicados', () {
      final copia = _categoriaBase().copyWith(nombre: 'Personal');

      expect(copia.nombre, 'Personal');
      expect(copia.colorHex, '#2196F3');
      expect(copia.icono, 'event');
      expect(copia.usuarioId, 1);
    });

    test('se compara por valor', () {
      expect(_categoriaBase(), equals(_categoriaBase()));
      expect(_categoriaBase().hashCode, _categoriaBase().hashCode);
    });
  });
}
