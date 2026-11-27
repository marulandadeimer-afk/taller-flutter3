/// Configuración de la API REST que expone el esquema de Neon.
///
/// La URL se inyecta en tiempo de compilación para no versionar entornos ni
/// credenciales:
///
/// ```bash
/// flutter run -d chrome --dart-define=API_BASE_URL=https://mi-proyecto.neon.tech/rest
/// ```
abstract final class ApiConstants {
  /// URL base de la API (PostgREST, Neon Data API o FastAPI).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Clave pública de la API (anon key / JWT) cuando el backend la exige.
  ///
  /// Es una clave pensada para el cliente, **nunca** la contraseña de la base
  /// de datos. Si queda vacía, no se envía ninguna cabecera de autorización.
  static const String apiKey = String.fromEnvironment('API_KEY');

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Rutas de la API. PostgREST expone cada tabla como un recurso.
  static const String eventos = '/eventos';
  static const String categorias = '/categorias';

  /// Usuario usado por la app mientras no exista pantalla de login.
  ///
  /// En la Fase 3 se reemplaza por el usuario autenticado.
  static const int usuarioDemoId = 1;
}
