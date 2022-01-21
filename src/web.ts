import { WebPlugin } from '@capacitor/core';

import type { metwearPlugin } from './definitions';

export class metwearWeb extends WebPlugin implements metwearPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
