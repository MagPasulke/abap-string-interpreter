/**
 * SAP client helper.
 * Loads connection config from http-client.env.json and provides a request function.
 */
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const envPath = resolve(__dirname, '../../http/http-client.env.json');

let env;
try {
  const raw = readFileSync(envPath, 'utf-8');
  env = JSON.parse(raw)['local'];
} catch {
  env = null;
}

export function getSapEnv() {
  return env;
}

export function isSapAvailable() {
  return env !== null && env.baseUrl && env.auth_b64;
}
