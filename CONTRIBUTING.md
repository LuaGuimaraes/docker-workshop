# Contribuindo com o Docker Workshop

Obrigado pelo interesse em contribuir! 🎉  
Este é um repositório de workshop educacional, então toda contribuição que melhore a clareza, corrija erros ou adicione conteúdo relevante é muito bem-vinda.

---

## Como contribuir

### 1. Reportando problemas (Issues)

- Use a aba **Issues** do GitHub para reportar erros, ambiguidades ou sugestões.
- Descreva o problema com clareza: o que você tentou fazer, o que aconteceu e o que era esperado.
- Se possível, inclua o comando executado, a mensagem de erro e a versão do Docker (`docker --version`).

### 2. Propondo melhorias (Pull Requests)

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

## Padrão de commits (recomendado)

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

## O que NÃO alterar

- O comportamento do `ingest_data.py` (lógica de ingestão).
- O `Dockerfile` e o `docker-compose.yaml` sem justificativa clara.
- Arquivos de lock (`uv.lock`) manualmente — deixe o `uv` gerenciar.

---

## Dúvidas

Abra uma issue com a label `question` e responderemos o mais breve possível.
