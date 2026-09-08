import { reconcile } from '../src/a';

test('reconcile dedupes a replayed batch', () => {
  expect(reconcile(['e1', 'e1', 'e2'])).toEqual(['e1', 'e2']);
});
