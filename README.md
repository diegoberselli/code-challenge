# Pipeline de Dados Northwind

Este projeto implementa um pipeline de dados utilizando Apache Airflow e Meltano para extrair, transformar e carregar dados do banco Northwind e arquivos CSV.

## 🚀 Tecnologias Utilizadas

- Apache Airflow 2.10.3
- Meltano
- PostgreSQL 13
- Redis 7.2
- Docker & Docker Compose
- Python 3.10

## 📁 Estrutura do Projeto

```
.
├── dags/
│   └── northwind_etl_pipeline.py
├── data/
│   ├── init-db.sql
│   ├── northwind.sql
│   └── order_details.csv
├── meltano/
│   ├── meltano.yml
│   ├── run_csv.sh
│   ├── run_postgres.sh
│   └── to_postgres.sh
├── docker-compose.yml
└── Dockerfile
```

## 🛠️ Configuração e Instalação

### Pré-requisitos

- Docker
- Docker Compose
- Git

### Passos para Instalação

1. Clone o repositório:
```bash
git clone [url-do-repositorio]
cd [nome-do-projeto]
```

2. Inicie os serviços:
```bash
docker compose up --build -d
```

O comando acima irá:
- Construir/reconstruir a imagem do Meltano definida no Dockerfile
- Baixar todas as imagens necessárias (Airflow, PostgreSQL, Redis)
- Criar e iniciar todos os containers
- Configurar a rede e volumes necessários

## 🔄 Pipeline de Dados

O pipeline está configurado para executar diariamente e consiste em três etapas principais:

1. **Extração do PostgreSQL** (`run_postgres.sh`)
   - Extrai dados das tabelas do banco Northwind
   - Armazena em formato JSONL

2. **Extração do CSV** (`run_csv.sh`)
   - Processa o arquivo order_details.csv
   - Converte para formato JSONL

3. **Carregamento Final** (`to_postgres.sh`)
   - Carrega os dados processados para o banco de destino

### Configuração do Meltano

Após iniciar os containers, é necessário configurar o ambiente Meltano:

```bash
# Acessar o container do Meltano
docker exec -it code-challenge-meltano-1 bash

# Criar ambiente virtual
python -m venv .venv

# Ativar o ambiente virtual
source .venv/bin/activate

# Instalar dependências do requirements.txt no ambiente virtual
pip install -r requirements.txt

# Instalar os plugins definidos no meltano.yml
meltano install

# Instalar extratores
meltano install extractor tap-postgres
meltano install extractor tap-csv
meltano add extractor tap-singer-jsonl
meltano install extractor tap-singer-jsonl

# Instalar loaders
meltano install loader target-postgres
meltano install loader target-jsonl

# Instalar utilitários
meltano install utility airflow
```

### Execução do Pipeline

O pipeline completo leva aproximadamente 2-3 minutos para executar, com os seguintes tempos aproximados:
- run_postgres: ~2 minutos (extração do banco Northwind)
- run_csv: ~10 segundos (processamento do order_details.csv)
- load_to_postgres: ~10 segundos (carregamento final dos dados)

O pipeline pode ser executado de duas formas:

### Via Airflow UI

1. Acesse a interface web do Airflow em `http://localhost:8080`
   - Usuário: admin
   - Senha: admin

2. Ative e execute a DAG `northwind_etl_pipeline`

### Via Linha de Comando

Execute os scripts individualmente:

```bash
docker exec code-challenge-meltano-1 bash -c "source .venv/bin/activate && meltano el [comando-específico]"
```

## 🔍 Verificação dos Dados

Para verificar os dados carregados no banco de destino:

```bash
# Acessar o PostgreSQL
docker exec -it code-challenge-postgres-1 psql -U northwind_user -d destination

# Listar todas as tabelas
\dt

# Verificar quantidade de registros na tabela order_details
SELECT COUNT(*) FROM public.order_details;
```

## 📊 Monitoramento e Acessos

- Airflow UI: http://localhost:8080
  - Usuário: admin
  - Senha: admin
- Banco de Dados: localhost:5432
  - Usuário: northwind_user
  - Senha: thewindisblowing
  - Database: northwind (source)
  - Database: destination (target)

## 🔍 Estrutura de Armazenamento

Os dados são armazenados seguindo a estrutura:

```
/csv-postgres/{table}/YYYY-MM-DD/file.format
```

## ⚠️ Observações Importantes

