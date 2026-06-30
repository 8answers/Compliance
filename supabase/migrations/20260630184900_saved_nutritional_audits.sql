alter table public.inspections
add column if not exists audit_number integer
check (audit_number is null or audit_number > 0);

alter table public.inspections
add column if not exists nutritional_report jsonb;

alter table public.inspections
add column if not exists report_created_at timestamptz;

alter table public.inspections
add column if not exists report_deleted_at timestamptz;

create index if not exists inspections_created_by_audit_number_idx
on public.inspections (created_by, audit_number desc)
where audit_number is not null;
