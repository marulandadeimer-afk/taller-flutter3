import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/errors/failures.dart';
import 'package:gestor_agenda/features/planner/domain/entities/categoria.dart';
import 'package:gestor_agenda/features/planner/domain/usecases/actualizar_categoria.dart';
import 'package:gestor_agenda/features/planner/domain/usecases/crear_categoria.dart';
import 'package:gestor_agenda/features/planner/domain/usecases/eliminar_categoria.dart';
import 'package:gestor_agenda/features/planner/domain/usecases/listar_categorias.dart';

import '../fakes/fake_categoria_repository.dart';

void main() {
  late FakeCategoriaRepository repository;
  late CrearCategoria crearCategoria;
  late ListarCategorias listarCategorias;
  late ActualizarCategoria actualizarCategoria;
  late EliminarCategoria eliminarCategoria;

  setUp(() {
    repository = FakeCategoriaRepository();
    crearCategoria = CrearCategoria(repository);
    listarCategorias = ListarCategorias(repository);
    actualizarCategoria = ActualizarCategoria(repository);
    eliminarCategoria = EliminarCategoria(repository);
  });

  group('CrearCategoria', () {
    test('crea la categoría y devuelve el id asignado', () async {
      final resultado = await crearCategoria(
        const CrearCategoriaParams(
          categoria: Categoria(nombre: 'Trabajo', usuarioId: 1),
        ),
      );

      expect(resultado.valueOrNull?.id, 1);
      expect(repository.categorias, hasLength(1));
    });

    test('rechaza un color que no cumple el formato', () async {
      final resultado = await crearCategoria(
        const CrearCategoriaParams(
          categoria: Categoria(
            nombre: 'Trabajo',
            colorHex: 'rojo',
            usuarioId: 1,
          ),
        ),
      );

      expect(resultado.failureOrNull, isA<ValidationFailure>());
      expect(repository.categorias, isEmpty);
    });
  });

  group('ListarCategorias', () {
    test('lista solo las categorías del usuario', () async {
      await repository.crearCategoria(
        const Categoria(nombre: 'Trabajo', usuarioId: 1),
      );
      await repository.crearCategoria(
        const Categoria(nombre: 'Personal', usuarioId: 1),
      );
      await repository.crearCategoria(
        const Categoria(nombre: 'Otra', usuarioId: 2),
      );

      final resultado = await listarCategorias(
        const ListarCategoriasParams(usuarioId: 1),
      );

      expect(resultado.valueOrNull, hasLength(2));
      expect(
        resultado.valueOrNull?.map((categoria) => categoria.nombre),
        isNot(contains('Otra')),
      );
    });

    test('rechaza un usuario inválido', () async {
      final resultado = await listarCategorias(
        const ListarCategoriasParams(usuarioId: 0),
      );

      expect(resultado.failureOrNull, isA<ValidationFailure>());
    });
  });

  group('ActualizarCategoria', () {
    test('actualiza una categoría existente', () async {
      final creada = await repository.crearCategoria(
        const Categoria(nombre: 'Trabajo', usuarioId: 1),
      );

      final resultado = await actualizarCategoria(
        ActualizarCategoriaParams(categoria: creada.copyWith(nombre: 'Oficina')),
      );

      expect(resultado.valueOrNull?.nombre, 'Oficina');
      expect(repository.categorias.single.nombre, 'Oficina');
    });

    test('falla si la categoría no tiene id', () async {
      final resultado = await actualizarCategoria(
        const ActualizarCategoriaParams(
          categoria: Categoria(nombre: 'Trabajo', usuarioId: 1),
        ),
      );

      expect(resultado.failureOrNull, isA<ValidationFailure>());
      expect(resultado.failureOrNull?.message, contains('id'));
    });
  });

  group('EliminarCategoria', () {
    test('elimina la categoría indicada', () async {
      final creada = await repository.crearCategoria(
        const Categoria(nombre: 'Trabajo', usuarioId: 1),
      );

      final resultado = await eliminarCategoria(
        EliminarCategoriaParams(creada.id!),
      );

      expect(resultado.isOk, isTrue);
      expect(repository.categorias, isEmpty);
    });

    test('rechaza ids inválidos', () async {
      final resultado = await eliminarCategoria(
        const EliminarCategoriaParams(0),
      );

      expect(resultado.failureOrNull, isA<ValidationFailure>());
    });
  });
}
