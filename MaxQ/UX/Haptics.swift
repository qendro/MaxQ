//
//  Haptics.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import UIKit

enum Haptics {
    static func success() { 
        UINotificationFeedbackGenerator().notificationOccurred(.success) 
    }
    
    static func error() { 
        UINotificationFeedbackGenerator().notificationOccurred(.error) 
    }
    
    static func select() { 
        UISelectionFeedbackGenerator().selectionChanged() 
    }
    
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
