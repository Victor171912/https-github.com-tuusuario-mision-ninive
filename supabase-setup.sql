-- Ejecutar una sola vez en Supabase > SQL Editor.
-- Esta tabla almacena el ranking compartido del juego.

create table if not exists public.ranking (
    id bigint generated always as identity primary key,
    nombre text not null check (char_length(nombre) between 1 and 30),
    puntaje integer not null check (puntaje >= 0),
    creado_en timestamptz not null default now()
);

alter table public.ranking enable row level security;

drop policy if exists "ranking público: lectura" on public.ranking;
create policy "ranking público: lectura"
    on public.ranking for select
    to anon, authenticated
    using (true);

drop policy if exists "ranking público: insertar" on public.ranking;
create policy "ranking público: insertar"
    on public.ranking for insert
    to anon, authenticated
    with check (char_length(nombre) between 1 and 30 and puntaje >= 0);

insert into public.ranking (nombre, puntaje)
select * from (values
    ('Victor', 1555),
    ('Yorleny', 905),
    ('Adamarle', 760),
    ('Carol', 705),
    ('Elena', 545)
) as inicial(nombre, puntaje)
where not exists (select 1 from public.ranking);
