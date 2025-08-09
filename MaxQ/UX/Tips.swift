//
//  Tips.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import TipKit
import SwiftUI

struct EditInlineTip: Tip {
    var title: Text { Text("Tap weight or reps to edit") }
    var message: Text? { Text("No popups — edit inline and keep flow.") }
    var image: Image? { Image(systemName: "hand.tap") }
}

struct ReorderDaysTip: Tip {
    var title: Text { Text("Reorder workout days") }
    var message: Text? { Text("Tap Edit to drag and reorder your workout days.") }
    var image: Image? { Image(systemName: "arrow.up.arrow.down") }
}

struct ExportDataTip: Tip {
    var title: Text { Text("Export your data") }
    var message: Text? { Text("Keep your workout history safe with CSV export.") }
    var image: Image? { Image(systemName: "square.and.arrow.up") }
}
