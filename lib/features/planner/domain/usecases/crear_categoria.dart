import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/categoria.dart';
import '../repositories/categoria_repository.dart';
import 'usecase.dart';

/// Parámetros de [CrearCategoria].
final class CrearCategoriaParams {
  const CrearCategoriaParams({required this.categoria});

  final Categoria categoria;
}

/// Caso de uso: crear una categoría para clasificar eventos.
final class CrearCategoria implements UseCase<Categoria, CrearCategoriaParams> {
  const CrearCategoria(this._repository);

  final CategoriaRepository _repository;

  @override
  Future<Result<Categoria>> call(CrearCategoriaParams params) async {
    final mensajeError = params.categoria.validar();
    if (mensajeError != null) {
      return Err(ValidationFailure(mensajeError));
    }

    try {
      final categoria = await _repository.crearCategoria(params.categoria);
      return Ok(categoria);
    } catch (error) {
      return Err(mapExceptionToFailure(error));
    }
  }
}
