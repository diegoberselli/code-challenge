from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta
import os

# Obter o diretório base da DAG
dag_path = os.path.dirname(os.path.abspath(__file__))

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    "northwind_etl_pipeline",
    default_args=default_args,
    description='Extrai dados usando Meltano para arquivos locais',
    schedule_interval='@daily',
    start_date=datetime(2024, 12, 15),
    catchup=False,
) as dag:

    extract_postgres = BashOperator(
        task_id="run_postgres",
        bash_command="bash '/opt/airflow/meltano/run_postgres.sh'"
    )

    extract_csv = BashOperator(
        task_id="run_csv",
        bash_command="bash '/opt/airflow/meltano/run_csv.sh'"
    )

    load_to_postgres = BashOperator(
        task_id="load_to_postgres",
        bash_command="bash '/opt/airflow/meltano/to_postgres.sh'"
    )


    extract_postgres >> extract_csv >> load_to_postgres
