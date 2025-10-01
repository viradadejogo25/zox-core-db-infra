drop policy if exists "public read when bucket is public" on storage.objects;
drop policy if exists "user read own objects"           on storage.objects;
drop policy if exists "user insert own objects"         on storage.objects;
drop policy if exists "user update own objects"         on storage.objects;
drop policy if exists "user delete own objects"         on storage.objects;
drop policy if exists "buckets read for all"            on storage.buckets;
