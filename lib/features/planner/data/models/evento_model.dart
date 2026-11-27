import '../../domain/entities/estado_evento.dart';
import '../../domain/entities/evento.dart';
import 'json_helpers.dart';

/// Modelo de datos de un evento.
///
/// Mapea la fila de la tabla `eventos` (o el JSON que devuelve PostgREST) a la
/// entidad de dominio. Extiende [Evento] para que la conversión sea directa:
/// el modelo **es** una entidad válida y el repositorio no tiene que copiar
/// campo por campo.
class EventoModel extends Evento {
  const EventoModel({
    super.id,
    required super.titulo,
    super.descripcion,
    required super.fechaInicio,
    required super.fechaFin,
    super.ubicacion,
    super.estado,
    required super.usuarioId,
    required super.categoriaId,
    super.createdAt,
    super.updatedAt,
  });

  /// Construye el modelo desde el JSON de la API.
  factory EventoModel.fromJson(Map<String, dynamic> json) {
    return EventoModel(
      id: parseEntero(json['id']),
      titulo: json['titulo'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      fechaInicio: parseFecha(json['fecha_inicio'], campo: 'fecha_inicio'),
      fechaFin: parseFecha(json['fecha_fin'], campo: 'fecha_fin'),
      ubicacion: json['ubicacion'] as String?,
      estado: json['estado'] == null
          ? EstadoEvento.pendiente
          : EstadoEvento.fromDbValue(json['estado'] as String),
      usuarioId: parseEntero(json['usuario_id']) ?? 0,
      categoriaId: parseEntero(json['categoria_id']) ?? 0,
      createdAt: parseFechaOpcional(json['created_at']),
      updatedAt: parseFechaOpcional(json['updated_at']),
    );
  }

  /// Convierte una entidad de dominio en modelo para enviarla a la API.
  factory EventoModel.fromEntity(Evento evento) {
    return EventoModel(
      id: evento.id,
      titulo: evento.titulo,
      descripcion: evento.descripcion,
      fechaInicio: evento.fechaInicio,
      fechaFin: evento.fechaFin,
      ubicacion: evento.ubicacion,
      estado: evento.estado,
      usuarioId: evento.usuarioId,
      categoriaId: evento.categoriaId,
      createdAt: evento.createdAt,
      updatedAt: evento.updatedAt,
    );
  }

  /// Cuerpo JSON que espera la API.
  ///
  /// No se envían `id`, `created_at` ni `updated_at`: los genera la base de
  /// datos. Las fechas van en ISO-8601 sin zona horaria para que coincidan con
  /// las columnas `TIMESTAMP` del esquema.
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'ubicacion': ubicacion,
      'estado': estado.dbValue,
      'usuario_id': usuarioId,
      'categoria_id': categoriaId,
    };
  }

  /// Devuelve la entidad de dominio (el modelo ya la implementa).
  Evento toEntity() => this;
}
