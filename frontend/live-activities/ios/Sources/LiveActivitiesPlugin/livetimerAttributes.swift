import ActivityKit
import Foundation

struct livetimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var startedAt: Date
        var endsAt: Date?
        var countsDown: Bool
    }

    var name: String
}
