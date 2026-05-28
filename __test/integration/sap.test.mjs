/**
 * SAP Integration Test Runner.
 * Runs shared scenarios against a real SAP system.
 * Requires credentials in __test/http/http-client.env.json.
 *
 * Run: node --test __test/integration/sap.test.mjs
 */
import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import { getSapEnv, isSapAvailable } from './helpers/sap-client.mjs';
import { postExecutionTests, getTests, methodTests } from './scenarios.mjs';

const RULESET = 'MySample';

before(() => {
  if (!isSapAvailable()) {
    throw new Error(
      'SAP connection not configured. Create __test/http/http-client.env.json with local.baseUrl, local.client, local.auth_b64.'
    );
  }
});

const env = getSapEnv() || {};

async function request(method, path, { body, contentType = 'application/json' } = {}) {
  const url = `${env.baseUrl}${path}?sap-client=${env.client}`;
  const headers = {
    'Authorization': `Basic ${env.auth_b64}`,
    'Accept': 'application/json',
    'Content-Type': contentType,
  };
  const options = { method, headers };
  if (body !== undefined) {
    options.body = typeof body === 'string' ? body : JSON.stringify(body);
  }
  const res = await fetch(url, options);
  let responseBody;
  const ct = res.headers.get('content-type') || '';
  if (ct.includes('application/json')) {
    responseBody = await res.json();
  } else {
    responseBody = await res.text();
  }
  return { status: res.status, body: responseBody };
}

// Run all shared scenarios (identical to ICF runner)
postExecutionTests(describe, it, assert, request, RULESET);
getTests(describe, it, assert, request, RULESET);
methodTests(describe, it, assert, request, RULESET);
