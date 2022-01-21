import { registerPlugin } from '@capacitor/core';

import type { MetawearCapacitorPlugin } from './definitions';

const MetawearCapacitor = registerPlugin<MetawearCapacitorPlugin>(
  'MetawearCapacitor',
  {
    web: () => import('./web').then(m => new m.MetawearCapacitorWeb()),
  },
);

export * from './definitions';
export { MetawearCapacitor };
