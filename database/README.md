# Base de datos (Neon PostgreSQL)

Esquema de la Fase 1: tablas `usuarios`, `categorias` y `eventos`, con llaves
foráneas, restricciones `NOT NULL`, `TIMESTAMP`, `CHECK` e índices para las
consultas de la agenda.

## 1. Crear el proyecto en Neon

1. Entrar a [neon.tech](https://neon.tech/) e iniciar sesión.
2. **New Project** → elegir la región más cercana (por ejemplo `AWS us-east-1`).
3. Guardar la **connection string** que muestra el asistente. Tiene esta forma:

   ```text
   postgresql://USUARIO:PASSWORD@ep-xxxx-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require
   ```

   - **Con `-pooler`**: recomendada para una API serverless (PostgREST/FastAPI).
   - **Sin `-pooler`**: conexión directa, útil para migraciones y para el editor SQL.

4. ⚠️ La cadena de conexión es un secreto. **Nunca** se sube al repositorio:
   va en un `.env` local (ya está en `.gitignore`) y en las variables de entorno
   de la API.

## 2. Ejecutar el esquema

1. En el panel de Neon abrir **SQL Editor**.
2. Pegar el contenido completo de [`schema.sql`](schema.sql) y ejecutarlo.
3. Si las tablas ya existían con la versión anterior del script, ejecutar
   primero:

   ```sql
   DROP TABLE IF EXISTS eventos, categorias, usuarios CASCADE;
   ```

El script es idempotente (`CREATE TABLE IF NOT EXISTS`, `CREATE OR REPLACE
FUNCTION`, `DROP TRIGGER IF EXISTS`), así que se puede volver a ejecutar sin
romper nada.

## 3. Verificar que quedó bien

```sql
-- 3.1 Tablas creadas
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- 3.2 Restricciones (llaves foráneas, checks y únicos)
SELECT conrelid::regclass AS tabla, conname, pg_get_constraintdef(oid) AS definicion
FROM pg_constraint
WHERE conrelid IN ('usuarios'::regclass, 'categorias'::regclass, 'eventos'::regclass)
ORDER BY 1, conname;

-- 3.3 Trigger de updated_at
SELECT event_object_table AS tabla, trigger_name
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY tabla;
```

Prueba de integridad de punta a punta (no deja datos: termina en `ROLLBACK`):

```sql
BEGIN;

WITH nuevo_usuario AS (
    INSERT INTO usuarios (nombre, email, password_hash)
    VALUES ('Usuario de prueba', 'prueba@correo.com', 'hash-de-prueba')
    RETURNING id
), nueva_categoria AS (
    INSERT INTO categorias (nombre, usuario_id)
    SELECT 'Trabajo', id FROM nuevo_usuario
    RETURNING id
)
INSERT INTO eventos (titulo, fecha_inicio, fecha_fin, usuario_id, categoria_id)
SELECT 'Evento de prueba', NOW(), NOW() + INTERVAL '1 hour', u.id, c.id
FROM nuevo_usuario u, nueva_categoria c;

-- El trigger debe actualizar updated_at
UPDATE eventos SET titulo = 'Evento editado' WHERE titulo = 'Evento de prueba';

-- Borrar el usuario debe borrar en cascada su categoria y su evento
DELETE FROM usuarios WHERE email = 'prueba@correo.com';

SELECT
    (SELECT COUNT(*) FROM usuarios) AS usuarios,
    (SELECT COUNT(*) FROM categorias) AS categorias,
    (SELECT COUNT(*) FROM eventos) AS eventos;

ROLLBACK;
```

Resultado esperado: `usuarios = 0`, `categorias = 0`, `eventos = 0` y ningún
error de llave foránea.

## 4. Modelo de datos

| Tabla | Columnas principales | Reglas de integridad |
|---|---|---|
| `usuarios` | `id`, `nombre`, `email`, `password_hash`, `created_at`, `updated_at` | `email` único sin distinguir mayúsculas (`LOWER(email)`), `updated_at` por trigger |
| `categorias` | `id`, `nombre`, `color_hex`, `icono`, `usuario_id`, `created_at`, `updated_at` | FK a `usuarios` con `ON DELETE CASCADE`, `(usuario_id, nombre)` único, color `#RRGGBB` |
| `eventos` | `id`, `titulo`, `descripcion`, `fecha_inicio`, `fecha_fin`, `ubicacion`, `estado`, `usuario_id`, `categoria_id`, `created_at`, `updated_at` | FKs a `usuarios` y `categorias` con `ON DELETE CASCADE`, `fecha_fin >= fecha_inicio`, `estado` dentro del catálogo permitido |

Estados permitidos en `eventos.estado`: `pendiente`, `en_progreso`,
`completado`, `cancelado`. Coinciden con el enum `EstadoEvento` de la capa de
dominio (`lib/features/planner/domain/entities/estado_evento.dart`).

## 5. Evidencia para el entregable de la Fase 1

Adjuntar en el PR o en el README del equipo:

1. Captura del SQL Editor con el script ejecutado sin errores.
2. Resultado de la consulta 3.1 (las tres tablas).
3. Resultado de la prueba de integridad del punto 3 (los tres contadores en 0).
4. Captura del proyecto de Neon con el nombre y la región (sin mostrar la
   cadena de conexión ni la contraseña).
