import ActivityKit
import WidgetKit
import SwiftUI

struct livetimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startedAt: Date
        var endsAt: Date?
        var countsDown: Bool
    }
    var name: String
}
