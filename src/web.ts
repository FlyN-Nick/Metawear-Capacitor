import { WebPlugin } from '@capacitor/core';

import type { MetawearCapacitorPlugin } from './definitions';

export class MetawearCapacitorWeb
  extends WebPlugin
  implements MetawearCapacitorPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
