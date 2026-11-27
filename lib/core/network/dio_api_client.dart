import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'api_client.dart';

/// Implementación de [ApiClient] sobre Dio.
///
/// Traduce los errores HTTP y de red a las excepciones del proyecto, para que
/// la capa de datos nunca vea un `DioException`.
class DioApiClient implements ApiClient {
  DioApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: ApiConstants.connectTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
              listFormat: ListFormat.multi,
              headers: _cabeceras(),
            ),
          );

  final Dio _dio;

  /// `Prefer: return=representation` hace que PostgREST devuelva la fila
  /// insertada o actualizada; otros backends simplemente ignoran la cabecera.
  static Map<String, String> _cabeceras() {
    final clave = ApiConstants.apiKey;
    return {
      'Accept': 'application/json',
      'Prefer': 'return=representation',
      if (clave.isNotEmpty) 'apikey': clave,
      if (clave.isNotEmpty) 'Authorization': 'Bearer $clave',
    };
  }

  @override
  Future<Object?> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _ejecutar(
      () => _dio.get<Object?>(path, queryParameters: queryParameters),
    );
  }

  @override
  Future<Object?> post(String path, {Object? data}) {
    return _ejecutar(() => _dio.post<Object?>(path, data: data));
  }

  @override
  Future<Object?> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _ejecutar(
      () => _dio.patch<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      ),
    );
  }

  @override
  Future<Object?> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _ejecutar(
      () => _dio.delete<Object?>(path, queryParameters: queryParameters),
    );
  }

  Future<Object?> _ejecutar(
    Future<Response<Object?>> Function() peticion,
  ) async {
    try {
      final respuesta = await peticion();
      return respuesta.data;
    } on DioException catch (error) {
      throw _traducir(error);
    }
  }

  AppException _traducir(DioException error) {
    final codigo = error.response?.statusCode;
    final detalle = _detalle(error);

    switch (codigo) {
      case 400:
      case 409:
      case 422:
        return ValidationException(
          'La API rechazó los datos: $detalle',
          code: codigo?.toString(),
        );
      case 401:
      case 403:
        return ServerException(
          'No autorizado para consumir la API: $detalle',
          code: codigo?.toString(),
        );
      case 404:
        return NotFoundException(
          'El recurso solicitado no existe: $detalle',
          code: codigo?.toString(),
        );
      default:
        break;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerException('La API tardó demasiado en responder.');
      case DioExceptionType.connectionError:
        return const ServerException(
          'No fue posible conectarse con la API. Revisa la URL y tu red.',
        );
      default:
        return ServerException(
          'Error de red: $detalle',
          code: codigo?.toString(),
        );
    }
  }

  String _detalle(DioException error) {
    final datos = error.response?.data;
    if (datos is Map && datos['message'] != null) {
      return datos['message'].toString();
    }
    if (datos is String && datos.isNotEmpty) {
      return datos.length > 200 ? datos.substring(0, 200) : datos;
    }
    return error.message ?? 'sin detalle';
  }
}
