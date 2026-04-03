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