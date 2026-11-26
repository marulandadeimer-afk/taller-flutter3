import 'package:gestor_agenda/core/errors/exceptions.dart';
import 'package:gestor_agenda/features/planner/domain/entities/estado_evento.dart';
import 'package:gestor_agenda/features/planner/domain/entities/evento.dart';
import 'package:gestor_agenda/features/planner/domain/repositories/evento_repository.dart';

/// Repositorio en memoria que implementa el contrato del dominio.
///
/// Permite probar los casos de uso sin Neon, sin red y sin mocks de paquetes
/// externos.
class FakeEventoRepository implements EventoRepository {
  FakeEventoRepository([List<Evento> iniciales = const []])
    : _eventos = [...iniciales];

  final List<Evento> _eventos;

  /// Si se asigna, todos los métodos lanzan esta excepción (simula fallos de
  /// infraestructura).
  Object? excepcion;

  List<Evento> get eventos => List.unmodifiable(_eventos);

  int _siguienteId() {
    var maximo = 0;
    for (final evento in _eventos) {
      final id = evento.id;
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
  Future<List<Evento>> listarEventos({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    EstadoEvento? estado,
  }) async {
    _verificarExcepcion();
    final filtrados = _eventos.where((evento) {
      if (evento.usuarioId != usuarioId) {
        return false;
      }
      if (categoriaId != null && evento.categoriaId != categoriaId) {
        return false;
      }
      if (estado != null && evento.estado != estado) {
        return false;
      }
      if (desde != null && evento.fechaInicio.isBefore(desde)) {
        return false;
      }
      if (hasta != null && evento.fechaInicio.isAfter(hasta)) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    return filtrados;
  }

  @override
  Future<Evento> obtenerEventoPorId(int id) async {
    _verificarExcepcion();
    for (final evento in _eventos) {
      if (evento.id == id) {
        return evento;
      }
    }
    throw NotFoundException('No existe un evento con id $id');
  }

  @override
  Future<Evento> crearEvento(Evento evento) async {
    _verificarExcepcion();
    final creado = evento.copyWith(
      id: _siguienteId(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _eventos.add(creado);
    return creado;
  }

  @override
  Future<Evento> actualizarEvento(Evento evento) async {
    _verificarExcepcion();
    final indice = _eventos.indexWhere((item) => item.id == evento.id);
    if (indice == -1) {
      throw NotFoundException('No existe un evento con id ${evento.id}');
    }
    _eventos[indice] = evento;
    return evento;
  }

  @override
  Future<void> eliminarEvento(int id) async {
    _verificarExcepcion();
    final cantidadAnterior = _eventos.length;
    _eventos.removeWhere((evento) => evento.id == id);
    if (_eventos.length == cantidadAnterior) {
      throw NotFoundException('No existe un evento con id $id');
    }
  }
}
