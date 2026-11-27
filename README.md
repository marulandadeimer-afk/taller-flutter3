# Taller 3: Flutter "Gestor de Agenda"

Aplicación móvil y web en Flutter diseñada bajo **Clean Architecture**, con base de datos en **Neon (PostgreSQL Serverless)** y flujo colaborativo **GitFlow**.

## Links de Despliegue

- **API REST:** `Por definir en Fase 2`
- **Aplicación Web:** `Por definir en Fase 3`

## Estructura Clean Architecture

```text
database/
├── schema.sql                # Script DDL para Neon (usuarios, categorias, eventos)
└── README.md                 # Pasos de despliegue en Neon y verificación
lib/
├── core/
│   ├── constants/            # URLs de API, claves, rutas
│   ├── errors/               # Exceptions, Failures y su traducción
│   ├── network/              # ApiClient + DioApiClient (HTTP)
│   └── utils/                # Result, formateadores de fecha, validadores
├── features/
│   └── planner/
│       ├── data/
│       │   ├── datasources/  # Fuente remota (REST) y local (caché)
│       │   ├── models/       # EventoModel, CategoriaModel (fromJson/toJson)
│       │   └── repositories/ # EventoRepositoryImpl, CategoriaRepositoryImpl
│       ├── domain/
│       │   ├── entities/     # Evento, Categoria, Usuario, EstadoEvento
│       │   ├── repositories/ # Contratos abstractos de eventos y categorías
│       │   └── usecases/     # CRUD de agenda + contrato UseCase
│       └── presentation/
│           ├── bloc/         # Gestión de estado (Bloc / Riverpod / Provider)
│           ├── pages/        # Pantallas completas
│           └── widgets/      # Componentes reutilizables
└── main.dart
test/
├── features/planner/domain/  # Pruebas unitarias de entidades y casos de uso
└── widget_test.dart          # Prueba de humo de la aplicación
```


## Base de Datos (Neon PostgreSQL)

