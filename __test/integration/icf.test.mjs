/**
 * ICF Shim Integration Test Runner.
 * Runs shared scenarios against the local Express + ICF shim server.
 */
import { describe, it, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { startServer } from './helpers/icf-server.mjs';
import { postExecutionTests, getTests, methodTests, errorFormatTests } from './scenarios.mjs';

const BASE_URL = 'http://localhost:3040/zasis';
const RULESET = 'TestRS';

let server;

before(async () => {
  server = await startServer(true);
});

after(async () => {
  server.close();
});

async function request(method, path, { body, contentType = 'application/json' } = {}) {
  const url = `${BASE_URL}${path}`;
  const headers = { 'Content-Type': contentType };
  const options = { method, headers };
  if (body !== undefined) {
    options.body = typeof body === 'string' ? body : JSON.stringify(body);
  }
  const res = await fetch(url, options);
  let responseBody;
  const ct = res.headers.get('content-type') || '';
  if (ct.includes('application/json')) {
    // The transpiled /ui2/cl_json may emit unquoted hex/numc values — fix before parsing
    let text = await res.text();
    text = text.replace(/:([0-9A-Fa-f]{16,})/g, ':"$1"');
    responseBody = JSON.parse(text);
  } else {
    responseBody = await res.text();
  }
  return { status: res.status, body: responseBody };
}

// Run all shared scenarios
postExecutionTests(describe, it, assert, request, RULESET);
getTests(describe, it, assert, request, RULESET);
methodTests(describe, it, assert, request, RULESET);
errorFormatTests(describe, it, assert, request, RULESET);
