-- ─────────────────────────────────────────────────────────────────────────────
-- Find Y Crew · 01 · Limpieza automática de posiciones antiguas
-- Dónde: Supabase → SQL Editor → pegar → Run.   Es seguro: solo BORRA filas viejas.
-- Por qué: el navegador borra tu fila al cerrar (pagehide), pero los móviles a veces
--          cancelan esa petición. Esta tarea borra en el servidor lo que quede.
-- La app deja de mostrar a alguien a los 30 min sin actualizar; aquí se borra a los 30 min.
-- ─────────────────────────────────────────────────────────────────────────────

-- 1) Borrado único ahora mismo (limpia las filas de prueba antiguas)
delete from public.positions
 where updated_at < (extract(epoch from now()) * 1000 - 1800000);

-- 2) Tarea programada cada 5 minutos (extensión pg_cron).
--    Si falla con "extension pg_cron is not available", actívala en:
--    Database → Extensions → pg_cron → Enable, y vuelve a ejecutar esta parte.
create extension if not exists pg_cron;

select cron.schedule(
  'fyc-cleanup-positions',
  '*/5 * * * *',
  $$ delete from public.positions
      where updated_at < (extract(epoch from now()) * 1000 - 1800000) $$
);

-- Comprobar que está programada:
--   select jobid, schedule, jobname, active from cron.job;
-- Desactivar si hiciera falta:
--   select cron.unschedule('fyc-cleanup-positions');
