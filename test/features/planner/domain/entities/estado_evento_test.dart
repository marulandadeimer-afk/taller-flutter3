import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/exceptions.dart';
import 'package:gestor_agenda/features/planner/domain/entities/estado_evento.dart';

void main() {
  test('convierte todos los valores usados en la base de datos', () {
    expect(EstadoEvento.fromDbValue('pendiente'), EstadoEvento.pendiente);
    expect(EstadoEvento.fromDbValue('en_progreso'), EstadoEvento.enProgreso);
    expect(EstadoEvento.fromDbValue('completado'), EstadoEvento.completado);
    expect(EstadoEvento.fromDbValue('cancelado'), EstadoEvento.cancelado);
  });

  test('lanza ValidationException cuando el valor no está soportado', () {
    expect(
      () => EstadoEvento.fromDbValue('archivado'),
      throwsA(isA<ValidationException>()),
    );
  });

  test('solo completado y cancelado son estados finales', () {
    expect(EstadoEvento.pendiente.esFinal, isFalse);
    expect(EstadoEvento.enProgreso.esFinal, isFalse);
    expect(EstadoEvento.completado.esFinal, isTrue);
    expect(EstadoEvento.cancelado.esFinal, isTrue);
  });

  test('los dbValue coinciden con el CHECK de la tabla eventos', () {
    expect(
      EstadoEvento.values.map((estado) => estado.dbValue).toList(),
      ['pendiente', 'en_progreso', 'completado', 'cancelado'],
    );
  });
}
