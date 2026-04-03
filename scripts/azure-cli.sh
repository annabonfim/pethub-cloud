# PetHub Cloud - Azure CLI Scripts

# Registrar os servicos
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.Sql
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.OperationalInsights

# Criar o Resource Group
az group create --name rg-pethub-cloud --location southafricanorth

# Criar o SQL Server
az sql server create \
  --name pethub-sqlserver-anna \
  --resource-group rg-pethub-cloud \
  --location southafricanorth \
  --admin-user pethubadmin \
  --admin-password PetHub@2025!

# Criar o Banco de Dados
az sql db create \
  --resource-group rg-pethub-cloud \
  --server pethub-sqlserver-anna \
  --name pethub \
  --edition Basic \
  --capacity 5

# Liberar o Firewall
az sql server firewall-rule create \
  --resource-group rg-pethub-cloud \
  --server pethub-sqlserver-anna \
  --name liberaGeral \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255

# Criar o App Service Plan
az appservice plan create \
  --name plan-pethub-anna \
  --resource-group rg-pethub-cloud \
  --location southafricanorth \
  --sku B1 \
  --is-linux

# Criar o Web App
az webapp create \
  --name pethub-cloud-anna \
  --resource-group rg-pethub-cloud \
  --plan plan-pethub-anna \
  --runtime "JAVA:17-java17"

# Criar o Application Insights
az extension add --name application-insights

az monitor app-insights component create \
  --app insights-pethub-anna \
  --location southafricanorth \
  --resource-group rg-pethub-cloud \
  --application-type web

# Configurar variaveis de ambiente do Web App
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

# Build e Deploy
./gradlew bootJar

az webapp deploy \
  --resource-group rg-pethub-cloud \
  --name pethub-cloud-anna \
  --src-path build/libs/pethub-0.0.1-SNAPSHOT.jar \
  --type jar