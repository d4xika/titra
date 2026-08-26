import Foundation
import Capacitor
import ActivityKit

public class LiveActivities {

    public init() {}

    // MARK: - Start

    public func start(_ call: CAPPluginCall) {
        guard #available(iOS 16.1, *) else {
            call.reject("Live Activities require iOS 16.1+")
            return
        }

        guard let startedAtMilliseconds = call.getDouble("startedAt") else {
            call.reject("startedAt is required")
            return
        }

        let startedAt = Date(timeIntervalSince1970: startedAtMilliseconds / 1000)
        let endsAt = call.getDouble("endsAt").map {
            Date(timeIntervalSince1970: $0 / 1000)
        }
        let countsDown = call.getBool("countsDown") ?? false

        Task {
            do {
                let attributes = livetimerAttributes(name: "Live Timer")
                let state = livetimerAttributes.ContentState(
                    startedAt: startedAt,
                    endsAt: endsAt,
                    countsDown: countsDown
                )

                if #available(iOS 16.2, *) {
                    let activity = try Activity.request(
                        attributes: attributes,
                        content: .init(state: state, staleDate: nil)
                    )
                    call.resolve([
                        "activityId": activity.id
                    ])
                }
            } catch {
                call.reject("Failed to start Live Activity: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Update

    public func update(_ call: CAPPluginCall) {
        guard #available(iOS 16.2, *) else {
            call.reject("Live Activities require iOS 16.1+")
            return
        }

        let activityId = call.getString("activityId") ?? ""
        guard let startedAtMilliseconds = call.getDouble("startedAt") else {
            call.reject("startedAt is required")
            return
        }

        let startedAt = Date(timeIntervalSince1970: startedAtMilliseconds / 1000)
        let endsAt = call.getDouble("endsAt").map {
            Date(timeIntervalSince1970: $0 / 1000)
        }
        let countsDown = call.getBool("countsDown") ?? false

        Task {
            let activities = Activity<livetimerAttributes>.activities
            guard let activity = activities.first(where: { $0.id == activityId }) else {
                call.reject("Activity not found")
                return
            }

            let newState = livetimerAttributes.ContentState(
                startedAt: startedAt,
                endsAt: endsAt,
                countsDown: countsDown
            )

            await activity.update(.init(state: newState, staleDate: nil))
            call.resolve()
        }
    }

    // MARK: - End

    public func end(_ call: CAPPluginCall) {
        guard #available(iOS 16.1, *) else {
            call.reject("Live Activities require iOS 16.1+")
            return
        }

        let activityId = call.getString("activityId") ?? ""

        Task {
            let activities = Activity<livetimerAttributes>.activities
            guard let activity = activities.first(where: { $0.id == activityId }) else {
                call.reject("Activity not found")
                return
            }

            await activity.end(dismissalPolicy: .immediate)
            call.resolve()
        }
    }
}
