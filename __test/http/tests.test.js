const env = require('./http-client.env.json')['local'];
const { baseUrl, client, auth_b64 } = env;

const headers = {
  Authorization: `Basic ${auth_b64}`,
  Accept: 'application/json',
  'Content-Type': 'application/json',
};

async function request(method, path, { body, customHeaders } = {}) {
  const url = `${baseUrl}${path}?sap-client=${client}`;
  let requestBody;
  if (body == null) {
    requestBody = undefined;
  } else if (typeof body === 'string') {
    requestBody = body;
  } else {
    requestBody = JSON.stringify(body);
  }
  const res = await fetch(url, {
    method,
    headers: customHeaders || headers,
    body: requestBody,
  });
  let responseBody;
  const ct = res.headers.get('content-type') || '';
  if (ct.includes('application/json')) {
    responseBody = await res.json();
  } else {
    responseBody = await res.text();
  }
  return { status: res.status, body: responseBody };
}

describe('GET /ruleSet', () => {
  test('MySample returns 200 with header and items', async () => {
    const { status, body } = await request('GET', '/ruleSet/MySample');
    expect(status).toBe(200);
    expect(body.HEADER.RULESETID).toBe('MySample');
    expect(body.ITEMS.length).toBeGreaterThan(0);
  });

  test('Unknown RuleSet returns 400', async () => {
    const { status } = await request('GET', '/ruleSet/UNKNOWN_RULESET');
    expect(status).toBe(400);
  });

  test('Without auth returns 401 or 403', async () => {
    const { status } = await request('GET', '/ruleSet/MySample', {
      customHeaders: { Accept: 'application/json' },
    });
    expect([401, 403]).toContain(status);
  });
});

describe('POST /ruleSetExecution', () => {
  test('MySample extracts MaterialNo from barcode', async () => {
    const { status, body } = await request('POST', '/ruleSetExecution/MySample', {
      body: { string_to_be_interpreted: '<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>' },
    });
    expect(status).toBe(200);
    const mat = body.find(r => r.TARGETFIELD === 'MaterialNo');
    expect(mat.INTERPRETATIONRESULT).toBe('MyMaterialNumber');
  });

  test('MySample with no matching tag returns no match', async () => {
    const { status, body } = await request('POST', '/ruleSetExecution/MySample', {
      body: { string_to_be_interpreted: '<Start><NO_KNOWN_TAG>SomeValue<End>' },
    });
    expect(status).toBe(200);
    expect(body.every(r => r.INTERPRETATIONRESULT === 'no match')).toBe(true);
  });

  test('Unknown RuleSet returns 400', async () => {
    const { status } = await request('POST', '/ruleSetExecution/UNKNOWN_RULESET', {
      body: { string_to_be_interpreted: '<Start><A7X>MyMaterialNumber<End>' },
    });
    expect(status).toBe(400);
  });

  test('MySample with context returns 200 and extracts MaterialNo', async () => {
    const { status, body } = await request('POST', '/ruleSetExecution/MySample', {
      body: {
        string_to_be_interpreted: '<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>',
        context: [
          { ctx_key: 'plant', value: '1000' },
          { ctx_key: 'source', value: 'scanner_01' },
        ],
      },
    });
    expect(status).toBe(200);
    const mat = body.find(r => r.TARGETFIELD === 'MaterialNo');
    expect(mat.INTERPRETATIONRESULT).toBe('MyMaterialNumber');
  });

  test('MySample with empty context array returns 200', async () => {
    const { status } = await request('POST', '/ruleSetExecution/MySample', {
      body: { string_to_be_interpreted: '<Start><A7X>MyMaterialNumber<End>', context: [] },
    });
    expect(status).toBe(200);
  });

  test('Empty string_to_be_interpreted returns 400', async () => {
    const { status } = await request('POST', '/ruleSetExecution/MySample', {
      body: { string_to_be_interpreted: '' },
    });
    expect(status).toBe(400);
  });

  test('Missing string_to_be_interpreted returns 400', async () => {
    const { status } = await request('POST', '/ruleSetExecution/MySample', {
      body: {},
    });
    expect(status).toBe(400);
  });

  test('Wrong Content-Type returns 400', async () => {
    const { status } = await request('POST', '/ruleSetExecution/MySample', {
      body: 'some plain text',
      customHeaders: { ...headers, 'Content-Type': 'text/plain' },
    });
    expect(status).toBe(400);
  });

  test('PUT method returns 405', async () => {
    const { status } = await request('PUT', '/ruleSetExecution/MySample', {
      body: { string_to_be_interpreted: 'test' },
    });
    expect(status).toBe(405);
  });
});
