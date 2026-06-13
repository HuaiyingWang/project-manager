create table if not exists public.project_owners (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

alter table public.project_owners enable row level security;

drop policy if exists "登入者可以查看負責人" on public.project_owners;
create policy "登入者可以查看負責人"
on public.project_owners for select
to authenticated
using (true);

drop policy if exists "登入者可以新增負責人" on public.project_owners;
create policy "登入者可以新增負責人"
on public.project_owners for insert
to authenticated
with check (true);

drop policy if exists "登入者可以修改負責人" on public.project_owners;
create policy "登入者可以修改負責人"
on public.project_owners for update
to authenticated
using (true)
with check (true);

drop policy if exists "登入者可以刪除負責人" on public.project_owners;
create policy "登入者可以刪除負責人"
on public.project_owners for delete
to authenticated
using (true);

insert into public.project_owners (name)
select distinct trim(owner)
from public.projects
where owner is not null and trim(owner) <> ''
on conflict (name) do nothing;

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'project_owners'
  ) then
    alter publication supabase_realtime add table public.project_owners;
  end if;
end $$;
