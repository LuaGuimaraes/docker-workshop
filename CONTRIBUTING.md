# Contribuindo com o Docker Workshop

<div align="center">

[🇧🇷 Português](#-português) · [🇺🇸 English](#-english)

</div>

---

## 🇧🇷 Português

Obrigado pelo interesse em contribuir! 🎉  
Este é um repositório de workshop educacional, então toda contribuição que melhore a clareza, corrija erros ou adicione conteúdo relevante é muito bem-vinda.

---

### Como contribuir

#### 1. Reportando problemas (Issues)

- Use a aba **Issues** do GitHub para reportar erros, ambiguidades ou sugestões.
- Descreva o problema com clareza: o que você tentou fazer, o que aconteceu e o que era esperado.
- Se possível, inclua o comando executado, a mensagem de erro e a versão do Docker (`docker --version`).

#### 2. Propondo melhorias (Pull Requests)

1. Faça um **fork** do repositório.
2. Crie uma branch descritiva a partir de `main`:
   ```bash
   git checkout -b feat/minha-melhoria
   ```
3. Faça suas alterações e **commite** seguindo o padrão abaixo.
4. Abra um **Pull Request** descrevendo:
   - O que foi alterado e por quê.
   - Como testar/verificar a mudança.

---

### Padrão de commits (recomendado)

Use mensagens de commit semânticas no formato `<tipo>: <descrição curta>`:

| Tipo | Quando usar |
|---|---|
| `feat` | Nova funcionalidade ou conteúdo |
| `fix` | Correção de erro ou comando incorreto |
| `docs` | Melhoria de documentação |
| `chore` | Tarefas de manutenção (gitignore, deps, etc.) |
| `refactor` | Refatoração sem mudança de comportamento |

**Exemplos:**
```
docs: adicionar seção de troubleshooting no README
fix: corrigir parâmetro --pg-host no exemplo do compose
feat: adicionar notebook de análise exploratória
```

---

### O que NÃO alterar

- O comportamento do `ingest_data.py` (lógica de ingestão).
- O `Dockerfile` e o `docker-compose.yaml` sem justificativa clara.
- Arquivos de lock (`uv.lock`) manualmente — deixe o `uv` gerenciar.

---

### Dúvidas

Abra uma issue com a label `question` e responderemos o mais breve possível.

---

## 🇺🇸 English

Thank you for your interest in contributing! 🎉  
This is an educational workshop repository, so any contribution that improves clarity, fixes errors, or adds relevant content is very welcome.

---

### How to contribute

#### 1. Reporting issues

- Use the **Issues** tab on GitHub to report bugs, ambiguities, or suggestions.
- Describe the problem clearly: what you tried to do, what happened, and what you expected.
- If possible, include the command you ran, the error message, and your Docker version (`docker --version`).

#### 2. Proposing improvements (Pull Requests)

1. **Fork** the repository.
2. Create a descriptive branch from `main`:
   ```bash
   git checkout -b feat/my-improvement
   ```
3. Make your changes and **commit** following the pattern below.
4. Open a **Pull Request** describing:
   - What was changed and why.
   - How to test/verify the change.

---

### Commit message convention (recommended)

Use semantic commit messages in the format `<type>: <short description>`:

| Type | When to use |
|---|---|
| `feat` | New feature or content |
| `fix` | Bug fix or incorrect command |
| `docs` | Documentation improvement |
| `chore` | Maintenance tasks (gitignore, deps, etc.) |
| `refactor` | Refactoring without behavior change |

**Examples:**
```
docs: add troubleshooting section to README
fix: correct --pg-host parameter in compose example
feat: add exploratory analysis notebook
```

---

### What NOT to change

- The behavior of `ingest_data.py` (ingestion logic).
- The `Dockerfile` and `docker-compose.yaml` without a clear justification.
- Lock files (`uv.lock`) manually — let `uv` manage them.

---

### Questions

Open an issue with the `question` label and we will respond as soon as possible.
