# Use a versão mais recente do Python (3.10 ou superior)
FROM python:3.10-slim

# Instala dependências do sistema
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instala Meltano com versão específica do SQLAlchemy e psycopg2
RUN pip install --no-cache-dir \
    meltano \
    "sqlalchemy>=2.0.30,<3.0.0" \
    psycopg2-binary

# Define o diretório de trabalho
WORKDIR /project

# Comando para manter o container rodando
CMD ["tail", "-f", "/dev/null"]
