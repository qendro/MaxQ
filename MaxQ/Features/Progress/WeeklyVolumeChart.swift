//
//  WeeklyVolumeChart.swift
//  MaxQ
//
//  Created by Kiro on 8/9/25.
//

import SwiftUI
import Charts

struct WeekPoint: Identifiable { 
    let id = UUID()
    let start: Date
    let volume: Double 
    
    var weekLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: start)
    }
}

struct WeeklyVolumeChart: View {
    let points: [WeekPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing().sm) {
            Text("Weekly Volume")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.primaryText)
            
            if points.isEmpty {
                Text("No workout data yet")
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(points) { point in
                    BarMark(
                        x: .value("Week", point.start),
                        y: .value("Volume", point.volume)
                    )
                    .foregroundStyle(DesignSystem.Colors.accent.gradient)
                    .cornerRadius(DesignSystem.Corners.sm)
                }
                .chartYAxisLabel("Volume (lbs)")
                .chartXAxis {
                    AxisMarks(values: .stride(by: .weekOfYear)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(WeekPoint(start: date, volume: 0).weekLabel)
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine()
                        AxisTick()
                    }
                }
                .frame(height: 180)
            }
        }
        .cardStyle()
    }
}

// MARK: - Volume Calculation Utilities
extension Array where Element == WorkoutSessionModel {
    /// Calculates weekly volume points from workout sessions
    func weeklyVolumePoints() -> [WeekPoint] {
        let calendar = Calendar.current
        
        // Group sessions by week
        let grouped = Dictionary(grouping: self) { session in
            calendar.dateInterval(of: .weekOfYear, for: session.date)?.start ?? session.date
        }
        
        return grouped.compactMap { (weekStart, sessions) in
            let totalVolume = sessions.reduce(0.0) { total, session in
                total + session.entries.reduce(0.0) { entryTotal, entry in
                    entryTotal + (entry.weight * Double(entry.reps))
                }
            }
            return WeekPoint(start: weekStart, volume: totalVolume)
        }.sorted { $0.start < $1.start }
    }
}
