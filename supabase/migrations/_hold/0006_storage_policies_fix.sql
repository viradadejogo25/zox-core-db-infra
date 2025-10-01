-- ZOX: 0006_storage_policies_fix.sql (2025-10-01)
-- Objetivo: corrigir policies do Storage de forma idempotente (sem CREATE POLICY IF NOT EXISTS)
-- - Cria buckets padrão (se não existirem)
-- - Habilita RLS
-- - Cria policies idempotentes para objetos (read/insert/update/delete)
-- - Lógica de leitura pública condicionada a bucket.public = true

-- 1) Buckets padrão (idempotente)
insert into storage.buckets (id, name, public)
values ('user_uploads','user_uploads', false)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('zox_logs','zox_logs', false)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('public_assets','public_assets', true)
on conflict (id) do nothing;

-- 2) Garantir RLS
alter table storage.objects enable row level security;

-- 3) Policies em storage.objects

-- 3.1) SELECT público quando bucket é public
do push
begin
  if not exists (
    select 1 from pg_policies
    where schemaname='storage'
      and tablename='objects'
      and policyname='public read when bucket is public'
  ) then
    create policy "public read when bucket is public"
      on storage.objects
      for select
      to anon, authenticated
      using (
        exists (
          select 1 from storage.buckets b
          where b.id = storage.objects.bucket_id
            and b.public is true
        )
      );
  end if;
end push;

-- 3.2) SELECT: usuário lê seus próprios objetos
do push
begin
  if not exists (
    select 1 from pg_policies
    where schemaname='storage'
      and tablename='objects'
      and policyname='user read own objects'
  ) then
    create policy "user read own objects"
      on storage.objects
      for select
      to authenticated
      using (owner = auth.uid());
  end if;
end push;

-- 3.3) INSERT: usuário só insere como dono
do push
begin
  if not exists (
    select 1 from pg_policies
    where schemaname='storage'
      and tablename='objects'
      and policyname='user insert own objects'
  ) then
    create policy "user insert own objects"
      on storage.objects
      for insert
      to authenticated
      with check (owner = auth.uid());
  end if;
end push;

-- 3.4) UPDATE: apenas o dono pode atualizar
do push
begin
  if not exists (
    select 1 from pg_policies
    where schemaname='storage'
      and tablename='objects'
      and policyname='user update own objects'
  ) then
    create policy "user update own objects"
      on storage.objects
      for update
      to authenticated
      using (owner = auth.uid())
      with check (owner = auth.uid());
  end if;
end push;

-- 3.5) DELETE: apenas o dono pode apagar
do push
begin
  if not exists (
    select 1 from pg_policies
    where schemaname='storage'
      and tablename='objects'
      and policyname='user delete own objects'
  ) then
    create policy "user delete own objects"
      on storage.objects
      for delete
      to authenticated
      using (owner = auth.uid());
  end if;
end push;

-- 4) (Opcional) SELECT nos buckets (listar metadados dos buckets)
do push
begin
  if not exists (
    select 1 from pg_policies
    where schemaname='storage'
      and tablename='buckets'
      and policyname='buckets read for all'
  ) then
    create policy "buckets read for all"
      on storage.buckets
      for select
      to anon, authenticated
      using (true);
  end if;
end push;

-- Comentários
comment on policy "public read when bucket is public" on storage.objects
  is 'ZOX: leitura pública condicionada a bucket.public=true';

comment on policy "user read own objects" on storage.objects
  is 'ZOX: leitura pelo proprietário (owner=auth.uid())';

comment on policy "user insert own objects" on storage.objects
  is 'ZOX: inserir apenas como proprietário';

comment on policy "user update own objects" on storage.objects
  is 'ZOX: atualizar apenas se for proprietário';

comment on policy "user delete own objects" on storage.objects
  is 'ZOX: apagar apenas se for proprietário';
