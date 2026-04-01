# 🐳 Docker Workshop

<div align="center">

[🇧🇷 Português](#-português) · [🇺🇸 English](#-english)

</div>

---

## 🇧🇷 Português

### Visão Geral

Este repositório documenta a minha jornada de aprendizado prático com Docker. A partir de conceitos fundamentais (imagens, containers, volumes e redes), eu aprendi a subir um banco de dados PostgreSQL, ingerir dados reais do dataset NY Taxi e explorá-los com pgAdmin e notebooks Jupyter — tudo orquestrado com Docker e Docker Compose.

---

### O que eu aprendi

| Conceito | Descrição |
|---|---|
| `CMD` vs `ENTRYPOINT` | Diferença de comportamento ao passar parâmetros para um container |
| Volumes persistentes | Como manter dados do PostgreSQL entre reinicializações do container |
| Bind Mounts | Montar arquivos locais dentro do container para agilizar o desenvolvimento sem rebuild |
| Redes Docker | Como containers se comunicam pelo nome (`--network`) |
| Build de imagem customizada | Empacotar um script Python com `uv` num container pronto para produção |
| Docker Compose | Orquestrar múltiplos serviços (Postgres + pgAdmin) com um único arquivo |
| Ingestão de dados em chunks | Inserir grandes arquivos CSV no Postgres com controle de memória |

---

### Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) ≥ 24 instalado e em execução
- [Docker Compose](https://docs.docker.com/compose/) (já incluso no Docker Desktop)
- [uv](https://github.com/astral-sh/uv) (gerenciador de pacotes Python) — necessário apenas para usar `pgcli` localmente
- Conexão com a internet (para baixar imagens e o dataset)

---

### Estrutura do Repositório

```
docker-workshop/
├── README.md               # Este arquivo
├── LICENSE                 # Licença MIT
├── CONTRIBUTING.md         # Guia de contribuição
├── CODE_OF_CONDUCT.md      # Código de conduta
├── .gitignore
└── pipeline/               # Todo o código do workshop
    ├── README.md           # Detalhes do diretório pipeline
    ├── Dockerfile          # Imagem customizada taxi_ingest:v001
    ├── docker-compose.yaml # Sobe Postgres + pgAdmin juntos
    ├── ingest_data.py      # Script de ingestão (CLI com click)
    ├── pyproject.toml      # Dependências Python (uv)
    ├── uv.lock             # Lock file do uv
    ├── .python-version     # Versão do Python usada
    ├── notebook.ipynb      # Notebook de exploração
    └── nytaxi_explore/
        ├── taxizone_ingestion.ipynb  # Ingestão da tabela de zonas
        ├── pgadmin-queries.sql       # Queries SQL de exemplo
        └── taxi_zone_lookup.csv      # CSV de referência de zonas
```

---

### Como Rodar

> ⚠️ **Todos os comandos do `docker build` e do `pipeline/` devem ser executados a partir do diretório `pipeline/`**, a menos que indicado de outra forma.

#### 1. Criar a rede Docker

```bash
docker network create pg-network
```

#### 2. Subir o PostgreSQL

```bash
docker run -d \
  -e POSTGRES_USER=root \
  -e POSTGRES_PASSWORD=root \
  -e POSTGRES_DB=ny_taxi \
  -v ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  --network=pg-network \
  --name pgdatabase \
  postgres:18
```

Aguarde alguns segundos e verifique os logs:

```bash
docker logs --tail 50 pgdatabase
```

#### 3. Build da imagem de ingestão

```bash
# Execute a partir do diretório pipeline/
cd pipeline/
docker build -t taxi_ingest:v001 .
```

#### 4. Rodar o container de ingestão

O script baixa automaticamente o arquivo CSV do dataset NY Yellow Taxi do GitHub e insere os dados no Postgres em chunks.

```bash
docker run -it --rm \
  --network=pg-network \
  taxi_ingest:v001 \
    --pg-user=root \
    --pg-password=root \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --target-table=yellow_taxi_data \
    --year=2021 \
    --month=1 \
    --chunksize=100000
```

**Parâmetros disponíveis:**

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `--pg-user` | `root` | Usuário do Postgres |
| `--pg-password` | `root` | Senha do Postgres |
| `--pg-host` | `pgdatabase` | Host do Postgres (nome do container) |
| `--pg-port` | `5432` | Porta do Postgres |
| `--pg-db` | `ny_taxi` | Nome do banco de dados |
| `--target-table` | `yellow_taxi_data` | Tabela de destino |
| `--year` | `2021` | Ano do arquivo de dados |
| `--month` | `1` | Mês do arquivo de dados |
| `--chunksize` | `100000` | Linhas por chunk de leitura |

#### 5. Verificar a ingestão com pgcli

```bash
# Execute a partir do diretório pipeline/
cd pipeline/
uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
```

Dentro do pgcli, teste:

```sql
\dt                          -- lista as tabelas
SELECT count(*) FROM yellow_taxi_data;
SELECT * FROM yellow_taxi_data LIMIT 5;
```

#### 6. Subir o pgAdmin (interface visual)

```bash
docker run -d \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -v pgadmin_data:/var/lib/pgadmin \
  -p 8085:80 \
  --network=pg-network \
  --name pgadmin \
  dpage/pgadmin4
```

Acesse: [http://localhost:8085/browser/](http://localhost:8085/browser/)

> Credenciais: **admin@admin.com** / **root**

No pgAdmin, crie um novo servidor apontando para:
- **Host**: `pgdatabase`
- **Port**: `5432`
- **Username**: `root`
- **Password**: `root`

---

### Rodando com Docker Compose

O `docker-compose.yaml` em `pipeline/` sobe o Postgres e o pgAdmin juntos, com volume e rede já configurados.

```bash
# Execute a partir do diretório pipeline/
cd pipeline/
docker compose up -d
```

Aguarde os containers iniciarem (o pgAdmin aguarda o Postgres estar saudável).

Após o compose estar em execução, rode o container de ingestão usando a **rede criada pelo compose** (`pipeline_pg-network`):

```bash
docker run -it --rm \
  --network=pipeline_pg-network \
  taxi_ingest:v001 \
    --pg-user=root \
    --pg-password=root \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --target-table=yellow_taxi_data \
    --year=2021 \
    --month=1 \
    --chunksize=100000
```

> **Por que `pipeline_pg-network`?** O Docker Compose prefixa o nome da rede com o nome do diretório do projeto (`pipeline`). Se você executar o compose de outro diretório, o prefixo mudará. Verifique com `docker network ls`.

Para parar os serviços:

```bash
cd pipeline/
docker compose down
```

Para parar e remover os volumes (apaga os dados):

```bash
cd pipeline/
docker compose down -v
```

---

### Bind Mount no Desenvolvimento

Durante o desenvolvimento do script `ingest_data.py`, o **bind mount** foi uma ferramenta essencial. Em vez de reconstruir a imagem a cada alteração no código, o arquivo local era montado diretamente dentro do container:

```bash
docker run -it --rm \
  -v ./ingest_data.py:/app/ingest_data.py \
  --network=pg-network \
  taxi_ingest:v001 \
    --pg-user=root \
    --pg-password=root \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --target-table=yellow_taxi_data \
    --year=2021 \
    --month=1
```

> A flag `-v ./ingest_data.py:/app/ingest_data.py` sobrescreve o arquivo copiado na imagem pelo arquivo local em tempo de execução. Edite o script, rode o container novamente — sem precisar de `docker build` a cada iteração. Isso acelera muito o ciclo de desenvolvimento e debug.

---

### Idempotência no Script de Ingestão

O script `ingest_data.py` utiliza `if_exists="replace"` na criação da tabela a partir do primeiro chunk:

```python
first_chunk.head(0).to_sql(
    name=target_table,
    con=engine,
    if_exists="replace",
    index=False,
)
```

Isso garante que a tabela seja **recriada do zero** a cada execução — descartando os dados anteriores antes de inserir os novos. Não é um sistema de idempotência robusto, mas para um projeto de aprendizado é suficiente: você pode rodar o script quantas vezes quiser sem duplicar registros e sem precisar executar `DROP TABLE` manualmente entre as tentativas.

---

### Troubleshooting

#### Porta já em uso (`bind: address already in use`)

```bash
# Verifique qual processo está usando a porta (ex: 5432)
lsof -i :5432
# ou no Linux:
ss -tlnp | grep 5432
```

Pare o processo ou mude a porta de bind no comando `docker run` (ex.: `-p 5433:5432`).

#### Rede não existe (`network pg-network not found`)

```bash
docker network create pg-network
```

#### Erro de credenciais no pgcli / pgAdmin

Confirme que o Postgres subiu com as variáveis corretas:

```bash
docker inspect pgdatabase | grep -A5 "Env"
```

#### Container com nome já em uso (`Conflict. The container name ... is already in use`)

```bash
docker rm -f pgdatabase     # força remoção do container existente
docker rm -f pgadmin
```

#### Ver logs de um container

```bash
docker logs pgdatabase
docker logs pgadmin
docker logs --follow pgdatabase   # em tempo real
```

#### Rede do Compose com prefixo diferente

```bash
docker network ls | grep pg-network
```

Use o nome exato retornado no parâmetro `--network` do container de ingestão.

---

### Licença

Distribuído sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

### Contribuição

Contribuições são bem-vindas! 

---

## 🇺🇸 English

### Overview

This repository documents my hands-on learning journey with Docker. Starting from core concepts (images, containers, volumes, and networks), I learned how to spin up a PostgreSQL database, ingest real data from the NY Taxi dataset, and explore it using pgAdmin and Jupyter notebooks — all orchestrated with Docker and Docker Compose.

---

### What I Learned

| Concept | Description |
|---|---|
| `CMD` vs `ENTRYPOINT` | Behavioral difference when passing parameters to a container |
| Persistent volumes | How to keep PostgreSQL data across container restarts |
| Bind mounts | Mount local files inside the container to speed up development without rebuilding |
| Docker networks | How containers communicate by name (`--network`) |
| Custom image build | Package a Python script with `uv` into a production-ready container |
| Docker Compose | Orchestrate multiple services (Postgres + pgAdmin) with a single file |
| Chunked data ingestion | Insert large CSV files into Postgres with memory control |

---

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) ≥ 24 installed and running
- [Docker Compose](https://docs.docker.com/compose/) (already included in Docker Desktop)
- [uv](https://github.com/astral-sh/uv) (Python package manager) — required only to use `pgcli` locally
- Internet connection (to pull images and the dataset)

---

### Repository Structure

```
docker-workshop/
├── README.md               # This file
├── LICENSE                 # MIT License
├── CONTRIBUTING.md         # Contribution guide
├── CODE_OF_CONDUCT.md      # Code of conduct
├── .gitignore
└── pipeline/               # All workshop code
    ├── README.md           # pipeline/ directory details
    ├── Dockerfile          # Custom image taxi_ingest:v001
    ├── docker-compose.yaml # Starts Postgres + pgAdmin together
    ├── ingest_data.py      # Ingestion script (CLI with click)
    ├── pyproject.toml      # Python dependencies (uv)
    ├── uv.lock             # uv lock file
    ├── .python-version     # Python version used by uv
    ├── notebook.ipynb      # Exploration notebook
    └── nytaxi_explore/
        ├── taxizone_ingestion.ipynb  # Zone table ingestion notebook
        ├── pgadmin-queries.sql       # Example SQL queries
        └── taxi_zone_lookup.csv      # NY taxi zone reference CSV
```

---

### How to Run

> ⚠️ **All `docker build` and `pipeline/` commands must be run from the `pipeline/` directory**, unless otherwise noted.

#### 1. Create the Docker network

```bash
docker network create pg-network
```

#### 2. Start PostgreSQL

```bash
docker run -d \
  -e POSTGRES_USER=root \
  -e POSTGRES_PASSWORD=root \
  -e POSTGRES_DB=ny_taxi \
  -v ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  --network=pg-network \
  --name pgdatabase \
  postgres:18
```

Wait a few seconds, then check the logs:

```bash
docker logs --tail 50 pgdatabase
```

#### 3. Build the ingestion image

```bash
# Run from the pipeline/ directory
cd pipeline/
docker build -t taxi_ingest:v001 .
```

#### 4. Run the ingestion container

The script automatically downloads the NY Yellow Taxi CSV dataset from GitHub and inserts the data into Postgres in chunks.

```bash
docker run -it --rm \
  --network=pg-network \
  taxi_ingest:v001 \
    --pg-user=root \
    --pg-password=root \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --target-table=yellow_taxi_data \
    --year=2021 \
    --month=1 \
    --chunksize=100000
```

**Available parameters:**

| Parameter | Default | Description |
|---|---|---|
| `--pg-user` | `root` | Postgres user |
| `--pg-password` | `root` | Postgres password |
| `--pg-host` | `pgdatabase` | Postgres host (container name) |
| `--pg-port` | `5432` | Postgres port |
| `--pg-db` | `ny_taxi` | Database name |
| `--target-table` | `yellow_taxi_data` | Destination table |
| `--year` | `2021` | Data file year |
| `--month` | `1` | Data file month |
| `--chunksize` | `100000` | Rows per CSV read chunk |

#### 5. Verify ingestion with pgcli

```bash
# Run from the pipeline/ directory
cd pipeline/
uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
```

Inside pgcli, try:

```sql
\dt                          -- list tables
SELECT count(*) FROM yellow_taxi_data;
SELECT * FROM yellow_taxi_data LIMIT 5;
```

#### 6. Start pgAdmin (visual interface)

```bash
docker run -d \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -v pgadmin_data:/var/lib/pgadmin \
  -p 8085:80 \
  --network=pg-network \
  --name pgadmin \
  dpage/pgadmin4
```

Open: [http://localhost:8085/browser/](http://localhost:8085/browser/)

> Credentials: **admin@admin.com** / **root**

In pgAdmin, create a new server pointing to:
- **Host**: `pgdatabase`
- **Port**: `5432`
- **Username**: `root`
- **Password**: `root`

---

### Running with Docker Compose

The `docker-compose.yaml` in `pipeline/` starts Postgres and pgAdmin together, with volumes and network already configured.

```bash
# Run from the pipeline/ directory
cd pipeline/
docker compose up -d
```

Wait for the containers to start (pgAdmin waits for Postgres to be healthy).

Once Compose is running, start the ingestion container using the **network created by Compose** (`pipeline_pg-network`):

```bash
docker run -it --rm \
  --network=pipeline_pg-network \
  taxi_ingest:v001 \
    --pg-user=root \
    --pg-password=root \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --target-table=yellow_taxi_data \
    --year=2021 \
    --month=1 \
    --chunksize=100000
```

> **Why `pipeline_pg-network`?** Docker Compose prefixes the network name with the project directory name (`pipeline`). If you run Compose from a different directory, the prefix will change. Verify with `docker network ls`.

To stop services:

```bash
cd pipeline/
docker compose down
```

To stop and remove volumes (deletes data):

```bash
cd pipeline/
docker compose down -v
```

---

### Bind Mount in Development

During the development of `ingest_data.py`, **bind mounts** were an essential tool. Instead of rebuilding the image on every code change, the local file was mounted directly inside the container:

```bash
docker run -it --rm \
  -v ./ingest_data.py:/app/ingest_data.py \
  --network=pg-network \
  taxi_ingest:v001 \
    --pg-user=root \
    --pg-password=root \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --target-table=yellow_taxi_data \
    --year=2021 \
    --month=1
```

> The `-v ./ingest_data.py:/app/ingest_data.py` flag overrides the file copied into the image with the local file at runtime. Edit the script, run the container again — no `docker build` required on every iteration. This significantly speeds up the development and debug cycle.

---

### Idempotency in the Ingestion Script

The `ingest_data.py` script uses `if_exists="replace"` when creating the table from the first chunk:

```python
first_chunk.head(0).to_sql(
    name=target_table,
    con=engine,
    if_exists="replace",
    index=False,
)
```

This ensures the table is **rebuilt from scratch** on every run — dropping the previous data before inserting new records. It is not a robust idempotency system, but for a learning project it is more than enough: you can run the script as many times as needed without duplicating rows and without manually executing `DROP TABLE` between runs.

---

### Troubleshooting

#### Port already in use (`bind: address already in use`)

```bash
# Check which process is using the port (e.g., 5432)
lsof -i :5432
# or on Linux:
ss -tlnp | grep 5432
```

Stop the process or change the bind port in the `docker run` command (e.g., `-p 5433:5432`).

#### Network not found (`network pg-network not found`)

```bash
docker network create pg-network
```

#### Credentials error in pgcli / pgAdmin

Confirm that Postgres started with the correct environment variables:

```bash
docker inspect pgdatabase | grep -A5 "Env"
```

#### Container name already in use (`Conflict. The container name ... is already in use`)

```bash
docker rm -f pgdatabase     # force-remove existing container
docker rm -f pgadmin
```

#### View container logs

```bash
docker logs pgdatabase
docker logs pgadmin
docker logs --follow pgdatabase   # real-time
```

#### Compose network with a different prefix

```bash
docker network ls | grep pg-network
```

Use the exact name returned in the `--network` parameter of the ingestion container.

---

### License

Distributed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

### Contributing

Contributions are welcome! Read [CONTRIBUTING.md](CONTRIBUTING.md) to learn how to participate.
