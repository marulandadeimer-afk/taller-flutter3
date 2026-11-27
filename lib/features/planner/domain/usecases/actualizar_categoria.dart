import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/categoria.dart';
import '../repositories/categoria_repository.dart';
import 'usecase.dart';

/// Parámetros de [ActualizarCategoria].
final class ActualizarCategoriaParams {
  const ActualizarCategoriaParams({required this.categoria});

  final Categoria categoria;
}

/// Caso de uso: actualizar una categoría existente.
final class ActualizarCategoria
    implements UseCase<Categoria, ActualizarCategoriaParams> {
  const ActualizarCategoria(this._repository);

  final CategoriaRepository _repository;

  @override
  Future<Result<Categoria>> call(ActualizarCategoriaParams params) async {
    final categoria = params.categoria;
    if (!categoria.tieneId) {
      return const Err(
        ValidationFailure(
          'La categoría debe tener un id para poder actualizarse.',
        ),
      );
    }

    final mensajeError = categoria.validar();
    if (mensajeError != null) {
      return Err(ValidationFailure(mensajeError));
    }

    try {
      final actualizada = await _repository.actualizarCategoria(categoria);
      return Ok(actualizada);
    } catch (error) {
      return Err(mapExceptionToFailure(error));
    }
  }
}
