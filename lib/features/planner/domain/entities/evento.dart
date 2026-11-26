import 'estado_evento.dart';

/// Entidad de negocio pura: no depende de Flutter, de JSON ni de la base de
/// datos.
///
/// [id] es nulo mientras el evento no haya sido persistido; `usuarioId` y
/// `categoriaId` son obligatorios porque el esquema de Neon los declara
/// `NOT NULL` con llave foránea.
class Evento {
  const Evento({
    this.id,
    required this.titulo,
    this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    this.ubicacion,
    this.estado = EstadoEvento.pendiente,
    required this.usuarioId,
    required this.categoriaId,
    this.createdAt,
    this.updatedAt,
  });

  /// Centinela para distinguir "no modificar" de "asignar null" en [copyWith].
  static const Object _sinCambios = Object();

  final int? id;
  final String titulo;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? ubicacion;
  final EstadoEvento estado;
  final int usuarioId;
  final int categoriaId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get tieneId => id != null;

  bool get estaVigente => !estado.esFinal;

  Duration get duracion => fechaFin.difference(fechaInicio);

  bool get fechasCoherentes => !fechaFin.isBefore(fechaInicio);

  /// `true` si los dos eventos ocupan al menos un instante en común.
  bool seSolapaCon(Evento otro) =>
      fechaInicio.isBefore(otro.fechaFin) && otro.fechaInicio.isBefore(fechaFin);

  /// Devuelve el primer error de validación o `null` si la entidad es válida.
  ///
  /// Estas reglas replican las restricciones del esquema SQL para fallar
  /// rápido, sin esperar el viaje a la base de datos.
  String? validar() {
    final tituloLimpio = titulo.trim();
    if (tituloLimpio.isEmpty) {
      return 'El título del evento es obligatorio.';
    }
    if (tituloLimpio.length > 150) {
      return 'El título no puede superar 150 caracteres.';
    }
    if (!fechasCoherentes) {
      return 'La fecha de fin no puede ser anterior a la fecha de inicio.';
    }
    if (usuarioId <= 0) {
      return 'El evento debe pertenecer a un usuario válido.';
    }
    if (categoriaId <= 0) {
      return 'El evento debe tener una categoría válida.';
    }
    final ubicacionLimpia = ubicacion?.trim();
    if (ubicacionLimpia != null && ubicacionLimpia.length > 200) {
      return 'La ubicación no puede superar 200 caracteres.';
    }
    return null;
  }

  /// Copia el evento cambiando solo los campos indicados.
  ///
  /// `descripcion` y `ubicacion` usan un centinela para permitir limpiarlas:
  /// `evento.copyWith(descripcion: null)`.
  Evento copyWith({
    int? id,
    String? titulo,
    Object? descripcion = _sinCambios,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    Object? ubicacion = _sinCambios,
    EstadoEvento? estado,
    int? usuarioId,
    int? categoriaId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Evento(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: identical(descripcion, _sinCambios)
          ? this.descripcion
          : descripcion as String?,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      ubicacion: identical(ubicacion, _sinCambios)
          ? this.ubicacion
          : ubicacion as String?,
      estado: estado ?? this.estado,
      usuarioId: usuarioId ?? this.usuarioId,
      categoriaId: categoriaId ?? this.categoriaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Evento &&
        other.id == id &&
        other.titulo == titulo &&
        other.descripcion == descripcion &&
        other.fechaInicio == fechaInicio &&
        other.fechaFin == fechaFin &&
        other.ubicacion == ubicacion &&
        other.estado == estado &&
        other.usuarioId == usuarioId &&
        other.categoriaId == categoriaId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    titulo,
    descripcion,
    fechaInicio,
    fechaFin,
    ubicacion,
    estado,
    usuarioId,
    categoriaId,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'Evento(id: $id, titulo: $titulo, estado: ${estado.dbValue})';
}
