/* eslint-disable */
import { WebPlugin } from '@capacitor/core';
export class LiveActivitiesWeb extends WebPlugin {
    async echo(options) {
        console.log('ECHO', options);
        return options;
    }
}
//# sourceMappingURL=web.js.map