insert into storage.buckets (id, name, public) values ('user_uploads','user_uploads', false) on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('zox_logs','zox_logs', false) on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('public_assets','public_assets', true) on conflict (id) do nothing;

create policy if not exists "user read own uploads"
on storage.objects for select to authenticated
using (bucket_id = 'user_uploads' and owner = auth.uid());

create policy if not exists "user write own uploads"
on storage.objects for insert to authenticated
with check (bucket_id = 'user_uploads' and owner = auth.uid());

create policy if not exists "service read/write logs"
on storage.objects for all to service_role
using (bucket_id = 'zox_logs') with check (bucket_id = 'zox_logs');

create policy if not exists "public read assets"
on storage.objects for select to anon
using (bucket_id = 'public_assets');

create policy if not exists "service write public assets"
on storage.objects for insert to service_role
with check (bucket_id = 'public_assets');
