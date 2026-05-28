/**
 * Shared integration test scenarios for the ZASIS HTTP handler.
 *
 * These scenarios run against BOTH the ICF shim (localhost) and real SAP.
 * Authorization tests are NOT here — they live in sap-auth.test.mjs.
 *
 * Each exported function receives:
 *   - describe, it, assert: test framework primitives
 *   - request(method, path, {body?, contentType?}): HTTP helper returning {status, body}
 *   - ruleSetId: the RuleSet name to use (seeded in ICF / existing on SAP)
 */

export function postExecutionTests(describe, it, assert, request, ruleSetId) {
  describe('POST /ruleSetExecution', () => {

    it(`${ruleSetId} extracts MaterialNo from barcode`, async () => {
      const { status, body } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: { string_to_be_interpreted: '<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>' },
      });
      assert.equal(status, 200);
      const results = body.RESULTS || body.results;
      const mat = results.find(r => (r.TARGETFIELD || r.targetfield) === 'MaterialNo');
      assert.ok(mat, 'Expected MaterialNo result');
      assert.equal(mat.INTERPRETATIONRESULT || mat.interpretationresult, 'MyMaterialNumber');
    });

    it(`${ruleSetId} returns no match for unrecognized tags`, async () => {
      const { status, body } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: { string_to_be_interpreted: '<Start><UNKNOWN>Value<End>' },
      });
      assert.equal(status, 200);
      const results = body.RESULTS || body.results;
      assert.ok(
        results.every(r => (r.INTERPRETATIONRESULT || r.interpretationresult) === 'no match'),
        'All items should be no match',
      );
    });

    it('Context is returned in the output', async () => {
      const { status, body } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: {
          string_to_be_interpreted: '<Start><A7X>MyMaterialNumber<End>',
          context: [{ ctx_key: 'plant', value: '1000' }],
        },
      });
      assert.equal(status, 200);
      const context = body.CONTEXT || body.context;
      assert.ok(context, 'Expected context in response');
      assert.equal(context.length, 1);
      assert.equal(context[0].CTX_KEY || context[0].ctx_key, 'plant');
      assert.equal(context[0].VALUE || context[0].value, '1000');
    });

    it('Context with multiple entries round-trips', async () => {
      const { status, body } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: {
          string_to_be_interpreted: '<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>',
          context: [
            { ctx_key: 'plant', value: '1000' },
            { ctx_key: 'source', value: 'scanner_01' },
          ],
        },
      });
      assert.equal(status, 200);
      const results = body.RESULTS || body.results;
      const mat = results.find(r => (r.TARGETFIELD || r.targetfield) === 'MaterialNo');
      assert.ok(mat, 'Expected MaterialNo result');
      assert.equal(mat.INTERPRETATIONRESULT || mat.interpretationresult, 'MyMaterialNumber');
    });

    it('Empty context array returns 200', async () => {
      const { status } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: { string_to_be_interpreted: '<Start><A7X>MyMaterialNumber<End>', context: [] },
      });
      assert.equal(status, 200);
    });

    it('Empty string returns 400 with structured error', async () => {
      const { status, body } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: { string_to_be_interpreted: '' },
      });
      assert.equal(status, 400);
      assert.ok(body.ERROR || body.error, 'Expected error envelope');
      const error = body.ERROR || body.error;
      assert.ok((error.CODE || error.code), 'Expected error code');
      assert.ok((error.MESSAGE || error.message), 'Expected error message');
      assert.equal(error.STATUS || error.status, '400');
    });

    it('Missing string_to_be_interpreted returns 400 with structured error', async () => {
      const { status, body } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: {},
      });
      assert.equal(status, 400);
      assert.ok(body.ERROR || body.error, 'Expected error envelope');
      const error = body.ERROR || body.error;
      assert.equal(error.STATUS || error.status, '400');
    });

    it('Unknown RuleSet returns 400 with error code', async () => {
      const { status, body } = await request('POST', '/ruleSetExecution/UNKNOWN_RULESET_XYZ', {
        body: { string_to_be_interpreted: 'test' },
      });
      assert.equal(status, 400);
      assert.ok(body.ERROR || body.error, 'Expected error envelope');
      const error = body.ERROR || body.error;
      assert.ok((error.CODE || error.code).includes('ZASIS_MSGS'), 'Expected ZASIS_MSGS code');
      assert.equal(error.STATUS || error.status, '400');
    });

    it('Wrong Content-Type returns 400 with structured error', async () => {
      const { status, body } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: 'some plain text',
        contentType: 'text/plain',
      });
      assert.equal(status, 400);
      assert.ok(body.ERROR || body.error, 'Expected error envelope');
    });

  });
}