- Todos os processos são idempotentes
- O pipeline suporta reprocessamento de datas passadas
- As credenciais fornecidas são apenas para desenvolvimento local

## 🤝 Contribuição

1. Faça um Fork do projeto
2. Crie uma Branch para sua Feature (`git checkout -b feature/AmazingFeature`)
3. Faça o Commit das suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Faça o Push para a Branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request


# Indicium Tech Code Challenge

Code challenge for Software Developer with focus in data projects.


## Context

At Indicium we have many projects where we develop the whole data pipeline for our client, from extracting data from many data sources to loading this data at its final destination, with this final destination varying from a data warehouse for a Business Intelligency tool to an api for integrating with third party systems.

As a software developer with focus in data projects your mission is to plan, develop, deploy, and maintain a data pipeline.


## The Challenge

We are going to provide 2 data sources, a PostgreSQL database and a CSV file.

The CSV file represents details of orders from an ecommerce system.

The database provided is a sample database provided by microsoft for education purposes called northwind, the only difference is that the **order_detail** table does not exists in this database you are beeing provided with. This order_details table is represented by the CSV file we provide.

Schema of the original Northwind Database:

![image](https://user-images.githubusercontent.com/49417424/105997621-9666b980-608a-11eb-86fd-db6b44ece02a.png)

Your challenge is to build a pipeline that extracts the data everyday from both sources and write the data first to local disk, and second to a PostgreSQL database. For this challenge, the CSV file and the database will be static, but in any real world project, both data sources would be changing constantly.

Its important that all writing steps (writing data from inputs to local filesystem and writing data from local filesystem to PostgreSQL database) are isolated from each other, you shoud be able to run any step without executing the others.

For the first step, where you write data to local disk, you should write one file for each table. This pipeline will run everyday, so there should be a separation in the file paths you will create for each source(CSV or Postgres), table and execution day combination, e.g.:

```
/data/postgres/{table}/2024-01-01/file.format
/data/postgres/{table}/2024-01-02/file.format
/data/csv/2024-01-02/file.format
```

You are free to chose the naming and the format of the file you are going to save.

At step 2, you should load the data from the local filesystem, which you have created, to the final database.

The final goal is to be able to run a query that shows the orders and its details. The Orders are placed in a table called **orders** at the postgres Northwind database. The details are placed at the csv file provided, and each line has an **order_id** field pointing the **orders** table.

## Solution Diagram

As Indicium uses some standard tools, the challenge was designed to be done using some of these tools.

The following tools should be used to solve this challenge.

Scheduler:
- [Airflow](https://airflow.apache.org/docs/apache-airflow/stable/installation/index.html)

Data Loader:
- [Embulk](https://www.embulk.org) (Java Based)
**OR**
- [Meltano](https://docs.meltano.com/?_gl=1*1nu14zf*_gcl_au*MTg2OTE2NDQ4Mi4xNzA2MDM5OTAz) (Python Based)

Database:
- [PostgreSQL](https://www.postgresql.org/docs/15/index.html)

The solution should be based on the diagrams below:
![image](docs/diagrama_embulk_meltano.jpg)


### Requirements

- You **must** use the tools described above to complete the challenge.
- All tasks should be idempotent, you should be able to run the pipeline everyday and, in this case where the data is static, the output shold be the same.
- Step 2 depends on both tasks of step 1, so you should not be able to run step 2 for a day if the tasks from step 1 did not succeed.
- You should extract all the tables from the source database, it does not matter that you will not use most of them for the final step.
- You should be able to tell where the pipeline failed clearly, so you know from which step you should rerun the pipeline.
- You have to provide clear instructions on how to run the whole pipeline. The easier the better.
- You must provide evidence that the process has been completed successfully, i.e. you must provide a csv or json with the result of the query described above.
- You should assume that it will run for different days, everyday.
- Your pipeline should be prepared to run for past days, meaning you should be able to pass an argument to the pipeline with a day from the past, and it should reprocess the data for that day. Since the data for this challenge is static, the only difference for each day of execution will be the output paths.

### Things that Matters

- Clean and organized code.
- Good decisions at which step (which database, which file format..) and good arguments to back those decisions up.
- The aim of the challenge is not only to assess technical knowledge in the area, but also the ability to search for information and use it to solve problems with tools that are not necessarily known to the candidate.
- Point and click tools are not allowed.


Thank you for participating!
