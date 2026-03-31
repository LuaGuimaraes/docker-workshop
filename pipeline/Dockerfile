# Define a imagem base Python 3.13.11 com versão slim
FROM python:3.13.11-slim

# Copia o executável 'uv' (gerenciador de pacotes) do container base para o PATH
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

# Define o diretório de trabalho dentro do container
WORKDIR /code

# Define variável de ambiente para usar o venv da aplicação
ENV PATH="/code/.venv/bin:$PATH"

# Copia arquivos de configuração de dependências para o diretório de trabalho
COPY pyproject.toml .python-version uv.lock ./

# Instala as dependências usando uv com lock file
RUN uv sync --locked

# Copia o script principal para o container
COPY ingest_data.py .

# Define o comando padrão para executar o script
ENTRYPOINT ["uv", "run", "python", "ingest_data.py"]