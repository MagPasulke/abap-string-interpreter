/**
 * SAP-Only Authorization Tests.
 * These scenarios CANNOT run against the ICF shim (AUTHORITY-CHECK is a no-op there).
 *
 * Run: node --test __test/integration/sap-auth.test.mjs
 */
import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import { getSapEnv, isSapAvailable } from './helpers/sap-client.mjs';

before(() => {
  if (!isSapAvailable()) {
    throw new Error(
      'SAP connection not configured. Create __test/http/http-client.env.json with local.baseUrl, local.client, local.auth_b64.'
    );
  }
});

const env = getSapEnv() || {};
const RULESET = 'MySample';

async function requestWithoutAuth(method, path) {
  const url = `${env.baseUrl}${path}?sap-client=${env.client}`;
  const res = await fetch(url, {
    method,
    headers: { 'Accept': 'application/json' },
  });
  return { status: res.status };
}

describe('Authorization (SAP-only)', () => {

  it('GET without auth returns 401 or 403', async () => {
    const { status } = await requestWithoutAuth('GET', `/ruleSet/${RULESET}`);
    assert.ok([401, 403].includes(status), `Expected 401 or 403, got ${status}`);
  });

  it('POST without auth returns 401 or 403', async () => {
    const url = `${env.baseUrl}/ruleSetExecution/${RULESET}?sap-client=${env.client}`;
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ string_to_be_interpreted: 'test' }),
    });
    assert.ok([401, 403].includes(res.status), `Expected 401 or 403, got ${res.status}`);
  });

});
