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