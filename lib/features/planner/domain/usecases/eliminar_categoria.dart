import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/categoria_repository.dart';
import 'usecase.dart';

/// Parámetros de [EliminarCategoria].
final class EliminarCategoriaParams {
  const EliminarCategoriaParams(this.id);

  final int id;
}

/// Caso de uso: eliminar una categoría.
///
/// En el esquema de Neon la llave foránea de eventos usa `ON DELETE CASCADE`,
/// así que eliminar una categoría elimina también sus eventos.
final class EliminarCategoria
    implements UseCase<void, EliminarCategoriaParams> {
  const EliminarCategoria(this._repository);

  final CategoriaRepository _repository;

  @override
  Future<Result<void>> call(EliminarCategoriaParams params) async {
    if (params.id <= 0) {
      return const Err(ValidationFailure('El id de la categoría no es válido.'));
    }

    try {
      await _repository.eliminarCategoria(params.id);
      return const Ok<void>(null);
    } catch (error) {
      return Err(mapExceptionToFailure(error));
    }
  }
}
