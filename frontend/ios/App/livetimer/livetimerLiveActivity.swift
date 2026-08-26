import ActivityKit
import CoreText
import WidgetKit
import SwiftUI

private enum LiveActivityFont {
    private static let isRegistered: Bool = {
        guard let fontURL = Bundle.main.url(
            forResource: "ChakraPetch-Bold",
            withExtension: "ttf"
        ) else {
            return false
        }

        return CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
    }()

    static func chakraPetch(size: CGFloat) -> Font {
        _ = isRegistered
        return .custom("ChakraPetch-Bold", size: size)
    }
}

private struct WorkingKittyImage: View {
    let name: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Image(name)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
    }
}

private struct LiveTimerText: View {
    let state: livetimerAttributes.ContentState
    let fontSize: CGFloat

    var body: some View {
        Group {
            if state.countsDown, let endsAt = state.endsAt {
                Text(timerInterval: state.startedAt...endsAt, countsDown: true)
            } else {
                Text(timerInterval: state.startedAt...Date.distantFuture, countsDown: false)
            }
        }
        .font(LiveActivityFont.chakraPetch(size: fontSize))
        .monospacedDigit()
    }
}

struct livetimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: livetimerAttributes.self) { context in
            // MARK: - Lock Screen / Banner UI
            HStack(alignment: .center) {
                LiveTimerText(state: context.state, fontSize: 48)
                    .foregroundColor(.white)

                Spacer()

                WorkingKittyImage(
                    name: "workingKittyLockScreen",
                    width: 120,
                    height: 75
                )
            }
            .padding(20)
            .activityBackgroundTint(Color(red: 44/255, green: 62/255, blue: 80/255))
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: - Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    LiveTimerText(state: context.state, fontSize: 35)
                        .padding(.leading, 10)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    WorkingKittyImage(
                        name: "workingKittyExpanded",
                        width: 90,
                        height: 56
                    )
                        .padding(.trailing, 10)
                }
                
            } compactLeading: {
                LiveTimerText(state: context.state, fontSize: 16)
                    .foregroundColor(.white)
            } compactTrailing: {
                WorkingKittyImage(
                    name: "workingKittyCompact",
                    width: 40,
                    height: 25
                )
            } minimal: {
                LiveTimerText(state: context.state, fontSize: 12)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.white)
        }
    }
}
