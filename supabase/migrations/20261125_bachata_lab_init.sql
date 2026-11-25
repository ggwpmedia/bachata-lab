-- Bachata Lab: Tabelle + privater Video-Bucket, pro Konto per Row Level Security getrennt.
-- Läuft im Supabase-Projekt "HeimWerk" mit, berührt dort aber nichts Bestehendes (alles mit Präfix bachata).
create table if not exists public.bachata_tutorials (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 200),
  style text not null default 'Sensual',
  category text not null default 'Grundschritte',
  level smallint not null default 2 check (level between 1 and 5),
  role text not null default 'Beide',
  duration integer check (duration is null or duration between 0 and 600),
  teacher text not null default '',
  counts text not null default '',
  tags text[] not null default '{}',
  notes text not null default '' check (char_length(notes) <= 20000),
  links text[] not null default '{}',
  video_path text,
  video_bytes bigint not null default 0 check (video_bytes >= 0),
  status text not null default 'offen' check (status in ('offen','wunsch','lernen','kann')),
  confidence smallint not null default 0 check (confidence between 0 and 100),
  favorite boolean not null default false,
  practice_count integer not null default 0 check (practice_count >= 0),
  last_practiced timestamptz,
  example boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists bachata_tutorials_user_created_idx on public.bachata_tutorials (user_id, created_at desc);

create or replace function public.bachata_touch_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin new.updated_at := now(); return new; end $$;
drop trigger if exists bachata_tutorials_touch on public.bachata_tutorials;
create trigger bachata_tutorials_touch before update on public.bachata_tutorials
  for each row execute function public.bachata_touch_updated_at();

alter table public.bachata_tutorials enable row level security;
drop policy if exists "bachata_select_own" on public.bachata_tutorials;
drop policy if exists "bachata_insert_own" on public.bachata_tutorials;
drop policy if exists "bachata_update_own" on public.bachata_tutorials;
drop policy if exists "bachata_delete_own" on public.bachata_tutorials;
create policy "bachata_select_own" on public.bachata_tutorials for select to authenticated using ((select auth.uid()) = user_id);
create policy "bachata_insert_own" on public.bachata_tutorials for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "bachata_update_own" on public.bachata_tutorials for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "bachata_delete_own" on public.bachata_tutorials for delete to authenticated using ((select auth.uid()) = user_id);
revoke all on public.bachata_tutorials from anon;
grant select, insert, update, delete on public.bachata_tutorials to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('bachata-videos', 'bachata-videos', false, 52428800, array['video/*'])
on conflict (id) do nothing;
drop policy if exists "bachata_videos_select_own" on storage.objects;
drop policy if exists "bachata_videos_insert_own" on storage.objects;
drop policy if exists "bachata_videos_update_own" on storage.objects;
drop policy if exists "bachata_videos_delete_own" on storage.objects;
create policy "bachata_videos_select_own" on storage.objects for select to authenticated
  using (bucket_id = 'bachata-videos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "bachata_videos_insert_own" on storage.objects for insert to authenticated
  with check (bucket_id = 'bachata-videos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "bachata_videos_update_own" on storage.objects for update to authenticated
  using (bucket_id = 'bachata-videos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "bachata_videos_delete_own" on storage.objects for delete to authenticated
  using (bucket_id = 'bachata-videos' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- Für bestehende Installationen
alter table public.bachata_tutorials add column if not exists video_bytes bigint not null default 0;
