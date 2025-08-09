//
//  EnhancedProgressView.swift
//  MaxQ
//
//  Enhanced progress screen with animated charts and engaging metrics
//

import SwiftUI
import Charts

struct EnhancedProgressView: View {
    @StateObject private var viewModel = ProgressViewModel()
    @State private var selectedWeek: WeekPoint?
    @State private var showingAllPRs = false
    @State private var animateCharts = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DS.Spacing.xxl) {
                    // Hero metrics
                    heroMetricsSection
                    
                    // Weekly volume chart
                    weeklyVolumeSection
                    
                    // Personal Records
                    personalRecordsSection
                    
                    // Activity streak
                    activityStreakSection
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, DS.Spacing.xxxl)
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshData()
            }
            .onAppear {
                viewModel.refresh()
                withAnimation(DS.Animation.gentle.delay(0.3)) {
                    animateCharts = true
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var heroMetricsSection: some View {
        MQCard(elevation: .medium) {
            VStack(spacing: DS.Spacing.lg) {
                HStack {
                    Text("This Week")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.text)
                    
                    Spacer()
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(DS.brand)
                }
                
                HStack(spacing: DS.Spacing.xxxl) {
                    MetricCard(
                        value: Int(viewModel.weeklyVolume),
                        unit: "lbs",
                        label: "Total Volume",
                        icon: "scalemass.fill",
                        color: DS.brand
                    )
                    
                    MetricCard(
                        value: viewModel.streakDays,
                        unit: "days",
                        label: "Streak",
                        icon: "flame.fill",
                        color: .orange
                    )
                }
            }
        }
        .scaleEffect(animateCharts ? 1.0 : 0.9)
        .opacity(animateCharts ? 1.0 : 0.0)
        .animation(DS.Animation.bouncy, value: animateCharts)
    }
    
    private var weeklyVolumeSection: some View {
        MQCard(elevation: .medium) {
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                HStack {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text("Weekly Volume")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.text)
                        
                        Text("Last 12 weeks")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.textSecondary)
                    }
                    
                    Spacer()
                    
                    if let selectedWeek = selectedWeek {
                        VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                            Text("\(Int(selectedWeek.volume)) lbs")
                                .font(DS.Typography.numbersLarge)
                                .foregroundColor(DS.brand)
                            
                            Text(selectedWeek.start, style: .date)
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.textSecondary)
                        }
                    }
                }
                
                // Chart placeholder - would use WeeklyVolumeChart here
                chartPlaceholder
                    .scaleEffect(animateCharts ? 1.0 : 0.8)
                    .opacity(animateCharts ? 1.0 : 0.0)
                    .animation(DS.Animation.gentle.delay(0.5), value: animateCharts)
            }
        }
    }
    
    private var personalRecordsSection: some View {
        MQCard(elevation: .medium) {
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                HStack {
                    Text("Personal Records")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.text)
                    
                    Spacer()
                    
                    if viewModel.topPRs.count > 3 {
                        Button("See All") {
                            showingAllPRs = true
                            Haptics.select()
                        }
                        .font(DS.Typography.captionMedium)
                        .foregroundColor(DS.brand)
                    }
                }
                
                if viewModel.topPRs.isEmpty {
                    Text("Complete your first workout to see PRs here")
                        .font(DS.Typography.body)
                        .foregroundColor(DS.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, DS.Spacing.xl)
                } else {
                    LazyVStack(spacing: DS.Spacing.md) {
                        ForEach(Array(viewModel.topPRs.prefix(3).enumerated()), id: \.offset) { index, pr in
                            PRRow(
                                exercise: pr.exercise,
                                weight: Int(pr.weight),
                                reps: Int(pr.reps),
                                rank: index + 1
                            )
                            .scaleEffect(animateCharts ? 1.0 : 0.8)
                            .opacity(animateCharts ? 1.0 : 0.0)
                            .animation(
                                DS.Animation.bouncy.delay(Double(index) * 0.1 + 0.7),
                                value: animateCharts
                            )
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAllPRs) {
            allPRsSheet
        }
    }
    
    private var activityStreakSection: some View {
        MQCard(elevation: .low) {
            HStack(spacing: DS.Spacing.lg) {
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundColor(.orange)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(.orange.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("Activity Streak")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.text)
                    
                    Text("Keep it up! Consistency builds strength.")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.textSecondary)
                }
                
                Spacer()
                
                Text("\(viewModel.streakDays)")
                    .font(DS.Typography.numbersLarge)
                    .foregroundColor(.orange)
            }
        }
        .scaleEffect(animateCharts ? 1.0 : 0.9)
        .opacity(animateCharts ? 1.0 : 0.0)
        .animation(DS.Animation.bouncy.delay(1.0), value: animateCharts)
    }
    
    private var chartPlaceholder: some View {
        RoundedRectangle(cornerRadius: DS.Corner.md, style: .continuous)
            .fill(DS.brand.opacity(0.1))
            .frame(height: 120)
            .overlay(
                VStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundColor(DS.brand)
                    
                    Text("Chart coming soon")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.textSecondary)
                }
            )
    }
    
    private var allPRsSheet: some View {
        NavigationStack {
            List {
                ForEach(Array(viewModel.topPRs.enumerated()), id: \.offset) { index, pr in
                    PRRow(
                        exercise: pr.exercise,
                        weight: Int(pr.weight),
                        reps: Int(pr.reps),
                        rank: index + 1
                    )
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .navigationTitle("All Personal Records")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingAllPRs = false
                    }
                    .foregroundColor(DS.brand)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Actions
    
    private func refreshData() async {
        viewModel.refresh()
        
        // Restart animations
        animateCharts = false
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        withAnimation(DS.Animation.gentle) {
            animateCharts = true
        }
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let value: Int
    let unit: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: DS.Spacing.xs) {
                HStack(alignment: .lastTextBaseline, spacing: DS.Spacing.xs) {
                    Text("\(value)")
                        .font(DS.Typography.numbersLarge)
                        .foregroundColor(DS.text)
                    
                    Text(unit)
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.textSecondary)
                }
                
                Text(label)
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PRRow: View {
    let exercise: String
    let weight: Int
    let reps: Int
    let rank: Int
    
    private var medalColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return DS.textSecondary
        }
    }
    
    private var medalIcon: String {
        switch rank {
        case 1: return "medal.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return "\(rank).circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: medalIcon)
                .font(.title3)
                .foregroundColor(medalColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(exercise)
                    .font(DS.Typography.bodyMedium)
                    .foregroundColor(DS.text)
                
                Text("Personal best")
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                Text("\(weight) lbs")
                    .font(DS.Typography.numbers)
                    .foregroundColor(DS.text)
                
                Text("\(reps) reps")
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.textSecondary)
            }
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

#Preview {
    EnhancedProgressView()
}
