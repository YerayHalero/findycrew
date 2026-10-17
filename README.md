# Find Y Crew

Web + app para encontrar a tu grupo en un festival sin perder la batería ni compartir tu ubicación con desconocidos.

- **Landing:** `index.html` (ES / EN / DA, comparte idioma con la app).
- **App (PWA):** `app/index.html` — modo real y modo demo.
- **Demo sin backend:** `app/?demo=1` → pregunta al entrar si eres asistente u organizador (es lo que enlaza el QR). Accesos directos: `?demo=1&role=fan` (app del asistente) y `?demo=1&role=org` (panel del organizador: mapa de calor, aforo y alertas, tareas al staff más cercano, avisos por zona).

## Estructura
```
index.html            landing + sección #prueba con QR generado en el navegador
app/index.html        app (mapa propio sin tiles, tiempo real, i18n, demo)
app/manifest.webmanifest
assets/               mapa ilustrado, capturas, iconos, qr-demo.svg/png (para flyers/dossier)
supabase/             01_cleanup_pgcron.sql (ejecutar) · 02_rls_fase2_BORRADOR.sql (NO ejecutar aún)
.github/workflows/    supabase-keepalive.yml (evita la pausa del plan gratuito)
docs/                 TRASPASO_TECNICO.md · consent-mockup.html
```

## Probar en local
```
python3 -m http.server 8080
# http://localhost:8080/            landing
# http://localhost:8080/app/?demo=1 demo
```
Parámetros útiles: `?lang=es|en|da` · `?at=lat,lng` (simula que estás en esa posición; útil para probar fuera del recinto).

## Publicación (GitHub Pages)
Settings → Pages → *Deploy from a branch* → `main` / root. URL esperada: `https://yerayhalero.github.io/findycrew/`.

## Backend
Supabase (plan gratuito), tabla `positions`. Ver `docs/TRASPASO_TECNICO.md` para el estado de seguridad: **la política RLS actual es abierta**; el cliente solo pide las filas de tu crew y borra la tuya al salir, pero no es una barrera real. Aceptable para una demo con datos de prueba; no para un evento real.

## Privacidad (principios del producto)
Posición solo entre quienes se han añadido por código · se borra al salir/caducar (30 min) · el organizador solo ve agregados con k ≥ 10 · sin cuentas ni correo en esta fase.

© 2026 YM Enterprise. Todos los derechos reservados (ver `LICENSE`).
