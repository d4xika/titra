import Foundation
import Capacitor

@objc(LiveActivitiesPlugin)
public class LiveActivitiesPlugin: CAPPlugin, CAPBridgedPlugin {

    public let identifier = "LiveActivitiesPlugin"
    public let jsName = "LiveActivities"

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "start", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "update", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "end", returnType: CAPPluginReturnPromise),
    ]

    private let implementation = LiveActivities()

    @objc func start(_ call: CAPPluginCall) {
        implementation.start(call)
    }

    @objc func update(_ call: CAPPluginCall) {
        implementation.update(call)
    }

    @objc func end(_ call: CAPPluginCall) {
        implementation.end(call)
    }
}
