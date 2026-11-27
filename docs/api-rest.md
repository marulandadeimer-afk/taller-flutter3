# Contrato de la API REST (Fase 2)

La app Flutter no se conecta directamente a PostgreSQL: consume una API REST
(PostgREST / Neon Data API o FastAPI). Toda la configuración se inyecta en
tiempo de compilación, así que **no hay credenciales en el repositorio**.

## Configuración

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=https://<tu-proyecto>.neon.tech/rest \
  --dart-define=API_KEY=<anon-key-publica>
```

| Variable | Obligatoria | Descripción |
|---|---|---|
| `API_BASE_URL` | Sí | URL base de la API, **sin** barra final |
| `API_KEY` | No | Clave pública (anon key o JWT). Si está vacía no se envían cabeceras de autorización |

> ⚠️ `API_KEY` es una clave pensada para el cliente. **Nunca** pongas aquí la
> contraseña de Postgres ni la cadena de conexión.

## Endpoints que consume la app

### Eventos

| Operación | Petición | Respuesta esperada |
|---|---|---|
| Listar | `GET /eventos?select=*&usuario_id=eq.{id}&order=fecha_inicio.asc` | `[ {...}, {...} ]` |
| Listar con filtros | `GET /eventos?select=*&usuario_id=eq.{id}&categoria_id=eq.{cat}&estado=eq.{estado}&fecha_inicio=gte.{desde}&fecha_inicio=lte.{hasta}` | `[ ... ]` |
| Obtener | `GET /eventos?select=*&id=eq.{id}&limit=1` | `[ { ... } ]` o `[]` |
| Crear | `POST /eventos` | `[ { ...con id... } ]` |
| Actualizar | `PATCH /eventos?id=eq.{id}` | `[ { ...actualizado... } ]` |
| Eliminar | `DELETE /eventos?id=eq.{id}` | `204` sin cuerpo |

### Categorías

| Operación | Petición |
|---|---|
| Listar | `GET /categorias?select=*&usuario_id=eq.{id}&order=nombre.asc` |
| Obtener | `GET /categorias?select=*&id=eq.{id}&limit=1` |
| Crear | `POST /categorias` |
| Actualizar | `PATCH /categorias?id=eq.{id}` |
| Eliminar | `DELETE /categorias?id=eq.{id}` |

## Formato del JSON

Fila de `eventos` tal como la devuelve PostgREST:

```json
{
  "id": 1,
  "titulo": "Entrega del taller",
  "descripcion": "Subir el tag v0.1.0",
  "fecha_inicio": "2026-11-26T08:00:00",
  "fecha_fin": "2026-11-26T10:00:00",
  "ubicacion": "SENA",
  "estado": "pendiente",
  "usuario_id": 1,
  "categoria_id": 2,
  "created_at": "2026-11-25T14:39:43",
  "updated_at": "2026-11-25T14:39:43"
}
```

Cuerpo que **envía** la app al crear o actualizar (sin `id`, `created_at` ni
`updated_at`, porque los genera la base de datos):

```json
{
  "titulo": "Entrega del taller",
  "descripcion": "Subir el tag v0.1.0",
  "fecha_inicio": "2026-11-26T08:00:00.000",
  "fecha_fin": "2026-11-26T10:00:00.000",
  "ubicacion": "SENA",
  "estado": "pendiente",
  "usuario_id": 1,
  "categoria_id": 2
}
```

### Reglas de mapeo (`EventoModel` / `CategoriaModel`)

- `snake_case` en la base de datos ↔ `camelCase` en el dominio.
- Fechas ISO-8601 **sin zona horaria**, porque las columnas son `TIMESTAMP`.
- `estado` acepta `pendiente`, `en_progreso`, `completado`, `cancelado`.
- `id`, `usuario_id` y `categoria_id` se aceptan como `int`, `num` o `String`.
- Un `estado` desconocido lanza `ValidationException` (no se propaga basura).

## Cabeceras que envía el cliente

```text
Accept: application/json
Prefer: return=representation      # hace que PostgREST devuelva la fila creada/actualizada
apikey: <API_KEY>                  # solo si API_KEY está definida
Authorization: Bearer <API_KEY>    # solo si API_KEY está definida
```

## Prueba rápida desde la terminal

```bash
curl "$API_BASE_URL/eventos?select=*&usuario_id=eq.1" -H "apikey: $API_KEY"
```

## Cambiar a FastAPI

Solo se modifica la construcción de `queryParameters` en
`lib/features/planner/data/datasources/*_remote_data_source.dart`. Los modelos,
los repositorios, los casos de uso y la interfaz no cambian, porque todo pasa
por el contrato `ApiClient`.

## Seguridad

- No exponer `usuarios.password_hash` al cliente: usar una vista sin esa
  columna o RLS/permisos en Postgres.
- Si el backend es PostgREST/Data API, habilitar RLS (Row Level Security) antes
  de publicar la app.
- La contraseña de la base de datos vive solo en el backend, nunca en Flutter.
