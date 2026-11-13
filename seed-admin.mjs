// Usage: node seed-admin.mjs "Owner Name" owner@email.com 1234
// Prints SQL to create the FIRST admin. Then run it with:
//   wrangler d1 execute fieldops-db --remote --command "<printed SQL>"
// After that, sign in and add the other 2 owners and 10 employees from the Admin > People tab.
import { webcrypto, randomUUID } from "node:crypto";
const [name, email, pin] = process.argv.slice(2);
if (!name || !email || !/^\d{4,6}$/.test(pin || "")) {
  console.error('Usage: node seed-admin.mjs "Name" email@example.com 1234   (PIN = 4-6 digits)');
  process.exit(1);
}
const id = randomUUID();
const buf = await webcrypto.subtle.digest("SHA-256", new TextEncoder().encode(pin + "::" + id));
const hash = [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, "0")).join("");
const esc = (s) => s.replace(/'/g, "''");
console.log(`INSERT INTO users (id,name,email,pin_hash,role) VALUES ('${id}','${esc(name)}','${esc(email.toLowerCase())}','${hash}','admin');`);
