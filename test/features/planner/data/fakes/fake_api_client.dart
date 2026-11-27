import 'package:gestor_agenda/core/network/api_client.dart';

/// Doble de prueba de [ApiClient]: devuelve respuestas controladas y registra
/// cómo se llamó a la API.
class FakeApiClient implements ApiClient {
  /// Respuesta que devolverán los métodos (JSON ya decodificado).
  Object? respuesta;

  /// Si se asigna, todos los métodos la lanzan.
  Object? error;

  /// Llamadas realizadas, con el formato `GET /eventos`.
  final List<String> llamadas = [];

  Map<String, dynamic>? ultimosParametros;
  Object? ultimoCuerpo;

  Object? _responder(
    String metodo,
    String ruta,
    Map<String, dynamic>? parametros,
    Object? cuerpo,
  ) {
    llamadas.add('$metodo $ruta');
    ultimosParametros = parametros;
    ultimoCuerpo = cuerpo;

    final fallo = error;
    if (fallo != null) {
      throw fallo;
    }
    return respuesta;
  }

  @override
  Future<Object?> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _responder('GET', path, queryParameters, null);
  }

  @override
  Future<Object?> post(String path, {Object? data}) async {
    return _responder('POST', path, null, data);
  }

  @override
  Future<Object?> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _responder('PATCH', path, queryParameters, data);
  }

  @override
  Future<Object?> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _responder('DELETE', path, queryParameters, null);
  }
}
