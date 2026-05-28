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

    it('Empty string returns 400', async () => {
      const { status } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: { string_to_be_interpreted: '' },
      });
      assert.equal(status, 400);
    });

    it('Missing string_to_be_interpreted returns 400', async () => {
      const { status } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: {},
      });
      assert.equal(status, 400);
    });

    it('Unknown RuleSet returns 400', async () => {
      const { status } = await request('POST', '/ruleSetExecution/UNKNOWN_RULESET_XYZ', {
        body: { string_to_be_interpreted: 'test' },
      });
      assert.equal(status, 400);
    });

    it('Wrong Content-Type returns 400', async () => {
      const { status } = await request('POST', `/ruleSetExecution/${ruleSetId}`, {
        body: 'some plain text',
        contentType: 'text/plain',
      });
      assert.equal(status, 400);
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

    it('Unknown RuleSet returns 400', async () => {
      const { status } = await request('GET', '/ruleSet/UNKNOWN_RULESET_XYZ');
      assert.equal(status, 400);
    });

  });
}

export function methodTests(describe, it, assert, request, ruleSetId) {
  describe('Unsupported methods', () => {

    it('PUT returns 405', async () => {
      const { status } = await request('PUT', `/ruleSetExecution/${ruleSetId}`, {
        body: { string_to_be_interpreted: 'test' },
      });
      assert.equal(status, 405);
    });

  });
}
