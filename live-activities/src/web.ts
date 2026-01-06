/* eslint-disable */
import { WebPlugin } from '@capacitor/core';

import type { LiveActivitiesPlugin } from './definitions';

export class LiveActivitiesWeb extends WebPlugin implements LiveActivitiesPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
