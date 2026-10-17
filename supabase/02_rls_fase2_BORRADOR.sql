-- ─────────────────────────────────────────────────────────────────────────────
-- Find Y Crew · 02 · Seguridad real (RLS) — BORRADOR, NO EJECUTAR TODAVÍA
--
-- Estado hoy: la tabla `positions` tiene una única política "public all" (ALL, true),
-- es decir, cualquiera con la clave pública puede leer/escribir/borrar TODO.
-- La app actual ya solo PIDE las filas de tu crew, pero eso es cortesía del cliente,
-- no una barrera: alguien con herramientas de desarrollador puede pedirlas todas.
--
-- Este borrador cierra eso. Para que funcione hace falta ANTES:
--   a) Activar "Anonymous sign-ins" (Authentication → Sign In / Providers).
--   b) Cambiar el cliente (app/index.html) para: crear sesión anónima, enviar el JWT
--      en Authorization, y escribir/leer `follows`. Eso NO está hecho aún.
-- Si se ejecuta sin (b), la app deja de funcionar. Probar primero en un proyecto
-- Supabase de pruebas, nunca directamente en el de producción.
--
-- Modelo: "poseer el código de alguien = su consentimiento" (código aleatorio de
-- 6 caracteres, ≈1.000 millones de combinaciones). Cada usuario solo puede ESCRIBIR
-- y BORRAR su propia fila, y solo puede LEER las filas de códigos que ha añadido.
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.positions add column if not exists user_id uuid default auth.uid();

create table if not exists public.follows (
  owner       uuid not null default auth.uid(),
  friend_code text not null check (friend_code ~ '^[A-Z0-9]{6}$'),
  created_at  timestamptz not null default now(),
  primary key (owner, friend_code)
);
alter table public.follows enable row level security;

drop policy if exists follows_own on public.follows;
create policy follows_own on public.follows
  for all to authenticated using (owner = auth.uid()) with check (owner = auth.uid());

drop policy if exists "public all" on public.positions;

drop policy if exists pos_insert_own on public.positions;
create policy pos_insert_own on public.positions
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists pos_update_own on public.positions;
create policy pos_update_own on public.positions
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists pos_delete_own on public.positions;
create policy pos_delete_own on public.positions
  for delete to authenticated using (user_id = auth.uid());

drop policy if exists pos_read_followed on public.positions;
create policy pos_read_followed on public.positions
  for select to authenticated using (
    user_id = auth.uid()
    or exists (select 1 from public.follows f where f.owner = auth.uid() and f.friend_code = positions.code)
  );

-- Añadir un amigo por código sin permitir listar la tabla: función que solo devuelve
-- el perfil público (nombre/color/avatar) de UN código concreto.
create or replace function public.lookup_code(p_code text)
returns table(code text, name text, color text, avatar text)
language sql security definer set search_path = public as $$
  select code, name, color, avatar from public.positions where code = upper(p_code) limit 1
$$;
revoke all on function public.lookup_code(text) from public;
grant execute on function public.lookup_code(text) to authenticated;
