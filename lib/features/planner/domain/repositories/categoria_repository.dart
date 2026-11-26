import '../entities/categoria.dart';

/// Contrato del repositorio de categorías.
///
/// Igual que [EventoRepository], es una interfaz pura: no conoce Neon, Dio ni
/// ningún detalle de infraestructura.
abstract interface class CategoriaRepository {
  /// Lista las categorías de un usuario.
  Future<List<Categoria>> listarCategorias(int usuarioId);

  /// Obtiene una categoría por id o lanza `NotFoundException`.
  Future<Categoria> obtenerCategoriaPorId(int id);

  /// Persiste una categoría nueva y la devuelve con el id asignado.
  Future<Categoria> crearCategoria(Categoria categoria);

  /// Actualiza una categoría existente y devuelve la versión persistida.
  Future<Categoria> actualizarCategoria(Categoria categoria);

  /// Elimina la categoría indicada.
  Future<void> eliminarCategoria(int id);
}
