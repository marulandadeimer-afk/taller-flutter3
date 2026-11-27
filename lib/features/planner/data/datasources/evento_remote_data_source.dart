import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/estado_evento.dart';
import '../models/evento_model.dart';

/// Acceso remoto a los eventos sobre la API REST de Neon.
abstract interface class EventoRemoteDataSource {
  Future<List<EventoModel>> listarEventos({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    EstadoEvento? estado,
  });

  Future<EventoModel> obtenerEventoPorId(int id);

  Future<EventoModel> crearEvento(EventoModel evento);

  Future<EventoModel> actualizarEvento(EventoModel evento);

  Future<void> eliminarEvento(int id);
}

/// Implementación sobre [ApiClient] usando la convención de PostgREST
/// (también compatible con Neon Data API y con una API FastAPI equivalente).
class EventoRemoteDataSourceImpl implements EventoRemoteDataSource {
  const EventoRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<EventoModel>> listarEventos({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
    EstadoEvento? estado,
  }) async {
    final filtrosFecha = <String>[
      if (desde != null) 'gte.${desde.toIso8601String()}',
      if (hasta != null) 'lte.${hasta.toIso8601String()}',
    ];

    final datos = await _apiClient.get(
      ApiConstants.eventos,
      queryParameters: {
        'select': '*',
        'usuario_id': 'eq.$usuarioId',
        if (categoriaId != null) 'categoria_id': 'eq.$categoriaId',
        if (estado != null) 'estado': 'eq.${estado.dbValue}',
        if (filtrosFecha.isNotEmpty) 'fecha_inicio': filtrosFecha,
        'order': 'fecha_inicio.asc',
      },
    );

    if (datos is! List) {
      throw const ServerException('La API no devolvió una lista de eventos.');
    }
    return datos.map(_aModelo).toList();
  }

  @override
  Future<EventoModel> obtenerEventoPorId(int id) async {
    final datos = await _apiClient.get(
      ApiConstants.eventos,
      queryParameters: {'select': '*', 'id': 'eq.$id', 'limit': 1},
    );

    final evento = _aModeloUnico(datos);
    if (evento == null) {
      throw NotFoundException('No existe un evento con id $id.');
    }
    return evento;
  }

  @override
  Future<EventoModel> crearEvento(EventoModel evento) async {
    final datos = await _apiClient.post(
      ApiConstants.eventos,
      data: evento.toJson(),
    );

    final creado = _aModeloUnico(datos);
    if (creado == null) {
      throw const ServerException('La API no devolvió el evento creado.');
    }
    return creado;
  }

  @override
  Future<EventoModel> actualizarEvento(EventoModel evento) async {
    final id = evento.id;
    if (id == null) {
      throw const ValidationException(
        'No se puede actualizar un evento que no tiene id.',
      );
    }

    final datos = await _apiClient.patch(
      ApiConstants.eventos,
      queryParameters: {'id': 'eq.$id'},
      data: evento.toJson(),
    );

    final actualizado = _aModeloUnico(datos);
    if (actualizado == null) {
      throw NotFoundException('No existe un evento con id $id.');
    }
    return actualizado;
  }

  @override
  Future<void> eliminarEvento(int id) async {
    await _apiClient.delete(
      ApiConstants.eventos,
      queryParameters: {'id': 'eq.$id'},
    );
  }

  EventoModel _aModelo(Object? item) {
    if (item is Map<String, dynamic>) {
      return EventoModel.fromJson(item);
    }
    throw const ServerException('Formato de evento inválido en la respuesta.');
  }

  /// PostgREST devuelve una lista incluso al insertar o consultar un solo
  /// registro; se aceptan ambos formatos para no depender del backend.
  EventoModel? _aModeloUnico(Object? datos) {
    if (datos is List) {
      if (datos.isEmpty) {
        return null;
      }
      return _aModelo(datos.first);
    }
    if (datos == null) {
      return null;
    }
    return _aModelo(datos);
  }
}
