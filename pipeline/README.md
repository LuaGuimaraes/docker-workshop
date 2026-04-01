# pipeline/

Este diretório contém todos os artefatos do workshop Docker.

## Conteúdo

| Arquivo / Pasta | Descrição |
|---|---|
| `Dockerfile` | Define a imagem `taxi_ingest:v001` — Python 3.13 slim com `uv`, copia o script `ingest_data.py` e define `ENTRYPOINT` para receber parâmetros CLI |
| `docker-compose.yaml` | Sobe **PostgreSQL 18** e **pgAdmin 4** juntos, com volumes persistentes e rede interna `pg-network` |
| `ingest_data.py` | Script CLI (via `click`) que baixa o dataset NY Yellow Taxi do GitHub e insere os dados em chunks no Postgres |
| `pyproject.toml` | Dependências do projeto gerenciadas com `uv` |
| `uv.lock` | Lock file do `uv` — garante reprodutibilidade |
| `.python-version` | Versão do Python usada pelo `uv` |
| `notebook.ipynb` | Notebook Jupyter para exploração inicial dos dados e testes de SQL |
| `nytaxi_explore/` | Pasta com artefatos de exploração adicional (veja abaixo) |

### `nytaxi_explore/`

| Arquivo | Descrição |
|---|---|
| `taxizone_ingestion.ipynb` | Notebook que ingere a tabela de zonas (`taxi_zone_lookup`) no Postgres para treinamento de JOINs e queries |
| `pgadmin-queries.sql` | Queries SQL de exemplo usadas no pgAdmin |
| `taxi_zone_lookup.csv` | CSV de referência com os IDs e nomes das zonas de táxi de NY |

## Como executar

Consulte o [README principal](../README.md) para o passo a passo completo.  
Os comandos `docker build` e `docker compose` devem ser executados **a partir deste diretório (`pipeline/`)**.

```bash
# Build da imagem
cd pipeline/
docker build -t taxi_ingest:v001 .

# Subir Postgres + pgAdmin
docker compose up -d
```