export function getTests(describe, it, assert, request, ruleSetId) {
  describe('GET /ruleSet', () => {

    it(`${ruleSetId} returns 200 with header and items`, async () => {
      const { status, body } = await request('GET', `/ruleSet/${ruleSetId}`);
      assert.equal(status, 200);
      const header = body.HEADER || body.header;
      const items = body.ITEMS || body.items;
      assert.ok(header, 'Expected header in response');
      assert.equal((header.RULESETID || header.rulesetid).trim(), ruleSetId);
      assert.ok(items.length >= 2, 'Expected at least 2 items');
    });

    it('Unknown RuleSet returns 400 with structured error', async () => {
      const { status, body } = await request('GET', '/ruleSet/UNKNOWN_RULESET_XYZ');
      assert.equal(status, 400);
      assert.ok(body.ERROR || body.error, 'Expected error envelope');
      const error = body.ERROR || body.error;
      assert.ok((error.CODE || error.code).includes('ZASIS_MSGS'), 'Expected ZASIS_MSGS code');
      assert.equal(error.STATUS || error.status, '400');
    });

  });
}

export function methodTests(describe, it, assert, request, ruleSetId) {
  describe('Unsupported methods', () => {

    it('PUT returns 405 with structured error', async () => {
      const { status, body } = await request('PUT', `/ruleSetExecution/${ruleSetId}`, {
        body: { string_to_be_interpreted: 'test' },
      });
      assert.equal(status, 405);
      assert.ok(body.ERROR || body.error, 'Expected error envelope');
      const error = body.ERROR || body.error;
      assert.ok((error.CODE || error.code).includes('ZASIS_MSGS/016'), 'Expected method_not_supported code');
      assert.equal(error.STATUS || error.status, '405');
    });

  });
}

/**
 * Helper: extract the error object from a response body, handling both
 * uppercase (transpiled /ui2/cl_json) and lowercase (real SAP) key casing.
 */
function getError(body) {
  const envelope = body.ERROR || body.error;
  if (!envelope) return null;
  return {
    code: envelope.CODE || envelope.code,
    message: envelope.MESSAGE || envelope.message,
    status: envelope.STATUS || envelope.status,
  };
}

export function errorFormatTests(describe, it, assert, request, ruleSetId) {
  describe('Error response format', () => {

    it('Empty string error has code ZASIS_MSGS/015 and descriptive message', async () => {
      const { status, body } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: { string_to_be_interpreted: '' },
      });
      assert.equal(status, 400);
      const error = getError(body);
      assert.ok(error, 'Expected error envelope');
      assert.equal(error.code, 'ZASIS_MSGS/015');
      assert.equal(error.status, '400');
      assert.ok(error.message.length > 0, 'Message must not be empty');
      assert.match(error.message, /empty/i);
    });

    it('Unknown RuleSet error has code ZASIS_MSGS/007 and includes RuleSet name', async () => {
      const { status, body } = await request('POST', '/ruleSetExecution/NO_SUCH_RS', {
        body: { string_to_be_interpreted: 'test' },
      });
      assert.equal(status, 400);
      const error = getError(body);
      assert.ok(error, 'Expected error envelope');
      assert.equal(error.code, 'ZASIS_MSGS/007');
      assert.equal(error.status, '400');
      assert.ok(error.message.includes('NO_SUCH_RS'), 'Message should include the RuleSet name');
    });

    it('Invalid route error has code ZASIS_MSGS/005', async () => {
      const { status, body } = await request('GET', '/invalidRoute');
      assert.equal(status, 400);
      const error = getError(body);
      assert.ok(error, 'Expected error envelope');
      assert.equal(error.code, 'ZASIS_MSGS/005');
      assert.equal(error.status, '400');
    });

    it('Wrong Content-Type error has code ZASIS_MSGS/006', async () => {
      const { status, body } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: 'not json',
        contentType: 'text/plain',
      });
      assert.equal(status, 400);
      const error = getError(body);
      assert.ok(error, 'Expected error envelope');
      assert.equal(error.code, 'ZASIS_MSGS/006');
      assert.equal(error.status, '400');
    });

    it('Method not supported error has code ZASIS_MSGS/016 and includes method name', async () => {
      const { status, body } = await request('DELETE', `/ruleSetExecution/${ruleSetId}`);
      assert.equal(status, 405);
      const error = getError(body);
      assert.ok(error, 'Expected error envelope');
      assert.equal(error.code, 'ZASIS_MSGS/016');
      assert.equal(error.status, '405');
      assert.ok(error.message.includes('DELETE'), 'Message should include the HTTP method');
    });

    it('GET unknown RuleSet error has code ZASIS_MSGS/007', async () => {
      const { status, body } = await request('GET', '/ruleSet/NO_SUCH_RS');
      assert.equal(status, 400);
      const error = getError(body);
      assert.ok(error, 'Expected error envelope');
      assert.equal(error.code, 'ZASIS_MSGS/007');
      assert.ok(error.message.includes('NO_SUCH_RS'), 'Message should include the RuleSet name');
    });

    it('Error response body is valid JSON (Content-Type allows parsing)', async () => {
      const { status, body } = await request('POST', '/ruleSetExecution/UNKNOWN_RS', {
        body: { string_to_be_interpreted: 'x' },
      });
      assert.equal(status, 400);
      // If body is an object (not a string), the response had application/json Content-Type
      assert.equal(typeof body, 'object', 'Error response must be parseable JSON (Content-Type: application/json)');
      const error = getError(body);
      assert.ok(error, 'Expected error envelope in parsed JSON');
    });

  });
}
