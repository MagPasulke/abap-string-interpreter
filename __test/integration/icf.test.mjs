/**
 * ICF Shim Integration Test Runner.
 * Runs shared scenarios against the local Express + ICF shim server.
 */
import { describe, it, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { startServer, setConfig, deleteConfig } from './helpers/icf-server.mjs';
import { postExecutionTests, getTests, methodTests, errorFormatTests, exportTests, bulkTests } from './scenarios.mjs';

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
  return { status: res.status, body: responseBody, headers: Object.fromEntries(res.headers.entries()) };
}

// Run all shared scenarios
postExecutionTests(describe, it, assert, request, RULESET);
getTests(describe, it, assert, request, RULESET);
exportTests(describe, it, assert, request, RULESET);
methodTests(describe, it, assert, request, RULESET);
errorFormatTests(describe, it, assert, request, RULESET);
bulkTests(describe, it, assert, request, RULESET);

// ICF-only: bulk max items read from zasis_config
describe('POST /ruleSetExecution/{id}/bulk with configured BULK_MAX', () => {
  const bulkUrl = `/ruleSetExecution/${RULESET}/bulk`;
  const items = (n) => Array.from({ length: n }, (_, i) => ({ id: `id-${i + 1}`, string_to_be_interpreted: '<Start><A7X>MatA<End>' }));
  const getError = (body) => {
    const envelope = body.ERROR || body.error;
    return { code: envelope.CODE || envelope.code, message: envelope.MESSAGE || envelope.message };
  };

  after(async () => {
    await deleteConfig('BULK_MAX');
  });

  it('Custom limit rejects more items than configured', async () => {
    await setConfig('BULK_MAX', '3');
    const { status, body } = await request('POST', bulkUrl, { body: { items: items(4) } });
    assert.equal(status, 400);
    const error = getError(body);
    assert.equal(error.code, 'ZASIS_MSGS/021');
    assert.ok(error.message.includes('3'), 'Message should name the configured maximum');
  });

  it('Custom limit above default accepts more than 50 items', async () => {
    await setConfig('BULK_MAX', '60');
    const { status } = await request('POST', bulkUrl, { body: { items: items(60) } });
    assert.equal(status, 200);
  });

  it('Invalid value falls back to 50', async () => {
    await setConfig('BULK_MAX', 'abc');
    const { status, body } = await request('POST', bulkUrl, { body: { items: items(51) } });
    assert.equal(status, 400);
    assert.ok(getError(body).message.includes('50'));
  });

  it('Without a row falls back to 50', async () => {
    await deleteConfig('BULK_MAX');
    const ok = await request('POST', bulkUrl, { body: { items: items(50) } });
    assert.equal(ok.status, 200);
    const tooMany = await request('POST', bulkUrl, { body: { items: items(51) } });
    assert.equal(tooMany.status, 400);
  });
});
