# FieldOps — Cloudflare Workers + D1 + R2

Attendance with high-accuracy GPS, live map, expenses, leave approvals, bike odometer photos (auto-compressed to ~200 KB, OCR + manual edit in the same box), and CSV exports. Built for 10 employees + 3 owner admins.

## Deploy (about 10 minutes)
1. `npm install`
2. `npx wrangler login`
3. Create the database: `npx wrangler d1 create fieldops-db` → paste the printed `database_id` into `wrangler.toml`
4. Create photo storage: `npx wrangler r2 bucket create fieldops-photos`
5. Create tables: `npm run db:init:remote`
6. Create the first owner: `node seed-admin.mjs "Admin" admin 12345`, then run  
   `npx wrangler d1 execute fieldops-db --remote --command "<the INSERT it printed>"`
7. Check `WORK_TIMEZONE_OFFSET_MINUTES` in `wrangler.toml` (330 = India)
8. `npm run deploy` → open the `*.workers.dev` URL, sign in at `/login.html`
9. In **Admin → People**, add the other 2 owners (role Admin) and 10 employees (role Employee)

## How the requirements map
- **Mandatory high-accuracy location**: clock in/out calls GPS with `enableHighAccuracy`; the server rejects any clock event without lat/lng.
- **Live monitoring**: while clocked in, the phone sends a location ping every 60 seconds; Admin → Live map refreshes every 30 s. Employees vanish from the map after clock-out.
- **Photos → 200 KB**: compressed in the browser (resize + JPEG quality loop) before upload to R2.
- **OCR + manual**: Tesseract.js reads the digits and fills the reading box; the same box stays editable. The source (`ocr`, `ocr_edited`, `manual`) is saved and exported.
- **CSV exports** (Admin → Exports, filter by date/employee): attendance with clock in/out coordinates, accuracy and working hours; expenses; leave; bike readings with photo links and km driven.

## Known limits (be aware before going live)
- Location pings (every 60 s) only run while the employee's page is open in the browser; mobile browsers pause background tabs. For true background tracking you'd need a native/PWA-with-background-sync approach.
- OCR on odometer photos is imperfect (digital vs. analog dials, glare), which is why manual edit is always available.
- Auth is a simple email + PIN with salted SHA-256 hashing; fine for a small private team, but add login rate limiting (Cloudflare WAF rule) before wider use.
- Admin map uses OpenStreetMap tiles; employees' IDs/PINs are managed in the People tab (no PIN reset UI yet — disable and re-add).
