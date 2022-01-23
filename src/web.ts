import { WebPlugin } from '@capacitor/core';

import type { MetawearCapacitorPlugin } from './definitions';

export class MetawearCapacitorWeb
  extends WebPlugin
  implements MetawearCapacitorPlugin {
  async connect(options: null): Promise<null> {
    throw new Error('Method not implemented.');
  }
  async disconnect(options: null): Promise<null> {
    throw new Error('Method not implemented.');
  }
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
