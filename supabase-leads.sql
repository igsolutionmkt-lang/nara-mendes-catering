-- ============================================================
-- Nara Mendes Catering — tabela de leads (pedidos de orçamento)
-- Colar e correr no SQL Editor do projeto Supabase
-- ("NaraMendesCatering's Project")
--
-- Payload enviado pelo formulário boutique:
-- { nome, telefone, data_evento, tipo_evento, convidados,
--   mensagem, consentimento, origem, pagina, timestamp }
-- ============================================================

create table if not exists public.leads (
  id           uuid primary key default gen_random_uuid(),
  nome         text not null,
  telefone     text not null,
  data_evento  date,
  tipo_evento  text,
  convidados   integer,
  mensagem     text,
  origem       text,
  pagina       text,
  criado_em    timestamptz not null default now()
);

-- Índice para ordenar/filtrar por data de entrada
create index if not exists leads_criado_em_idx on public.leads (criado_em desc);

-- RLS ligado: ninguém acede pela chave pública.
-- O n8n grava usando a SERVICE ROLE KEY (que ignora RLS).
alter table public.leads enable row level security;

-- (Opcional) Se mais tarde quiseres uma app/admin a LER os leads
-- com a chave pública, cria uma policy específica. Por agora,
-- só o n8n (service role) escreve e lê.

comment on table public.leads is 'Pedidos de orçamento do site Nara Mendes Catering';
