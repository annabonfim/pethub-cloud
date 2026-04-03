CREATE TABLE vacinas (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome NVARCHAR(100) NOT NULL,
    data_aplicacao DATE NOT NULL,
    proxima_dose DATE,
    observacoes NVARCHAR(MAX),
    pet_id BIGINT NOT NULL,
    CONSTRAINT fk_vacinas_pet FOREIGN KEY (pet_id) REFERENCES pets(id)
);