# Integração n8n — Nara Mendes Catering

## Fluxo do workflow

```
Formulário (site)  ──POST JSON──►  Webhook n8n
                                       ↓
                               Supabase — Insert na tabela `leads`
                                       ↓
                               Gmail — Email para cantinhodanarusca@gmail.com
                                       ↓
                               Responder 200 (JSON { status: "ok" })
```

---

## Payload enviado pelo formulário

| Campo           | Exemplo                        |
|-----------------|--------------------------------|
| `nome`          | Maria Silva                    |
| `telefone`      | 912 345 678                    |
| `data_evento`   | 2026-07-12                     |
| `tipo_evento`   | Aniversário                    |
| `convidados`    | 30                             |
| `mensagem`      | texto livre                    |
| `consentimento` | true                           |
| `origem`        | Landing Page - Nara Mendes Catering |
| `pagina`        | URL da página                  |
| `timestamp`     | 2026-06-17T14:32:00.000Z (ISO) |

Acesso no n8n: `{{ $('Webhook - Formulario').item.json.body.nome }}` etc.

---

## Passo 1 — Criar a tabela no Supabase

- Abrir o projeto "NaraMendesCatering's Project" no Supabase
- SQL Editor → colar e executar o conteúdo de `supabase-leads.sql`

## Passo 2 — Importar o workflow no n8n

1. No n8n: **Workflows → Import from File**
2. Escolher `n8n-workflow-nara-orcamento.json` (nesta pasta)
3. O workflow tem 4 nós: Webhook → Supabase → Gmail → Responder 200

## Passo 3 — Configurar credenciais

**Supabase:**
- Settings → Credentials → New → Supabase
- Nome: `Supabase Nara`
- API URL: Supabase → Settings → API → Project URL
- Service Role Key: Supabase → Settings → API → service_role key

**Gmail (OAuth2):**
- Settings → Credentials → New → Gmail OAuth2
- Nome: `Gmail Nara`
- Fazer login com cantinhodanarusca@gmail.com e autorizar

## Passo 4 — Ativar e copiar o Production URL

1. Guardar e ativar o workflow (toggle no topo)
2. Clicar no nó **Webhook - Formulario**
3. Copiar o **Production URL** — algo como:
   `https://n8n-production-6ead.up.railway.app/webhook/nara-orcamento`

## Passo 5 — Ligar o webhook ao site

Em `index.html`, antes do script principal (antes de `</body>`), adicionar:

```html
<script>
  window.NARA_CONFIG = {
    WEBHOOK_URL: "https://n8n-production-6ead.up.railway.app/webhook/nara-orcamento"
  };
</script>
```

Depois:
```bash
git add index.html
git commit -m "Liga webhook n8n em produção"
git push agency master
```

---

## Notas técnicas

- **CORS**: o nó Webhook já tem `allowedOrigins: "*"`. Para restringir,
  usar `https://igsolutionmkt-lang.github.io` (ou o domínio final da Nara).
- **Fallback**: se o webhook não estiver configurado (`SUBSTITUIR_AQUI`) ou
  o n8n estiver offline, o formulário redireciona automaticamente para o
  WhatsApp com os dados preenchidos. Nenhum lead se perde.
- **Extensões futuras**: adicionar nó Telegram (aviso instantâneo),
  Z-API (mensagem de confirmação ao cliente) ou Notion entre o Supabase e o Gmail.
