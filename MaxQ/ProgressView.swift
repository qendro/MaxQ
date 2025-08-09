import SwiftUI

struct ProgressViewScreen: View {
    @StateObject private var viewModel = ProgressViewModel()
    @State private var animateMetrics = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DS.Spacing.xxl) {
                    // Hero metrics
                    heroMetricsSection
                    
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
                    animateMetrics = true
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
        .scaleEffect(animateMetrics ? 1.0 : 0.9)
        .opacity(animateMetrics ? 1.0 : 0.0)
        .animation(DS.Animation.bouncy, value: animateMetrics)
    }
    
    private var personalRecordsSection: some View {
        MQCard(elevation: .medium) {
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                HStack {
                    Text("Personal Records")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.text)
                    
                    Spacer()
                }
                
                if viewModel.topPRs.isEmpty {
                    VStack(spacing: DS.Spacing.md) {
                        Image(systemName: "trophy")
                            .font(.system(size: 32))
                            .foregroundColor(DS.textTertiary)
                        
                        Text("Complete your first workout to see PRs here")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DS.Spacing.xl)
                } else {
                    LazyVStack(spacing: DS.Spacing.md) {
                        ForEach(Array(viewModel.topPRs.prefix(5).enumerated()), id: \.offset) { index, pr in
                            PRRow(
                                exercise: pr.exercise,
                                weight: Int(pr.weight),
                                reps: Int(pr.reps),
                                rank: index + 1
                            )
                            .scaleEffect(animateMetrics ? 1.0 : 0.8)
                            .opacity(animateMetrics ? 1.0 : 0.0)
                            .animation(
                                DS.Animation.bouncy.delay(Double(index) * 0.1 + 0.5),
                                value: animateMetrics
                            )
                        }
                    }
                }
            }
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
        .scaleEffect(animateMetrics ? 1.0 : 0.9)
        .opacity(animateMetrics ? 1.0 : 0.0)
        .animation(DS.Animation.bouncy.delay(0.8), value: animateMetrics)
    }
    
    // MARK: - Actions
    
    private func refreshData() async {
        viewModel.refresh()
        
        // Restart animations
        animateMetrics = false
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        withAnimation(DS.Animation.gentle) {
            animateMetrics = true
        }
    }
}




