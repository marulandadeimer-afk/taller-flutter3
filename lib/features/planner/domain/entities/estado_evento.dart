import '../../../../core/errors/exceptions.dart';

/// Estados posibles de un evento.
///
/// Los valores de [dbValue] coinciden exactamente con el `CHECK` de la tabla
/// `eventos` del esquema de Neon, por lo que se pueden persistir sin
/// traducciones intermedias.
enum EstadoEvento {
  pendiente('pendiente'),
  enProgreso('en_progreso'),
  completado('completado'),
  cancelado('cancelado');

  const EstadoEvento(this.dbValue);

  /// Valor almacenado en la columna `eventos.estado`.
  final String dbValue;

  /// Convierte el valor de la base de datos al enum del dominio.
  ///
  /// Lanza [ValidationException] si el valor no está soportado, para no
  /// propagar datos corruptos desde la capa de datos.
  static EstadoEvento fromDbValue(String value) {
    for (final estado in values) {
      if (estado.dbValue == value) {
        return estado;
      }
    }
    throw ValidationException('Estado de evento no soportado: $value');
  }

  /// `true` cuando el evento ya no admite más cambios de estado.
  bool get esFinal => this == completado || this == cancelado;
}
