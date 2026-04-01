# 🐳 Docker Workshop

> Workshop prático para aprender Docker construindo um pipeline de ingestão de dados de táxi de Nova York.

---

## Visão Geral

Este repositório documenta uma jornada de aprendizado prático com Docker. A partir de conceitos fundamentais (imagens, containers, volumes e redes), você vai subir um banco de dados PostgreSQL, ingerir dados reais do dataset NY Taxi e explorá-los com pgAdmin e notebooks Jupyter — tudo orquestrado com Docker e Docker Compose.

---

## O que você vai aprender

| Conceito | Descrição |
|---|---|
| `CMD` vs `ENTRYPOINT` | Diferença de comportamento ao passar parâmetros para um container |
| Volumes persistentes | Como manter dados do PostgreSQL entre reinicializações do container |
| Redes Docker | Como containers se comunicam pelo nome (`--network`) |
| Build de imagem customizada | Empacotar um script Python com `uv` num container pronto para produção |
| Docker Compose | Orquestrar múltiplos serviços (Postgres + pgAdmin) com um único arquivo |
| Ingestão de dados em chunks | Inserir grandes arquivos CSV no Postgres com controle de memória |

---

## Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) ≥ 24 instalado e em execução
- [Docker Compose](https://docs.docker.com/compose/) (já incluso no Docker Desktop)
- [uv](https://github.com/astral-sh/uv) (gerenciador de pacotes Python) — necessário apenas para usar `pgcli` localmente
- Conexão com a internet (para baixar imagens e o dataset)

---

## Estrutura do Repositório

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

## Como Rodar

> ⚠️ **Todos os comandos do `docker build` e do `pipeline/` devem ser executados a partir do diretório `pipeline/`**, a menos que indicado de outra forma.

### 1. Criar a rede Docker

```bash
docker network create pg-network
```

### 2. Subir o PostgreSQL

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

### 3. Build da imagem de ingestão

```bash
# Execute a partir do diretório pipeline/
cd pipeline/
docker build -t taxi_ingest:v001 .
```

### 4. Rodar o container de ingestão

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

### 5. Verificar a ingestão com pgcli

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

### 6. Subir o pgAdmin (interface visual)

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

## Rodando com Docker Compose

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

## Troubleshooting

### Porta já em uso (`bind: address already in use`)

```bash
# Verifique qual processo está usando a porta (ex: 5432)
lsof -i :5432
# ou no Linux:
ss -tlnp | grep 5432
```

Pare o processo ou mude a porta de bind no comando `docker run` (ex.: `-p 5433:5432`).

### Rede não existe (`network pg-network not found`)

```bash
docker network create pg-network
```

### Erro de credenciais no pgcli / pgAdmin

Confirme que o Postgres subiu com as variáveis corretas:

```bash
docker inspect pgdatabase | grep -A5 "Env"
```

### Container com nome já em uso (`Conflict. The container name ... is already in use`)

```bash
docker rm -f pgdatabase     # força remoção do container existente
docker rm -f pgadmin
```

### Ver logs de um container

```bash
docker logs pgdatabase
docker logs pgadmin
docker logs --follow pgdatabase   # em tempo real
```

### Rede do Compose com prefixo diferente

```bash
docker network ls | grep pg-network
```

Use o nome exato retornado no parâmetro `--network` do container de ingestão.

---

## Licença

Distribuído sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## Contribuição

Contribuições são bem-vindas! Leia o [CONTRIBUTING.md](CONTRIBUTING.md) para saber como participar.
