/**
 * SAP Integration Test Runner.
 * Runs shared scenarios against a real SAP system.
 * Requires credentials in __test/http/http-client.env.json.
 *
 * Run: node --test __test/integration/sap.test.mjs
 */
import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import { getAllSapEnvs, isSapAvailable } from './helpers/sap-client.mjs';
import { postExecutionTests, getTests, methodTests } from './scenarios.mjs';

before(() => {
  if (!isSapAvailable()) {
    throw new Error(
      'SAP connection not configured. Create __test/http/http-client.env.json with sap.baseUrl, sap.client, sap.auth_b64.'
    );
  }
});

const envs = getAllSapEnvs();

for (const [envName, env] of Object.entries(envs)) {
  const ruleSetId = env.ruleSetId || 'MySample';

  function makeRequest(method, path, { body, contentType = 'application/json' } = {}) {
    const queryParams = env.queryParams || (env.client ? `?sap-client=${env.client}` : '');
    const url = `${env.baseUrl}${path}${queryParams}`;
    const headers = {
      'Authorization': `Basic ${env.auth_b64}`,
      'Accept': 'application/json',
      'Content-Type': contentType,
    };
    const options = { method, headers };
    if (body !== undefined) {
      options.body = typeof body === 'string' ? body : JSON.stringify(body);
    }
    return fetch(url, options).then(async (res) => {
      let responseBody;
      const ct = res.headers.get('content-type') || '';
      if (ct.includes('application/json')) {
        responseBody = await res.json();
      } else {
        responseBody = await res.text();
      }
      return { status: res.status, body: responseBody };
    });
  }

  describe(`[${envName}]`, () => {
    postExecutionTests(describe, it, assert, makeRequest, ruleSetId);
    getTests(describe, it, assert, makeRequest, ruleSetId);
    methodTests(describe, it, assert, makeRequest, ruleSetId);
  });
}
