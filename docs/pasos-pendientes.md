# Pendientes del taller — Fase 1 y Fase 2

> Documento operativo: cada bloque dice **quién** hace qué y **cómo**.
> Estado: PR **#1 a #4** abiertos hacia `develop`. `main` y `develop` siguen en `e6745b0`.

## 0. Estado actual

| PR | Rama | Contenido | Commit |
|---|---|---|---|
| [#1](https://github.com/marulandadeimer-afk/taller-flutter3/pull/1) | `chore/project-config` | SDK `^3.5.0`, versión `0.1.0+1`, permiso INTERNET, `.gitignore` con secretos, metadatos | `591fe57` |
| [#2](https://github.com/marulandadeimer-afk/taller-flutter3/pull/2) | `feature/planner-domain-layer` | Entidades, contratos y 9 casos de uso + 59 pruebas | `cff3407` |
| [#3](https://github.com/marulandadeimer-afk/taller-flutter3/pull/3) | `feature/neon-schema-hardening` | `schema.sql` endurecido + `database/README.md` | `bb9ab38` |
| [#4](https://github.com/marulandadeimer-afk/taller-flutter3/pull/4) | `feature/neon-datasource` | Capa de datos (Dio, models, datasources, repositories) + 41 pruebas | `5514c79` |

Verificación local ya hecha: `flutter analyze` sin issues y `flutter test` **101/101**.

---

## 1. ADMIN del repositorio (`marulandadeimer-afk`)

Solo el dueño puede hacer esto. Sin estos pasos no se cumple el GitFlow del taller.

### 1.1 Agregar a los otros 3 compañeros

`Settings → Collaborators → Add people` → usuario de GitHub → rol **Write**.

⚠️ Cada invitado debe aceptar la invitación (correo o
<https://github.com/marulandadeimer-afk/taller-flutter3/invitations>).
Sin esto **no se pueden conseguir las 2 aprobaciones por PR**.

### 1.2 Proteger `main` y `develop`

`Settings → Branches → Add branch protection rule` (repetir dos veces):

- **Branch name pattern:** `develop` (después `main`)
- ✅ Require a pull request before merging
  - ✅ Require approvals: **2**
  - ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require conversation resolution before merging
- ✅ Do not allow bypassing the above settings
- ❌ Allow force pushes
- ❌ Allow deletions

### 1.3 Aprobar y fusionar los PRs, en este orden

| Orden | PR | Quién aprueba |
|---|---|---|
| 1 | #1 config | Admin + 1 compañero |
| 2 | #2 dominio | Admin + 1 compañero |
| 3 | #3 base de datos | Admin + 1 compañero |
| 4 | #4 capa de datos | Admin + 1 compañero |

Cómo se hace:

1. Abrir el PR → pestaña **Files changed** → **Review changes** → **Approve**.
2. Botón **Merge pull request** → elegir **Create a merge commit**
   (❌ no usar *Squash* ni *Rebase*: el taller evalúa el historial GitFlow).
3. Refrescar el siguiente PR antes de aprobarlo.

⚠️ El #2 contiene el commit del #1 y el #4 contiene el del #2. Al fusionar el #1,
el #2 se limpia solo; al fusionar el #2, se limpia el #4.
⚠️ **No borrar las ramas** hasta cerrar la fase: son evidencia del trabajo por ramas.

---

## 2. Cada integrante (incluido tú)

### 2.1 Configurar la identidad de Git

```bash
git config user.name "Tu Nombre"
git config user.email "tu-correo-de-github@ejemplo.com"
```

El correo debe estar asociado a tu cuenta de GitHub para que el commit te cuente.
Si no quieres exponer tu correo real:

```bash
git config user.email "tu-usuario@users.noreply.github.com"
```

El commit inicial del repo está firmado como `equipo@gestor-agenda.local`, así que
**no le suma a nadie**. Los commits nuevos sí deben ir con identidad real.

### 2.2 Traer el repo y verificar

```bash
git clone https://github.com/marulandadeimer-afk/taller-flutter3.git
cd taller-flutter3
git checkout develop
flutter pub get
flutter analyze
flutter test
```

### 2.3 Revisar los PRs

<https://github.com/marulandadeimer-afk/taller-flutter3/pulls>

Cada integrante debe dejar su **Approve** en los 4 PRs (es parte de la nota).

### 2.4 (Solo tú) revocar el token de GitHub

El token usado para subir estos cambios estuvo escrito en el chat:

`Settings (GitHub) → Developer settings → Personal access tokens (classic) → Delete`

Si hay que seguir trabajando: generar uno nuevo **solo con scope `repo`**.

---

## 3. Cierre de la Fase 1 (release + tag) — Tech Lead

Se ejecuta **cuando los 4 PRs estén en `develop`**:

```powershell
git checkout develop
git pull origin develop

git checkout -b release/v0.1.0
flutter pub get
flutter analyze
flutter test          # deben pasar las 101 pruebas

git checkout main
git pull origin main
git merge --no-ff release/v0.1.0 -m "release: v0.1.0 (Fase 1 - infraestructura, Neon y dominio)"
git tag -a v0.1.0 -m "Fase 1: infraestructura, base de datos Neon y capa de dominio"
git push origin main
git push origin v0.1.0
git push origin develop
```

Comprobar que quedó:

```powershell
git tag -l
git ls-remote --tags origin
```

> Si prefieres, pídeselo a Cline cuando los PRs estén fusionados y lo ejecuta en 5 minutos.

---

## 4. Fase 2 — Base de datos en Neon (Backend & Data Engineer)

### 4.1 Crear el proyecto

1. Entrar a <https://console.neon.tech> → **New Project** → región más cercana.
2. Copiar la **connection string** (la que incluye `-pooler`).
3. ⚠️ **No subirla al repositorio.** Va en un `.env` local (ya está en `.gitignore`)
   o en las variables de entorno del backend.

### 4.2 Ejecutar el esquema

1. En el panel de Neon abrir **SQL Editor**.
2. Pegar el contenido completo de [`database/schema.sql`](../database/schema.sql) y ejecutar.
3. Si las tablas ya existían con la versión anterior del script, ejecutar antes:

```sql
DROP TABLE IF EXISTS eventos, categorias, usuarios CASCADE;
```

### 4.3 Verificar que quedó bien

```sql
-- Tablas creadas
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Restricciones (FK, CHECK, UNIQUE)
SELECT conrelid::regclass AS tabla, conname, pg_get_constraintdef(oid) AS definicion
FROM pg_constraint
WHERE conrelid IN ('usuarios'::regclass, 'categorias'::regclass, 'eventos'::regclass)
ORDER BY 1, conname;

-- Triggers de updated_at
SELECT event_object_table AS tabla, trigger_name
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY tabla;
```

Prueba de integridad (no deja datos, termina en `ROLLBACK`):

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

UPDATE eventos SET titulo = 'Evento editado' WHERE titulo = 'Evento de prueba';
DELETE FROM usuarios WHERE email = 'prueba@correo.com';

SELECT
    (SELECT COUNT(*) FROM usuarios) AS usuarios,
    (SELECT COUNT(*) FROM categorias) AS categorias,
    (SELECT COUNT(*) FROM eventos) AS eventos;

ROLLBACK;
```

Resultado esperado: `usuarios = 0`, `categorias = 0`, `eventos = 0` y **ningún error
de llave foránea** (esto comprueba el arreglo del `ON DELETE CASCADE`).

### 4.4 Exponer la API REST (elegir UNA opción)

**Opción A — Neon Data API / PostgREST** (recomendada: sin backend propio)

1. En el panel de Neon buscar la sección **Data API** y habilitarla.
2. Copiar la **URL base** (termina en `/rest`) y la **anon key**.
3. Probar:

```bash
curl "https://<proyecto>.neon.tech/rest/eventos?select=*&usuario_id=eq.1" \
  -H "apikey: <ANON_KEY>"
```

**Opción B — FastAPI propio**

```bash
# en una carpeta backend/ del repo (todavía no existe; se puede pedir a Cline)
pip install fastapi uvicorn asyncpg
uvicorn main:app --reload --port 3000
```

Variables de entorno del backend: `DATABASE_URL=postgresql://...` (nunca en el repo).
Desplegar en Render/Railway y anotar la URL pública.

El contrato completo de endpoints, cabeceras y JSON está en [`api-rest.md`](api-rest.md).

### 4.5 Probar la app contra la API real

```powershell
flutter run -d chrome `
  --dart-define=API_BASE_URL=https://<proyecto>.neon.tech/rest `
  --dart-define=API_KEY=<ANON_KEY>
```

- `API_BASE_URL` **sin** barra final.
- `API_KEY` es una clave **pública**; nunca la contraseña de Postgres.
- Si no se pasa `API_KEY`, el cliente no envía cabeceras de autorización.

### 4.6 Evidencias para el entregable de la Fase 2

1. Captura del SQL Editor con el script ejecutado sin errores.
2. Resultado de la consulta de tablas (las 3).
3. Resultado de la prueba de integridad (los 3 contadores en 0).
4. Captura del `curl` respondiendo `200` con JSON de eventos.
5. URL de la API y de la app publicadas en el `README.md` (sección *Links de Despliegue*).

---

## 5. Checklist final

### Fase 1

- [ ] Los 3 compañeros agregados como colaboradores
- [ ] `main` y `develop` protegidas (2 aprobaciones, sin bypass)
- [ ] PR #1 aprobado y fusionado
- [ ] PR #2 aprobado y fusionado
- [ ] PR #3 aprobado y fusionado
- [ ] `release/v0.1.0` creada y probada
- [ ] `main` actualizada y tag `v0.1.0` publicado
- [ ] `database/schema.sql` ejecutado en Neon
- [ ] Capturas de evidencia subidas al PR o al README

### Fase 2

- [ ] PR #4 aprobado y fusionado
- [ ] API REST expuesta (Data API o FastAPI) con URL pública
- [ ] `curl` devolviendo eventos reales
- [ ] App ejecutada con `--dart-define=API_BASE_URL=...` contra Neon
- [ ] Sin contraseñas ni tokens en el repositorio
- [ ] `README.md` con los links de despliegue

---

## 6. Recordatorio de GitFlow

- Prohibido `push` directo a `main` o `develop`.
- Cada funcionalidad nace de `develop`: `feature/nombre-tarea`.
- Todo entra a `develop` por **Pull Request con 2 aprobaciones**.
- Al cerrar cada fase: `release/vX.0` → pruebas → merge a `main` → `git tag`.

## 7. Seguridad

- La contraseña de Neon no va al repositorio ni al cliente Flutter.
- `.env` y los keystores ya están en `.gitignore`.
- No exponer `usuarios.password_hash`: usar una vista sin esa columna o RLS.
- Si se usa PostgREST / Data API, activar RLS antes de publicar la web.
- Revocar el token de GitHub usado durante el desarrollo.



