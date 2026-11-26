/// Entidad de negocio pura que clasifica los eventos de un usuario.
class Categoria {
  const Categoria({
    this.id,
    required this.nombre,
    this.colorHex = '#2196F3',
    this.icono = 'event',
    required this.usuarioId,
    this.createdAt,
    this.updatedAt,
  });

  /// Centinela para distinguir "no modificar" de "asignar null" en [copyWith].
  static const Object _sinCambios = Object();

  static final RegExp _colorPattern = RegExp(r'^#[0-9A-Fa-f]{6}$');

  final int? id;
  final String nombre;

  /// Color en formato `#RRGGBB` (columna `categorias.color_hex`).
  final String colorHex;

  /// Nombre del ícono de Material (columna `categorias.icono`).
  final String icono;

  final int usuarioId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get tieneId => id != null;

  bool get tieneColorValido => _colorPattern.hasMatch(colorHex);

  /// Devuelve el primer error de validación o `null` si la entidad es válida.
  String? validar() {
    final nombreLimpio = nombre.trim();
    if (nombreLimpio.isEmpty) {
      return 'El nombre de la categoría es obligatorio.';
    }
    if (nombreLimpio.length > 80) {
      return 'El nombre de la categoría no puede superar 80 caracteres.';
    }
    if (!tieneColorValido) {
      return 'El color debe tener el formato hexadecimal #RRGGBB.';
    }
    final iconoLimpio = icono.trim();
    if (iconoLimpio.isEmpty) {
      return 'El ícono de la categoría es obligatorio.';
    }
    if (iconoLimpio.length > 50) {
      return 'El ícono de la categoría no puede superar 50 caracteres.';
    }
    if (usuarioId <= 0) {
      return 'La categoría debe pertenecer a un usuario válido.';
    }
    return null;
  }

  Categoria copyWith({
    int? id,
    String? nombre,
    String? colorHex,
    String? icono,
    int? usuarioId,
    Object? createdAt = _sinCambios,
    Object? updatedAt = _sinCambios,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      colorHex: colorHex ?? this.colorHex,
      icono: icono ?? this.icono,
      usuarioId: usuarioId ?? this.usuarioId,
      createdAt: identical(createdAt, _sinCambios)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _sinCambios)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Categoria &&
        other.id == id &&
        other.nombre == nombre &&
        other.colorHex == colorHex &&
        other.icono == icono &&
        other.usuarioId == usuarioId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, colorHex, icono, usuarioId, createdAt, updatedAt);

  @override
  String toString() => 'Categoria(id: $id, nombre: $nombre)';
}
