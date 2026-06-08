import { WebPlugin } from '@capacitor/core';
import type { LiveActivitiesPlugin } from './definitions';
export declare class LiveActivitiesWeb extends WebPlugin implements LiveActivitiesPlugin {
    echo(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
}
