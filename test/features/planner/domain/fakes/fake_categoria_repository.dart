import 'package:gestor_agenda/core/errors/exceptions.dart';
import 'package:gestor_agenda/features/planner/domain/entities/categoria.dart';
import 'package:gestor_agenda/features/planner/domain/repositories/categoria_repository.dart';

/// Repositorio en memoria que implementa el contrato del dominio.
class FakeCategoriaRepository implements CategoriaRepository {
  FakeCategoriaRepository([List<Categoria> iniciales = const []])
    : _categorias = [...iniciales];

  final List<Categoria> _categorias;

  /// Si se asigna, todos los métodos lanzan esta excepción.
  Object? excepcion;

  List<Categoria> get categorias => List.unmodifiable(_categorias);

  int _siguienteId() {
    var maximo = 0;
    for (final categoria in _categorias) {
      final id = categoria.id;
      if (id != null && id > maximo) {
        maximo = id;
      }
    }
    return maximo + 1;
  }

  void _verificarExcepcion() {
    final error = excepcion;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<List<Categoria>> listarCategorias(int usuarioId) async {
    _verificarExcepcion();
    return _categorias
        .where((categoria) => categoria.usuarioId == usuarioId)
        .toList();
  }

  @override
  Future<Categoria> obtenerCategoriaPorId(int id) async {
    _verificarExcepcion();
    for (final categoria in _categorias) {
      if (categoria.id == id) {
        return categoria;
      }
    }
    throw NotFoundException('No existe una categoría con id $id');
  }

  @override
  Future<Categoria> crearCategoria(Categoria categoria) async {
    _verificarExcepcion();
    final creada = categoria.copyWith(id: _siguienteId());
    _categorias.add(creada);
    return creada;
  }

  @override
  Future<Categoria> actualizarCategoria(Categoria categoria) async {
    _verificarExcepcion();
    final indice = _categorias.indexWhere((item) => item.id == categoria.id);
    if (indice == -1) {
      throw NotFoundException('No existe una categoría con id ${categoria.id}');
    }
    _categorias[indice] = categoria;
    return categoria;
  }

  @override
  Future<void> eliminarCategoria(int id) async {
    _verificarExcepcion();
    final cantidadAnterior = _categorias.length;
    _categorias.removeWhere((categoria) => categoria.id == id);
    if (_categorias.length == cantidadAnterior) {
      throw NotFoundException('No existe una categoría con id $id');
    }
  }
}
