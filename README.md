# zox-core-db-infra

Infra do banco do ZOX (Supabase):
- Migrations versionadas em `supabase/migrations`
- Edge Functions no Supabase (ex.: `webhook_signals`)
- Regras ZOX: nomenclatura, RLS habilitado, rollback possível

## Comandos úteis
supabase db push
supabase functions deploy webhook_signals
