-- Criar banco de dados Airflow
CREATE DATABASE airflow;
GRANT ALL PRIVILEGES ON DATABASE airflow TO northwind_user;

-- Criar banco de dados Meltano
CREATE DATABASE meltano;
GRANT ALL PRIVILEGES ON DATABASE meltano TO northwind_user;

-- Criar banco de dados de destino
CREATE DATABASE destination;
GRANT ALL PRIVILEGES ON DATABASE destination TO northwind_user;
