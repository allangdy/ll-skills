const test = require('node:test');
const assert = require('node:assert');

const { toCents } = require('../src/money.js');

test('amounts are compared in integer cents', () => {
  assert.strictEqual(toCents('10.05'), 1005);
});
