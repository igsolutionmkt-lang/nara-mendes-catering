# Integração do formulário com n8n

A landing page **não envia emails nem faz automação**. Ela apenas faz um `POST`
com os dados do formulário para o **webhook do n8n**. Toda a lógica (email,
notificações, gravação de leads) corre no n8n.

```
Formulário (site)  ──POST JSON──►  Webhook n8n  ──►  Email para cantinhodanarusca@gmail.com
```

---

## Passo 1 — Importar o workflow no n8n

1. No n8n: **Workflows → ⋮ (canto sup. direito) → Import from File**.
2. Escolher o ficheiro `n8n-workflow-nara-orcamento.json` (nesta pasta).
3. O workflow tem 3 nós:
   - **Webhook - Formulario** (recebe os dados, CORS já aberto a `*`)
   - **Enviar Email (Gmail)** (envia para `cantinhodanarusca@gmail.com`)
   - **Responder 200** (confirma ao site que recebeu)

## Passo 2 — Ligar a conta Gmail

1. Abrir o nó **Enviar Email (Gmail)**.
2. Em **Credential to connect with**, criar/selecionar uma credencial
   **Gmail OAuth2** (liga a conta Google que vai *enviar* os avisos — pode ser a
   própria `cantinhodanarusca@gmail.com` ou outra).
3. O destinatário já está definido: `cantinhodanarusca@gmail.com`.

> **Alternativa sem OAuth:** se preferir não configurar OAuth do Google,
> substitua o nó Gmail por um nó **Send Email (SMTP)** usando uma
> *App Password* do Gmail. O assunto/corpo e as ligações são iguais.

## Passo 3 — Ativar e copiar o URL

1. **Guardar** e **ativar** o workflow (toggle no canto superior direito).
2. Abrir o nó **Webhook - Formulario** e copiar o **Production URL**
   (algo como `https://o-teu-n8n.../webhook/nara-orcamento`).

## Passo 4 — Colar o URL no site

No ficheiro `index.html`, localizar e substituir:

```js
const WEBHOOK_URL = "SUBSTITUIR_AQUI";
```

por:

```js
const WEBHOOK_URL = "https://o-teu-n8n.../webhook/nara-orcamento";
```

Pronto. A partir daqui, cada submissão do formulário chega por email à Nara.

---

## Dados recebidos pelo webhook (`$json.body`)

| Campo           | Acesso no n8n                   | Exemplo                       |
|-----------------|---------------------------------|-------------------------------|
| `nome`          | `{{ $json.body.nome }}`         | Maria Silva                   |
| `telefone`      | `{{ $json.body.telefone }}`     | 912 345 678                   |
| `email`         | `{{ $json.body.email }}`        | maria@email.com               |
| `data_evento`   | `{{ $json.body.data_evento }}`  | 2026-07-12                    |
| `local_evento`  | `{{ $json.body.local_evento }}` | Matosinhos                    |
| `tipo_evento`   | `{{ $json.body.tipo_evento }}`  | Aniversário                   |
| `convidados`    | `{{ $json.body.convidados }}`   | 30                            |
| `servicos`      | `{{ $json.body.servicos }}`     | ["Salgados", "Bolo decorado"] |
| `mensagem`      | `{{ $json.body.mensagem }}`     | texto livre                   |
| `origem`        | `{{ $json.body.origem }}`       | Landing Page - Nara Mendes... |
| `pagina`        | `{{ $json.body.pagina }}`       | URL da página                 |
| `timestamp`     | `{{ $json.body.timestamp }}`    | 2026-06-16T14:32:00.000Z (ISO)|

---

## Extensões fáceis (adicionar mais nós depois do Webhook)

- **Telegram** — aviso instantâneo no telemóvel (padrão IG Ops).
- **Supabase / Google Sheets** — guardar todos os leads numa base.
- **Notion** — criar um cartão por pedido.
- **Z-API / WhatsApp** — mensagem automática de confirmação ao cliente.

> Dica: o nó **Responder 200** pode ser ligado logo a seguir ao Webhook se
> quiser resposta instantânea ao site e processar email/Telegram em paralelo.
> Na versão atual, responde depois do email para garantir que o lead foi tratado.

## Notas técnicas

- **CORS**: o nó Webhook já tem `allowedOrigins: "*"`. Se quiser restringir,
  troque por `https://igsolutionmkt-lang.github.io` (ou o domínio final).
- **Fallback**: enquanto `WEBHOOK_URL` não estiver configurado — ou se o n8n
  estiver offline — o formulário do site cai automaticamente num botão de
  WhatsApp com os dados preenchidos. Nenhum lead se perde.
