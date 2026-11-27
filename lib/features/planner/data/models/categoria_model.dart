import '../../domain/entities/categoria.dart';
import 'json_helpers.dart';

/// Modelo de datos de una categoría.
class CategoriaModel extends Categoria {
  const CategoriaModel({
    super.id,
    required super.nombre,
    super.colorHex,
    super.icono,
    required super.usuarioId,
    super.createdAt,
    super.updatedAt,
  });

  /// Construye el modelo desde el JSON de la API.
  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: parseEntero(json['id']),
      nombre: json['nombre'] as String? ?? '',
      colorHex: json['color_hex'] as String? ?? '#2196F3',
      icono: json['icono'] as String? ?? 'event',
      usuarioId: parseEntero(json['usuario_id']) ?? 0,
      createdAt: parseFechaOpcional(json['created_at']),
      updatedAt: parseFechaOpcional(json['updated_at']),
    );
  }

  /// Convierte una entidad de dominio en modelo para enviarla a la API.
  factory CategoriaModel.fromEntity(Categoria categoria) {
    return CategoriaModel(
      id: categoria.id,
      nombre: categoria.nombre,
      colorHex: categoria.colorHex,
      icono: categoria.icono,
      usuarioId: categoria.usuarioId,
      createdAt: categoria.createdAt,
      updatedAt: categoria.updatedAt,
    );
  }

  /// Cuerpo JSON que espera la API (el `id` lo genera la base de datos).
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'color_hex': colorHex,
      'icono': icono,
      'usuario_id': usuarioId,
    };
  }

  /// Devuelve la entidad de dominio (el modelo ya la implementa).
  Categoria toEntity() => this;
}
