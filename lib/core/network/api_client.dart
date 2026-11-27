/// Contrato mínimo del cliente HTTP que consume la API REST de Neon.
///
/// Existe para que la capa de datos no dependa directamente de Dio: en las
/// pruebas se reemplaza por un doble que devuelve JSON controlado.
abstract interface class ApiClient {
  Future<Object?> get(String path, {Map<String, dynamic>? queryParameters});

  Future<Object?> post(String path, {Object? data});

  Future<Object?> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  });

  Future<Object?> delete(String path, {Map<String, dynamic>? queryParameters});
}
