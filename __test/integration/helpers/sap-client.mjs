/**
 * SAP client helper.
 * Loads connection config from http-client.env.json and provides a request function.
 */
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const envPath = resolve(__dirname, '../../http/http-client.env.json');

let allEnvs = {};
try {
  const raw = readFileSync(envPath, 'utf-8');
  const parsed = JSON.parse(raw);
  for (const [key, value] of Object.entries(parsed)) {
    if (key.startsWith('sap') && value.baseUrl && value.auth_b64) {
      allEnvs[key] = value;
    }
  }
} catch {
  allEnvs = {};
}

/** Returns the default 'sap' environment (legacy). */
export function getSapEnv() {
  return allEnvs['sap'] || null;
}

/** Returns all sap* environments as { key: envConfig } pairs. */
export function getAllSapEnvs() {
  return allEnvs;
}

export function isSapAvailable() {
  return Object.keys(allEnvs).length > 0;
}
