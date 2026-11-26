import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/categoria.dart';
import '../repositories/categoria_repository.dart';
import 'usecase.dart';

/// Parámetros de [ListarCategorias].
final class ListarCategoriasParams {
  const ListarCategoriasParams({required this.usuarioId});

  final int usuarioId;
}

/// Caso de uso: listar las categorías de un usuario.
final class ListarCategorias
    implements UseCase<List<Categoria>, ListarCategoriasParams> {
  const ListarCategorias(this._repository);

  final CategoriaRepository _repository;

  @override
  Future<Result<List<Categoria>>> call(ListarCategoriasParams params) async {
    if (params.usuarioId <= 0) {
      return const Err(ValidationFailure('El usuario no es válido.'));
    }

    try {
      final categorias = await _repository.listarCategorias(params.usuarioId);
      return Ok(categorias);
    } catch (error) {
      return Err(mapExceptionToFailure(error));
    }
  }
}
