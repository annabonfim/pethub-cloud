-- PetHub Cloud - DDL Script
-- Azure SQL Server

CREATE TABLE users (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome NVARCHAR(100) NOT NULL,
    email NVARCHAR(150) NOT NULL UNIQUE,
    senha NVARCHAR(255) NOT NULL,
    role NVARCHAR(20) NOT NULL DEFAULT 'USER'
);

CREATE TABLE pets (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome NVARCHAR(100) NOT NULL,
    especie NVARCHAR(20) NOT NULL,
    raca NVARCHAR(100),
    data_nascimento DATE,
    user_id BIGINT NOT NULL,
    CONSTRAINT fk_pets_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE vacinas (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome NVARCHAR(100) NOT NULL,
    data_aplicacao DATE NOT NULL,
    proxima_dose DATE,
    observacoes NVARCHAR(MAX),
    pet_id BIGINT NOT NULL,
    CONSTRAINT fk_vacinas_pet FOREIGN KEY (pet_id) REFERENCES pets(id)
);

CREATE TABLE consultas (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    data DATE NOT NULL,
    veterinario NVARCHAR(100),
    motivo NVARCHAR(255),
    observacoes NVARCHAR(MAX),
    peso DECIMAL(5,2),
    pet_id BIGINT NOT NULL,
    CONSTRAINT fk_consultas_pet FOREIGN KEY (pet_id) REFERENCES pets(id)
);

CREATE TABLE medicamentos (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome NVARCHAR(100) NOT NULL,
    dose NVARCHAR(100),
    frequencia NVARCHAR(100),
    data_inicio DATE,
    data_fim DATE,
    pet_id BIGINT NOT NULL,
    CONSTRAINT fk_medicamentos_pet FOREIGN KEY (pet_id) REFERENCES pets(id)
);