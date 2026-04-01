# pipeline/

<div align="center">

[🇧🇷 Português](#-português) · [🇺🇸 English](#-english)

</div>

---

## 🇧🇷 Português

Este diretório contém todos os artefatos do workshop Docker.

### Conteúdo

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

#### `nytaxi_explore/`

| Arquivo | Descrição |
|---|---|
| `taxizone_ingestion.ipynb` | Notebook que ingere a tabela de zonas (`taxi_zone_lookup`) no Postgres para treinamento de JOINs e queries |
| `pgadmin-queries.sql` | Queries SQL de exemplo usadas no pgAdmin |
| `taxi_zone_lookup.csv` | CSV de referência com os IDs e nomes das zonas de táxi de NY |

### Como executar

Consulte o [README principal](../README.md) para o passo a passo completo.  
Os comandos `docker build` e `docker compose` devem ser executados **a partir deste diretório (`pipeline/`)**.

```bash
# Build da imagem
cd pipeline/
docker build -t taxi_ingest:v001 .

# Subir Postgres + pgAdmin
docker compose up -d
```

---

## 🇺🇸 English

This directory contains all the Docker workshop artifacts.

### Contents

| File / Folder | Description |
|---|---|
| `Dockerfile` | Defines the `taxi_ingest:v001` image — Python 3.13 slim with `uv`, copies `ingest_data.py` and sets `ENTRYPOINT` to receive CLI parameters |
| `docker-compose.yaml` | Starts **PostgreSQL 18** and **pgAdmin 4** together, with persistent volumes and an internal `pg-network` network |
| `ingest_data.py` | CLI script (via `click`) that downloads the NY Yellow Taxi dataset from GitHub and inserts the data into Postgres in chunks |
| `pyproject.toml` | Project dependencies managed with `uv` |
| `uv.lock` | `uv` lock file — ensures reproducibility |
| `.python-version` | Python version used by `uv` |
| `notebook.ipynb` | Jupyter notebook for initial data exploration and SQL testing |
| `nytaxi_explore/` | Folder with additional exploration artifacts (see below) |

#### `nytaxi_explore/`

| File | Description |
|---|---|
| `taxizone_ingestion.ipynb` | Notebook that ingests the zone lookup table (`taxi_zone_lookup`) into Postgres for JOIN and query practice |
| `pgadmin-queries.sql` | Example SQL queries used in pgAdmin |
| `taxi_zone_lookup.csv` | Reference CSV with NY taxi zone IDs and names |

### How to run

Refer to the [main README](../README.md) for the full step-by-step guide.  
All `docker build` and `docker compose` commands must be run **from this directory (`pipeline/`)**.

```bash
# Build the image
cd pipeline/
docker build -t taxi_ingest:v001 .

# Start Postgres + pgAdmin
docker compose up -d
```
