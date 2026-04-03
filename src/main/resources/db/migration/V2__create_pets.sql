CREATE TABLE pets (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome NVARCHAR(100) NOT NULL,
    especie NVARCHAR(20) NOT NULL,
    raca NVARCHAR(100),
    data_nascimento DATE,
    user_id BIGINT NOT NULL,
    CONSTRAINT fk_pets_user FOREIGN KEY (user_id) REFERENCES users(id)
);