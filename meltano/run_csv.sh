
#!/bin/bash

# Identifica o diretório do script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR"

# Gera um ID único para a execução (sem usar uuidgen)
run_id=$(cat /proc/sys/kernel/random/uuid)

# # Executa o Meltano no container correto para o CSV
docker exec code-challenge-meltano-1 bash -c "source .venv/bin/activate && meltano el tap-csv target-jsonl --run-id=$run_id"
