import '../../../../core/errors/exceptions.dart';

/// Lee un entero tolerando `int`, `num` o `String`: PostgREST y FastAPI no
/// siempre devuelven el mismo tipo para las columnas `SERIAL`.
int? parseEntero(Object? valor) {
  if (valor == null) {
    return null;
  }
  if (valor is int) {
    return valor;
  }
  if (valor is num) {
    return valor.toInt();
  }
  if (valor is String) {
    return int.tryParse(valor);
  }
  return null;
}

/// Lee una fecha ISO-8601 obligatoria del JSON.
DateTime parseFecha(Object? valor, {required String campo}) {
  final fecha = parseFechaOpcional(valor);
  if (fecha == null) {
    throw ValidationException(
      'El campo "$campo" es obligatorio y debe venir en formato ISO-8601.',
    );
  }
  return fecha;
}

/// Lee una fecha ISO-8601 opcional (columnas `created_at` / `updated_at`).
DateTime? parseFechaOpcional(Object? valor) {
  if (valor == null) {
    return null;
  }
  if (valor is DateTime) {
    return valor;
  }
  if (valor is String && valor.isNotEmpty) {
    final fecha = DateTime.tryParse(valor);
    if (fecha == null) {
      throw ValidationException(
        'Fecha inválida: "$valor". Se esperaba formato ISO-8601.',
      );
    }
    return fecha;
  }
  return null;
}
