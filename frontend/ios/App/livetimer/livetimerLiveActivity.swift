import ActivityKit
import WidgetKit
import SwiftUI

struct livetimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: livetimerAttributes.self) { context in
            // String in Zahl umwandeln (Fallback auf 0, falls der String keine Zahl ist)
            let numericValue = Double(context.state.value) ?? 0.0
            
            // MARK: - Lock Screen / Banner UI
            VStack(spacing: 12) {
                HStack(alignment: .center) {
                    // Links: Großer Wert
                    Text(context.state.value)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Rechts: Bild (System-Icon oder eigenes Asset)
                    Image(systemName: "stopwatch.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 45, height: 45)
                        .foregroundColor(.orange)
                }
                
                // Progress Bar (100% = 60)
                // min(..., 60) verhindert, dass der Balken über 100% hinausgeht
                ProgressView(value: min(numericValue, 60), total: 60)
                    .progressViewStyle(.linear)
                    .tint(.orange)
                    .background(Color.white.opacity(0.1))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center) // Macht den Balken etwas dicker
                    .clipShape(Capsule())
            }
            .padding(20)
            .activityBackgroundTint(Color(red: 44/255, green: 62/255, blue: 80/255))
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            let numericValue = Double(context.state.value) ?? 0.0
            
            return DynamicIsland {
                // MARK: - Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.value)
                        .font(.system(size: 35, weight: .bold, design: .rounded))
                        .padding(.leading, 10)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: "stopwatch.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                        .foregroundColor(.orange)
                        .padding(.trailing, 10)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: min(numericValue, 60), total: 60)
                        .tint(.orange)
                        .padding(.horizontal)
                        .padding(.top, 5)
                }
                
            } compactLeading: {
                Text(context.state.value)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            } compactTrailing: {
                Image(systemName: "timer")
                    .imageScale(.small)
            } minimal: {
                Text(context.state.value)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.orange)
        }
    }
}
