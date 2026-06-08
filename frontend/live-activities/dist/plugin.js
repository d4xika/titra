var capacitorLiveActivities = (function (exports, core) {
    'use strict';

    /* eslint-disable */
    const LiveActivities = core.registerPlugin('LiveActivities', {
        web: () => Promise.resolve().then(function () { return web; }).then((m) => new m.LiveActivitiesWeb()),
    });

    /* eslint-disable */
    class LiveActivitiesWeb extends core.WebPlugin {
        async echo(options) {
            console.log('ECHO', options);
            return options;
        }
    }

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        LiveActivitiesWeb: LiveActivitiesWeb
    });

    exports.LiveActivities = LiveActivities;

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
