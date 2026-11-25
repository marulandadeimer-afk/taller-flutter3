-- ============================================================================
-- Taller 3: Flutter "Gestor de Agenda"
-- Esquema DDL para Neon (PostgreSQL Serverless)
-- Solo estructura base (sin datos iniciales)
-- ============================================================================

CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS categorias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    color_hex VARCHAR(7) NOT NULL DEFAULT '#2196F3',
    icono VARCHAR(50) NOT NULL DEFAULT 'event',
    usuario_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_categorias_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE CASCADE,
    CONSTRAINT uq_categorias_usuario_nombre
        UNIQUE (usuario_id, nombre)
);

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
    CONSTRAINT fk_eventos_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categorias(id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_eventos_fechas
        CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT chk_eventos_estado
        CHECK (estado IN ('pendiente', 'en_progreso', 'completado', 'cancelado'))
);

CREATE INDEX IF NOT EXISTS idx_categorias_usuario_id ON categorias(usuario_id);
CREATE INDEX IF NOT EXISTS idx_eventos_usuario_id ON eventos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_eventos_categoria_id ON eventos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_eventos_fecha_inicio ON eventos(fecha_inicio);

