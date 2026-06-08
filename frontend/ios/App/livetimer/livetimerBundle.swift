//
//  livetimerBundle.swift
//  livetimer
//
//  Created by Katja Daxberger on 06.01.26.
//

import WidgetKit
import SwiftUI

@main
struct livetimerBundle: WidgetBundle {
    var body: some Widget {
        livetimer()
        livetimerControl()
        livetimerLiveActivity()
    }
}
