-- ===== Contagem de Bebidas — Mercearia Amauri =====
-- Cole este arquivo no Supabase em: SQL Editor > New query > Run
-- Depois rode o seed.sql (cadastro inicial de produtos e ambientes).

-- Um único armazém de documentos: cada linha é um "papel" do app
-- (produto, ambiente, usuário, contagem, lançamentos de um ambiente...).
create table if not exists docs (
  path text primary key,
  col text not null,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create index if not exists docs_col_idx on docs (col);

-- Junta o novo conteúdo com o que já está gravado, campo a campo.
-- É isso que deixa duas pessoas lançarem produtos diferentes do mesmo
-- ambiente ao mesmo tempo sem uma apagar o trabalho da outra.
create or replace function jsonb_merge_deep(a jsonb, b jsonb)
returns jsonb language sql immutable as $$
  select case
    when jsonb_typeof(a) <> 'object' or jsonb_typeof(b) <> 'object' then b
    else (
      select coalesce(jsonb_object_agg(k, v), '{}'::jsonb) from (
        select k,
          case
            when a ? k and b ? k then jsonb_merge_deep(a->k, b->k)
            when b ? k then b->k
            else a->k
          end as v
        from (select jsonb_object_keys(a) as k union select jsonb_object_keys(b)) ks
      ) m
    )
  end
$$;

create or replace function doc_merge(p_path text, p_col text, p_patch jsonb)
returns void language plpgsql as $$
begin
  insert into docs (path, col, data, updated_at)
  values (p_path, p_col, p_patch, now())
  on conflict (path) do update
    set data = jsonb_merge_deep(docs.data, excluded.data),
        updated_at = now();
end $$;

-- Atualização em tempo real entre os celulares
do $$
begin
  begin
    alter publication supabase_realtime add table docs;
  exception when duplicate_object then null;
  end;
end $$;
alter table docs replica identity full;

-- Acesso: o app entra com a chave pública (anon) e identifica a pessoa pelo PIN.
-- O PIN é guardado como hash (SHA-256), mas quem tiver o endereço do app e a chave
-- pública consegue ler os dados por fora dele — mantenha o link só com a equipe.
alter table docs enable row level security;
drop policy if exists app_all on docs;
create policy app_all on docs for all to anon using (true) with check (true);

-- Consultas prontas para relatório no próprio Supabase
create or replace view v_produtos as
  select path, data->>'codigo' as codigo, data->>'descricao' as descricao, data->>'categoria' as categoria,
         data->>'unidade' as unidade, data->>'forma' as forma, (data->>'ativo')::boolean as ativo, data
  from docs where col = 'produtos';
create or replace view v_contagens as
  select path, data->>'data' as data, data->>'responsavel' as responsavel, data->>'status' as status, data
  from docs where col = 'contagens';