1. Crear un proyecto en [Neon.tech](https://neon.tech/).
2. Abrir el **SQL Editor** del proyecto.
3. Ejecutar el contenido de [`database/schema.sql`](database/schema.sql) para crear las tablas `usuarios`, `categorias` y `eventos` (estructura base sin datos).

## Roles y Ramas (GitFlow)

| Rol / Aprendiz | Rama Asignada | Responsabilidad Técnica |
|---|---|---|
| 1. Tech Lead / DevOps | `develop` & `release/*` | Configuración inicial, reglas de protección de ramas, revisión de PRs y despliegue SQL en Neon. |
| 2. Backend & Data Engineer | `feature/neon-datasource` | Tablas en Neon, API REST y capa `data/datasources` y `models`. |
| 3. Domain Architect | `feature/domain-layer` | Entidades, contratos de repositorios y casos de uso en `domain/`. |
| 4. UI/UX & Core Widgets | `feature/ui-components` | `ThemeData` y componentes reutilizables en `presentation/widgets`. |
| 5. State & Integration Dev | `feature/presentation-logic` | Estado, pantallas (`pages/`) e inyección de dependencias (`get_it`). |

### Reglas de GitFlow

- Prohibido hacer `push` directo a `main` o `develop`.
- Toda nueva funcionalidad nace desde `develop` con el formato `feature/nombre-tarea`.
- Cada integración hacia `develop` requiere Pull Request aprobado por al menos 2 compañeros (incluyendo el Tech Lead).
- Al finalizar cada fase, se crea `release/vX.0` antes de fusionar a `main` con su etiqueta (`git tag`).

## Plataformas Soportadas

Proyecto inicializado únicamente para **Android** y **Web** (`--platforms=android,web`).

---

## Estado por fases

| Fase | Alcance | Estado |
|---|---|---|
| 1 | Infraestructura, base de datos Neon y capa de dominio | ✅ Completada (entrega con tag `v0.1.0`) |
| 2 | Capa de datos e integración con Neon | ✅ Implementada (falta desplegar la API y probar contra Neon) |
| 3 | Presentación, estado y despliegue web | ⏳ Pendiente |

## Cómo ejecutar

Requisitos: Flutter **3.35 o superior** (Dart 3.5+).

```bash
flutter pub get          # instala las dependencias
flutter test             # ejecuta las pruebas unitarias
flutter run -d chrome    # ejecuta en el navegador
flutter run -d android   # ejecuta en un emulador o dispositivo
```

## Capa de dominio (Fase 1)

La carpeta `lib/features/planner/domain/` **no importa Flutter, Dio, `json_serializable` ni ninguna otra dependencia externa**: solo Dart puro y `core/`.

**Entidades** (objetos de negocio inmutables, con `copyWith`, `==` y validación propia):

| Entidad | Reglas de validación principales |
|---|---|
| `Evento` | título obligatorio (máx. 150), `fechaFin >= fechaInicio`, usuario y categoría válidos, ubicación máx. 200 |
| `Categoria` | nombre obligatorio (máx. 80), color `#RRGGBB`, ícono obligatorio, usuario válido |
| `Usuario` | nombre obligatorio (máx. 100), correo con formato válido |
| `EstadoEvento` | `pendiente`, `en_progreso`, `completado`, `cancelado` (coinciden con el `CHECK` de la tabla `eventos`) |

**Contratos de repositorio:** `EventoRepository` y `CategoriaRepository` declaran el CRUD. La implementación real llega en la Fase 2, dentro de `data/repositories`.

**Casos de uso** (todos implementan `UseCase<Salida, Entrada>`):

| Eventos | Categorías |
|---|---|
| `CrearEvento` | `CrearCategoria` |
| `ActualizarEvento` | `ActualizarCategoria` |
| `EliminarEvento` | `EliminarCategoria` |
| `ListarEventos` (filtra por rango de fechas, categoría y estado) | `ListarCategorias` |
| `ObtenerEvento` | — |

**Manejo de errores:** los casos de uso devuelven `Result<T>`, que puede ser `Ok<T>(valor)` o `Err<T>(Failure)`. Las excepciones de infraestructura (`ServerException`, `DatabaseException`, `NotFoundException`, etc.) se traducen con `mapExceptionToFailure`, de modo que la interfaz nunca captura excepciones de Dio o de Postgres.

```dart
final resultado = await crearEvento(CrearEventoParams(evento: evento));

resultado.fold(
  onOk: (evento) => mostrarEvento(evento),
  onErr: (failure) => mostrarError(failure.message),
);
```

## Capa de datos (Fase 2)

- `core/network/api_client.dart` define el contrato HTTP y `dio_api_client.dart` lo implementa con **Dio**, traduciendo errores HTTP/red a `ServerException`, `ValidationException`, `NotFoundException`, etc.
- `data/models/` convierte el JSON de PostgREST (`snake_case`, fechas ISO-8601) a las entidades de dominio.
- `data/datasources/` contiene la fuente **remota** (API REST) y la **local** (caché en memoria).
- `data/repositories/` implementa `EventoRepository` y `CategoriaRepository`; si la API falla con `ServerException`, devuelve la última lista cacheada en lugar de romper la pantalla.

### Configurar la URL de la API

La URL no se versiona: se inyecta en tiempo de compilación.

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=https://<tu-proyecto>.neon.tech/rest \
  --dart-define=API_KEY=<anon-key-publica>
```

`API_KEY` es opcional y solo debe contener una clave pública (nunca la contraseña de Postgres). El contrato completo de endpoints, cabeceras y ejemplos de JSON está en [`docs/api-rest.md`](docs/api-rest.md).

## Pruebas

```bash
flutter test                # 101 pruebas unitarias
flutter test --coverage     # genera coverage/lcov.info
```

Las pruebas de `test/features/planner/domain/` y `test/features/planner/data/` usan repositorios y clientes HTTP falsos (`fakes/`): no necesitan red, Neon ni mocks de paquetes externos.


## Base de datos

El detalle del despliegue, las restricciones de integridad y la verificación del esquema están en [`database/README.md`](database/README.md).

