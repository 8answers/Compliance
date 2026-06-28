create extension if not exists pgcrypto;

create table if not exists public.inspections (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references auth.users(id) on delete cascade,
  institution_type text not null check (
    institution_type in (
      'Education',
      'Residential',
      'Workplace',
      'Community',
      'Other'
    )
  ),
  age_groups text[] not null default '{}'::text[] check (
    cardinality(age_groups) > 0
    and age_groups <@ array[
      '2–5 Years',
      '6–12 Years',
      '13–18 Years',
      '19–30 Years',
      '31–50 Years',
      '51–60 Years',
      '60+ Years',
      'Mixed Age Group'
    ]::text[]
  ),
  diet_types text[] not null default '{}'::text[] check (
    cardinality(diet_types) > 0
    and diet_types <@ array[
      'Vegetarian',
      'Non-Vegetarian',
      'Eggetarian',
      'Vegan',
      'Jain'
    ]::text[]
  ),
  meals_served text[] not null default '{}'::text[] check (
    cardinality(meals_served) > 0
    and meals_served <@ array[
      'Breakfast',
      'Lunch',
      'Dinner',
      'Morning Snack',
      'Afternoon Snack',
      'Night Snack'
    ]::text[]
  ),
  region text not null check (
    region in (
      'North India',
      'South India',
      'East India',
      'West India',
      'Central India',
      'North-East India'
    )
  ),
  menu_entry_method text not null default 'upload_file' check (
    menu_entry_method in ('upload_file', 'typed_menu')
  ),
  menu_file_name text,
  menu_file_size_bytes bigint check (
    menu_file_size_bytes is null or menu_file_size_bytes >= 0
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.inspections
add column if not exists menu_entry_method text not null default 'upload_file'
check (menu_entry_method in ('upload_file', 'typed_menu'));

alter table public.inspections
add column if not exists menu_file_name text;

alter table public.inspections
add column if not exists menu_file_size_bytes bigint
check (menu_file_size_bytes is null or menu_file_size_bytes >= 0);

alter table public.inspections enable row level security;

drop policy if exists "Users can read own inspections" on public.inspections;
create policy "Users can read own inspections"
on public.inspections
for select
to authenticated
using (auth.uid() = created_by);

drop policy if exists "Users can insert own inspections" on public.inspections;
create policy "Users can insert own inspections"
on public.inspections
for insert
to authenticated
with check (auth.uid() = created_by);

drop policy if exists "Users can update own inspections" on public.inspections;
create policy "Users can update own inspections"
on public.inspections
for update
to authenticated
using (auth.uid() = created_by)
with check (auth.uid() = created_by);

drop policy if exists "Users can delete own inspections" on public.inspections;
create policy "Users can delete own inspections"
on public.inspections
for delete
to authenticated
using (auth.uid() = created_by);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_inspections_updated_at on public.inspections;
create trigger set_inspections_updated_at
before update on public.inspections
for each row
execute function public.set_updated_at();

grant select, insert, update, delete on public.inspections to authenticated;
