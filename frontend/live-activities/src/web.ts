/* eslint-disable */
import { WebPlugin } from '@capacitor/core';

import type { LiveActivitiesPlugin } from './definitions';

export class LiveActivitiesWeb extends WebPlugin implements LiveActivitiesPlugin {
  async start(): Promise<{ activityId: string }> {
    throw this.unavailable('Live Activities are only available on iOS.');
  }

  async update(): Promise<void> {
    throw this.unavailable('Live Activities are only available on iOS.');
  }

  async end(): Promise<void> {
    throw this.unavailable('Live Activities are only available on iOS.');
  }
}
