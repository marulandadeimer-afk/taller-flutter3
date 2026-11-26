-- ============================================================================
-- Taller 3: Flutter "Gestor de Agenda"
-- Esquema DDL para Neon (PostgreSQL Serverless) - version 0.1.0
--
-- Uso: abrir el SQL Editor del proyecto en Neon y ejecutar el archivo completo.
--
-- Si las tablas ya existian con una version anterior de este script (que no
-- tenia el trigger de updated_at ni los indices nuevos), ejecutar antes:
--   DROP TABLE IF EXISTS eventos, categorias, usuarios CASCADE;
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Funcion generica para mantener actualizado el campo updated_at
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- usuarios
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Un correo no puede repetirse, sin importar el uso de mayusculas/minusculas.
CREATE UNIQUE INDEX IF NOT EXISTS uq_usuarios_email
    ON usuarios (LOWER(email));

DROP TRIGGER IF EXISTS trg_usuarios_updated_at ON usuarios;
CREATE TRIGGER trg_usuarios_updated_at
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------------
-- categorias
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categorias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    color_hex VARCHAR(7) NOT NULL DEFAULT '#2196F3',
    icono VARCHAR(50) NOT NULL DEFAULT 'event',
    usuario_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_categorias_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE CASCADE,
    CONSTRAINT uq_categorias_usuario_nombre
        UNIQUE (usuario_id, nombre),
    CONSTRAINT chk_categorias_color
        CHECK (color_hex ~ '^#[0-9A-Fa-f]{6}$')
);

DROP TRIGGER IF EXISTS trg_categorias_updated_at ON categorias;
CREATE TRIGGER trg_categorias_updated_at
    BEFORE UPDATE ON categorias
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------------
-- eventos
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS eventos (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    ubicacion VARCHAR(200),
    estado VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    usuario_id INTEGER NOT NULL,
    categoria_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_eventos_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE CASCADE,
    -- CASCADE para que borrar un usuario no choque con la restriccion de la
    -- categoria: al eliminar la cuenta se eliminan sus categorias y eventos.
    CONSTRAINT fk_eventos_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categorias(id)
        ON DELETE CASCADE,
    CONSTRAINT chk_eventos_fechas
        CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT chk_eventos_estado
        CHECK (estado IN ('pendiente', 'en_progreso', 'completado', 'cancelado'))
);

DROP TRIGGER IF EXISTS trg_eventos_updated_at ON eventos;
CREATE TRIGGER trg_eventos_updated_at
    BEFORE UPDATE ON eventos
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------------
-- Indices para las consultas de la agenda
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_categorias_usuario_id ON categorias(usuario_id);
CREATE INDEX IF NOT EXISTS idx_eventos_usuario_id ON eventos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_eventos_categoria_id ON eventos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_eventos_estado ON eventos(estado);
CREATE INDEX IF NOT EXISTS idx_eventos_fecha_inicio ON eventos(fecha_inicio);

-- Consulta principal de la agenda: eventos de un usuario en un rango de fechas.
CREATE INDEX IF NOT EXISTS idx_eventos_usuario_fecha
    ON eventos(usuario_id, fecha_inicio);


