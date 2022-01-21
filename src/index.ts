import { registerPlugin } from '@capacitor/core';

import type { metwearPlugin } from './definitions';

const metwear = registerPlugin<metwearPlugin>('metwear', {
  web: () => import('./web').then(m => new m.metwearWeb()),
});

export * from './definitions';
export { metwear };
