-- Ejecutar una sola vez en Supabase > SQL Editor.
-- Separa los puntajes de Jonás y Jueces.

create table if not exists public.ranking_jonas (
    id bigint generated always as identity primary key,
    nombre text not null check (char_length(nombre) between 1 and 30),
    puntaje integer not null check (puntaje >= 0),
    creado_en timestamptz not null default now()
);

create table if not exists public.ranking_jueces (
    id bigint generated always as identity primary key,
    nombre text not null check (char_length(nombre) between 1 and 30),
    puntaje integer not null check (puntaje >= 0),
    creado_en timestamptz not null default now()
);

alter table public.ranking_jonas enable row level security;
alter table public.ranking_jueces enable row level security;

drop policy if exists "jonas lectura pública" on public.ranking_jonas;
create policy "jonas lectura pública" on public.ranking_jonas
for select to anon, authenticated using (true);

drop policy if exists "jonas insertar puntajes" on public.ranking_jonas;
create policy "jonas insertar puntajes" on public.ranking_jonas
for insert to anon, authenticated
with check (char_length(nombre) between 1 and 30 and puntaje >= 0);

drop policy if exists "jueces lectura pública" on public.ranking_jueces;
create policy "jueces lectura pública" on public.ranking_jueces
for select to anon, authenticated using (true);

drop policy if exists "jueces insertar puntajes" on public.ranking_jueces;
create policy "jueces insertar puntajes" on public.ranking_jueces
for insert to anon, authenticated
with check (char_length(nombre) between 1 and 30 and puntaje >= 0);

create unique index if not exists ranking_jonas_nombre_unico
on public.ranking_jonas (lower(trim(nombre)));

create unique index if not exists ranking_jueces_nombre_unico
on public.ranking_jueces (lower(trim(nombre)));

do $$
begin
    if to_regclass('public.ranking') is not null then
        insert into public.ranking_jonas (nombre, puntaje, creado_en)
        select antiguo.nombre, antiguo.puntaje, antiguo.creado_en
        from (
            select distinct on (lower(trim(nombre)))
                nombre, puntaje, creado_en
            from public.ranking
            order by lower(trim(nombre)), puntaje desc, creado_en asc
        ) as antiguo
        where not exists (
            select 1
            from public.ranking_jonas actual
            where lower(trim(actual.nombre)) = lower(trim(antiguo.nombre))
        );
    end if;
end $$;

insert into public.ranking_jonas (nombre, puntaje)
select inicial.nombre, inicial.puntaje
from (values
    ('Victor', 1555),
    ('Yorleny', 905),
    ('Adamarle', 760),
    ('Carol', 705),
    ('Elena', 545)
) as inicial(nombre, puntaje)
where not exists (
    select 1
    from public.ranking_jonas r
    where lower(trim(r.nombre)) = lower(trim(inicial.nombre))
);
