<div align="center">
  <img src=".github/pethub-logo.png" alt="PetHub" width="150" />
</div>

# 🐾 PetHub Cloud

PetHub é uma aplicação desenvolvida para donos de pets que querem centralizar e acompanhar a saúde dos seus animais em um só lugar. Com o PetHub, é possível cadastrar múltiplos pets e manter um histórico completo de vacinas, consultas veterinárias e medicamentos de cada um.

O sistema conta com autenticação segura via JWT com chaves RSA, garantindo que cada usuário acesse apenas os dados dos seus próprios pets.

## ☁️ Sobre esta versão — CP2 DevOps Tools & Cloud Computing

O projeto original foi desenvolvido para a disciplina de **Java Advanced**, utilizando PostgreSQL como banco de dados e Docker para execução local.

Para o **2º Checkpoint de DevOps Tools & Cloud Computing**, o projeto foi adaptado para rodar inteiramente na nuvem da Microsoft Azure, com as seguintes mudanças:

- Banco de dados migrado de **PostgreSQL** para **Azure SQL Server (PaaS)**
- Deploy da API no **Azure App Service** (Java 17, Linux)
- Monitoramento configurado com **Azure Application Insights**
- Scripts de infraestrutura criados via **Azure CLI**
- Migrations do Flyway reescritas para sintaxe **SQL Server**

## 🛠️ Tecnologias

- Java 17
- Spring Boot 4.0.4
- Spring Security + JWT (RSA 2048 bits)
- Spring Data JPA + Hibernate
- Flyway
- Azure App Service
- Azure SQL Server (PaaS)
- Azure Application Insights
- Lombok
- Gradle

## 📦 Estrutura do Projeto
```
pethub-cloud/
├── .github/
│   └── pethub-logo.png
├── database/
│   └── ddl.sql
├── scripts/
│   └── azure-cli.sh
├── src/
│   └── main/
│       ├── java/
│       └── resources/
│           ├── application.properties
│           └── db/migration/
└── README.md
```

## 🗄️ Modelo de Dados

- **users** — usuários do sistema
- **pets** (master) — cadastro de pets vinculados a um usuário (FK: user_id)
- **vacinas** (detail) — vacinas vinculadas a um pet (FK: pet_id)
- **consultas** (detail) — consultas veterinárias vinculadas a um pet (FK: pet_id)
- **medicamentos** (detail) — medicamentos vinculados a um pet (FK: pet_id)

## ☁️ Como realizar a implantação no Azure

### Pré-requisitos

- Azure CLI instalado e configurado
- Java 17 instalado
- Conta Azure com créditos ativos
- Projeto clonado localmente

### Passo 1 — Login no Azure
```bash
az login
```

### Passo 2 — Registrar os serviços na assinatura
```bash
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.Sql
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.OperationalInsights
```

### Passo 3 — Criar o Resource Group
```bash
az group create --name rg-pethub-cloud --location southafricanorth
```

### Passo 4 — Criar o SQL Server
```bash
az sql server create \
  --name pethub-sqlserver-anna \
  --resource-group rg-pethub-cloud \
  --location southafricanorth \
  --admin-user pethubadmin \
  --admin-password PetHub@2025!
```

### Passo 5 — Criar o Banco de Dados
```bash
az sql db create \
  --resource-group rg-pethub-cloud \
  --server pethub-sqlserver-anna \
  --name pethub \
  --edition Basic \
  --capacity 5
```

### Passo 6 — Liberar o Firewall
```bash
az sql server firewall-rule create \
  --resource-group rg-pethub-cloud \
  --server pethub-sqlserver-anna \
  --name liberaGeral \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255
```

### Passo 7 — Criar o App Service Plan
```bash
az appservice plan create \
  --name plan-pethub-anna \
  --resource-group rg-pethub-cloud \
  --location southafricanorth \
  --sku B1 \
  --is-linux
```

### Passo 8 — Criar o Web App
```bash
az webapp create \
  --name pethub-cloud-anna \
  --resource-group rg-pethub-cloud \
  --plan plan-pethub-anna \
  --runtime "JAVA:17-java17"
```

### Passo 9 — Criar o Application Insights
```bash
az extension add --name application-insights

az monitor app-insights component create \
  --app insights-pethub-anna \
  --location southafricanorth \
  --resource-group rg-pethub-cloud \
  --application-type web
```

