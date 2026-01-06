import ActivityKit
import WidgetKit
import SwiftUI

struct livetimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var value: String
    }
    var name: String
}
