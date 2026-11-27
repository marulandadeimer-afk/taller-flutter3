/// Usuario dueño de la agenda.
///
/// La contraseña y su hash **no** forman parte de la entidad de dominio: la
/// autenticación se resuelve en la capa de datos y nunca debe viajar a la
/// interfaz.
class Usuario {
  const Usuario({
    this.id,
    required this.nombre,
    required this.email,
    this.createdAt,
  });

  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  final int? id;
  final String nombre;
  final String email;
  final DateTime? createdAt;

  bool get tieneId => id != null;

  bool get tieneEmailValido => _emailPattern.hasMatch(email.trim());

  /// Devuelve el primer error de validación o `null` si la entidad es válida.
  String? validar() {
    if (nombre.trim().isEmpty) {
      return 'El nombre del usuario es obligatorio.';
    }
    if (nombre.trim().length > 100) {
      return 'El nombre del usuario no puede superar 100 caracteres.';
    }
    if (!tieneEmailValido) {
      return 'El correo electrónico no tiene un formato válido.';
    }
    if (email.trim().length > 150) {
      return 'El correo electrónico no puede superar 150 caracteres.';
    }
    return null;
  }

  Usuario copyWith({
    int? id,
    String? nombre,
    String? email,
    DateTime? createdAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Usuario &&
        other.id == id &&
        other.nombre == nombre &&
        other.email == email &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, nombre, email, createdAt);

  @override
  String toString() => 'Usuario(id: $id, nombre: $nombre, email: $email)';
}