### Passo 10 — Configurar variáveis de ambiente
```bash
az webapp config appsettings set \
  --name pethub-cloud-anna \
  --resource-group rg-pethub-cloud \
  --settings \
  SPRING_DATASOURCE_URL="jdbc:sqlserver://pethub-sqlserver-anna.database.windows.net:1433;database=pethub;encrypt=true;trustServerCertificate=false;loginTimeout=30;" \
  SPRING_DATASOURCE_USERNAME="pethubadmin" \
  SPRING_DATASOURCE_PASSWORD="PetHub@2025!" \
  SPRING_DATASOURCE_DRIVER_CLASS_NAME="com.microsoft.sqlserver.jdbc.SQLServerDriver" \
  SPRING_JPA_DATABASE_PLATFORM="org.hibernate.dialect.SQLServerDialect" \
  SPRING_FLYWAY_BASELINE_ON_MIGRATE="true" \
  ApplicationInsightsAgent_EXTENSION_VERSION="~3" \
  XDT_MicrosoftApplicationInsights_Mode="recommended"
```

### Passo 11 — Gerar as chaves RSA
```bash
mkdir -p src/main/resources/certs

openssl genrsa -out src/main/resources/certs/private_key.pem 2048

openssl rsa -in src/main/resources/certs/private_key.pem \
  -pubout -out src/main/resources/certs/public_key.pem
```

### Passo 12 — Build e Deploy
```bash
./gradlew bootJar

az webapp deploy \
  --resource-group rg-pethub-cloud \
  --name pethub-cloud-anna \
  --src-path build/libs/pethub-0.0.1-SNAPSHOT.jar \
  --type jar
```

## 🔗 URL da API
```
https://pethub-cloud-anna.azurewebsites.net
```

## 🎥 Vídeo de Demonstração

> _Link do vídeo aqui_

## 🔐 Autenticação

**1. Criar usuário — POST /users**
```json
{
  "nome": "Anna Bonfim",
  "email": "anna@pethub.com",
  "senha": "123456"
}
```

**2. Login — POST /login**
```json
{
  "email": "anna@pethub.com",
  "senha": "123456"
}
```

Copie o token retornado e utilize como **Bearer Token** em todas as requisições protegidas.

## 📋 Endpoints

### Autenticação

| Método | Endpoint | Descrição | Auth |
|--------|----------|-----------|------|
| POST | `/users` | Cadastrar usuário | ❌ |
| POST | `/login` | Login e geração de token | ❌ |

### Pets

| Método | Endpoint | Descrição | Auth |
|--------|----------|-----------|------|
| POST | `/pets` | Criar pet | ✅ |
| GET | `/pets` | Listar pets | ✅ |
| GET | `/pets/{id}` | Buscar pet por ID | ✅ |
| PUT | `/pets/{id}` | Atualizar pet | ✅ |
| DELETE | `/pets/{id}` | Deletar pet | ✅ |

### Vacinas

| Método | Endpoint | Descrição | Auth |
|--------|----------|-----------|------|
| POST | `/pets/{petId}/vacinas` | Criar vacina | ✅ |
| GET | `/pets/{petId}/vacinas` | Listar vacinas | ✅ |
| PUT | `/pets/{petId}/vacinas/{id}` | Atualizar vacina | ✅ |
| DELETE | `/pets/{petId}/vacinas/{id}` | Deletar vacina | ✅ |

### Consultas

| Método | Endpoint | Descrição | Auth |
|--------|----------|-----------|------|
| POST | `/pets/{petId}/consultas` | Criar consulta | ✅ |
| GET | `/pets/{petId}/consultas` | Listar consultas | ✅ |
| PUT | `/pets/{petId}/consultas/{id}` | Atualizar consulta | ✅ |
| DELETE | `/pets/{petId}/consultas/{id}` | Deletar consulta | ✅ |

### Medicamentos

| Método | Endpoint | Descrição | Auth |
|--------|----------|-----------|------|
| POST | `/pets/{petId}/medicamentos` | Criar medicamento | ✅ |
| GET | `/pets/{petId}/medicamentos` | Listar medicamentos | ✅ |
| PUT | `/pets/{petId}/medicamentos/{id}` | Atualizar medicamento | ✅ |
| DELETE | `/pets/{petId}/medicamentos/{id}` | Deletar medicamento | ✅ |

## 🔒 Segurança

- Senhas armazenadas com **BCrypt**
- Tokens JWT assinados com **RSA 2048 bits**
- Cada usuário acessa apenas os próprios pets e registros
- Chaves RSA não versionadas (`.gitignore`)

## 👩‍💻 Integrante

| Nome | RM |
|------|----|
| Anna Beatriz de Araújo Bonfim | 559561 |