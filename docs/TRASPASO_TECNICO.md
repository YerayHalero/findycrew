# Find Y Crew — Traspaso técnico v2 (17 oct 2026)

Sustituye a la v1 (5 oct). Audiencia: Joaquim (técnico) y Kilian (visión comercial). Presentación: Canarias, 29/10/2026.

## 1. Qué hay ahora
Un único repositorio estático (`YerayHalero/findycrew`) con **landing + app + demo** que funcionan como ecosistema:
- La landing detecta idioma (ES/EN/DA) y lo pasa a la app (`?lang=`, `localStorage fyc4_lang`).
- La landing incluye un **QR** (generado en el navegador, sin dependencias externas) que abre `app/?demo=1`.
- La app tiene modo **real** (Supabase) y modo **demo** (simulación local, sin red).
- Marca neutra: sin referencias a festivales concretos. Contacto en la web: `hola@findycrew.com` (marcador de posición hasta registrar dominio/correo).

## 2. Arquitectura
| Pieza | Decisión |
|---|---|
| Hosting | GitHub Pages (repo público). Pages en repos privados exige plan de pago. |
| Mapa | Visor propio: imagen ilustrada en un `div` transformado; pan/zoom por pointer events; marcadores DOM. **Sin Leaflet, sin teselas, sin CDN** → carga completa o nada, sin cuadros a medias, funciona offline tras la primera carga. |
| Georreferencia | `center` + `widthM` (metros de ancho de la imagen); `ll2xy` / `xy2ll`. Override `?at=lat,lng`. |
| Tiempo real | Sondeo REST a Supabase cada 3 s (`LIVE_MS`). Posición obsoleta a 5 min, oculta a 30 min. |
| Datos | Tabla `positions` (id, code, name, color, avatar, x=lat, y=lng, status, status_expiry, updated_at). `status` admite `||MEET:lat:lng` (punto de encuentro). |
| Demo | Grafo de caminos trazados a mano + BFS por POI; 6 bots y ~600 asistentes simulados; mapa de calor del organizador con k‑anonimato (K_MIN = 10); tiempo simulado. |
| i18n | Diccionario `TR` + `t()` (ES/EN/DA). |
| QR | qrcode-generator (MIT, K. Arase) minificado; canvas en la app, SVG en la landing. `assets/qr-demo.svg/png` para flyers/dossier. |

## 2b. Panel del organizador (demo, 17 oct)
- Entrada a la demo con selector de rol (`role=fan|org`). El QR lleva al selector.
- Organizador, 4 pestañas: **En vivo** (KPIs, alertas de aforo ≥90 % con histéresis hasta <85 %, hora simulada, aforo por zona), **Tareas** (tipo → zona → prioridad → «Crear y asignar al más cercano»; distancia por caminos del grafo), **Equipo** (staff en turno por rol y estado), **Avisos** (todo el recinto / una zona / solo equipo, con plantillas).
- Capas del mapa conmutables: calor, equipo, incidencias. Asistentes solo agregados (k ≥ 10); el staff sí aparece individualmente (comparte ubicación en turno con consentimiento — Nuria: revisar base legal laboral/GDPR antes de un piloto real).
- Todo es simulado en el navegador (`scratchpad src/h_org.js` → incluido en `app/index.html`). Nada de esto existe aún en el modo real.

## 3. Seguridad — estado honesto
Hecho en cliente: solo se piden filas de los códigos de tu crew; todo dato remoto se escapa (anti‑XSS); se borra tu fila al pasar a invisible y en `pagehide` (`fetch keepalive`); eliminado todo el código de admin/PIN de la versión nueva.
**Pendiente (importante):**
1. La política RLS es `public all`: con la clave pública cualquiera puede leer/escribir/borrar toda la tabla. `supabase/02_rls_fase2_BORRADOR.sql` propone el modelo correcto (auth anónima + `follows` + políticas por usuario), pero **requiere cambios en el cliente que no están hechos**. No ejecutar antes.
2. Ejecutar `supabase/01_cleanup_pgcron.sql` para borrar filas viejas y programar limpieza cada 5 min (la promesa «tu posición se borra al salir» solo es completamente cierta con esto activo).
3. El proyecto Supabase aún se llama «copenhell-2026» (solo visible en el panel; renombrar en Settings → General; la URL/ref no cambia).
4. Repo antiguo `copenhell-app` es público y contiene `ADMIN_CODE` y `COORD_PINS`: archivar o poner privado, y considerar esos valores quemados.

## 4. Pruebas
Hechas (Playwright/Chromium, Supabase simulado con dos clientes): demo completa, UI de onboarding/ajustes, sincronización entre dos clientes, escape de datos, QR decodificado con OpenCV, enlaces con idioma, `node --check`.
**No hechas:** móviles reales (iOS Safari / Android Chrome), GPS real en recinto, `pagehide` DELETE en navegadores reales (solo se despachó el evento), batería, Supabase real bajo carga. Capturas hechas con fuente de reserva (Google Fonts bloqueado en el entorno de pruebas).
Plan: el 27 oct, prueba con 2 móviles reales (recordatorio en calendario).

## 5. Operación (plan gratuito de Supabase)
Se pausa tras ~1 semana sin actividad. Mitigación: `.github/workflows/supabase-keepalive.yml` (consulta cada 2 días; la clave anon es pública por diseño) + recordatorios de calendario (21, 25, 27 y 28 oct). Si se pausa: panel Supabase → *Restore project*.

## 6. ¿QR a la demo = riesgo de que nos copien la idea?
Valoración (probabilística, no asesoría legal):
- **Las ideas no están protegidas**; lo que vale es ejecución, relaciones con organizadores, marca y datos. Un competidor con cierto nivel puede replicar la funcionalidad visible de *cualquier* web app con o sin QR.
- El **código del front-end es visible** en cualquier web app. La demo es una simulación autocontenida: **no expone backend, claves de producción ni datos reales**.
- Lo realmente valioso (acuerdos con festivales, algoritmos de agregación finos, base de usuarios) no está en la demo.
- Recomendaciones: no poner en flyers la URL del modo real; mantener `LICENSE` de derechos reservados; registrar la marca (SKAT/DKPTO — verificar organismo en Dinamarca) antes de difundir; acuerdo escrito corto con Joaquim sobre autoría/cesión (un freelance puede conservar derechos de autor por defecto); considerar repo privado + otro hosting cuando haya algo sensible.
- Veredicto: **buena idea** para clientes potenciales y para mostrar valor; riesgo bajo‑moderado y asumible en esta fase.

## 7. Siguientes pasos
1. Merge del PR y activar Pages. 2. Ejecutar `01_cleanup_pgcron.sql`. 3. Prueba con 2 móviles. 4. Archivar/privatizar `copenhell-app`. 5. Decidir auth anónima y migrar a RLS (fase 2). 6. Registrar marca, dominio y correo; sustituir el marcador de contacto.
