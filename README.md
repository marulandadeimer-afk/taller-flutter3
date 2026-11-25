# Taller 3: Flutter "Gestor de Agenda"

Aplicación móvil y web en Flutter diseñada bajo **Clean Architecture**, con base de datos en **Neon (PostgreSQL Serverless)** y flujo colaborativo **GitFlow**.

## Links de Despliegue

- **API REST:** `Por definir en Fase 2`
- **Aplicación Web:** `Por definir en Fase 3`

## Estructura Clean Architecture

```text
database/
└── schema.sql                # Script DDL para Neon (usuarios, categorias, eventos)
lib/
├── core/
│   ├── constants/            # URLs de API, claves, rutas
│   ├── errors/               # Manejo de excepciones y Failures
│   ├── network/              # Cliente HTTP (Dio/Http) y estado de red
│   └── utils/                # Formateadores de fecha, validadores
├── features/
│   └── planner/
│       ├── data/
│       │   ├── datasources/  # Conexión remota (API/Neon) y local (caché)
│       │   ├── models/       # Mapeo JSON <-> Entidad (fromJson / toJson)
│       │   └── repositories/ # Implementación de los contratos de dominio
│       ├── domain/
│       │   ├── entities/     # Objetos de negocio puros
│       │   ├── repositories/ # Interfaces / Contratos abstractos
│       │   └── usecases/     # Casos de uso
│       └── presentation/
│           ├── bloc/         # Gestión de estado (Bloc / Riverpod / Provider)
│           ├── pages/        # Pantallas completas
│           └── widgets/      # Componentes reutilizables
└── main.dart
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
