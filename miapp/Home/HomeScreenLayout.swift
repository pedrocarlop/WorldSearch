import SwiftUI
import DesignSystem
import FeatureDailyPuzzle
import FeatureHistory

struct HomeScreenLayout: View {
    let challengeCards: [DailyPuzzleChallengeCardState]
    let carouselOffsets: [Int]
    @Binding var selectedOffset: Int?
    let todayOffset: Int
    let unlockedOffsets: Set<Int>
    let launchingCardOffset: Int?
    let onCardTap: (Int) -> Void
    let dateForOffset: (Int) -> Date
    let progressForOffset: (Int) -> Double
    let hoursUntilAvailable: (Int) -> Int?

    var body: some View {
        GeometryReader { geometry in
            let verticalInset = SpacingTokens.xxxl
            let interSectionSpacing = SpacingTokens.xxxl
            let dayCarouselHeight: CGFloat = 106
            let cardWidth = min(geometry.size.width * 0.80, 450)
            let sidePadding = max((geometry.size.width - cardWidth) / 2, SpacingTokens.xs)
            let availableCardHeight = geometry.size.height - dayCarouselHeight - interSectionSpacing - (verticalInset * 2)
            let cardHeight = min(max(availableCardHeight, 260), 620)
            let activeOffset = selectedOffset ?? todayOffset
            let cardSelection = Binding<Int?>(
                get: { carouselOffsets.contains(activeOffset) ? activeOffset : nil },
                set: { selectedOffset = $0 }
            )

            VStack(spacing: interSectionSpacing) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: SpacingTokens.sm + 2) {
                        ForEach(challengeCards) { card in
                            DailyPuzzleChallengeCardView(
                                date: card.date,
                                puzzleNumber: card.puzzleNumber,
                                grid: card.grid,
                                words: card.words,
                                foundWords: card.progress.foundWords,
                                solvedPositions: card.progress.solvedPositions,
                                isLocked: card.isLocked,
                                hoursUntilAvailable: card.hoursUntilAvailable,
                                isLaunching: launchingCardOffset == card.offset
                            ) {
                                onCardTap(card.offset)
                            }
                            .frame(width: cardWidth, height: cardHeight)
                            .scaleEffect(launchingCardOffset == card.offset ? 1.10 : 1)
                            .opacity(launchingCardOffset == nil || launchingCardOffset == card.offset ? 1 : 0.45)
                            .zIndex(launchingCardOffset == card.offset ? 5 : 0)
                            .id(card.offset)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, sidePadding)
                }
                .frame(height: cardHeight)
                .scrollClipDisabled(true)
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                .scrollPosition(id: cardSelection, anchor: .center)

                DailyPuzzleDayCarouselView(
                    offsets: carouselOffsets,
                    selectedOffset: $selectedOffset,
                    todayOffset: todayOffset,
                    unlockedOffsets: unlockedOffsets,
                    dateForOffset: dateForOffset,
                    progressForOffset: progressForOffset,
                    hoursUntilAvailable: hoursUntilAvailable
                )
                .frame(height: dayCarouselHeight)
                .padding(.horizontal, SpacingTokens.sm)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.vertical, verticalInset)
        }
    }
}

struct HomeToolbarContent: ToolbarContent {
    let completedCount: Int
    let streakCount: Int
    let onCompletedTap: () -> Void
    let onStreakTap: () -> Void
    let onSettingsTap: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(AppStrings.homeTitle)
                .font(TypographyTokens.screenTitle)
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            HistoryNavCounterView(
                value: completedCount,
                systemImage: "checkmark.seal.fill",
                iconGradient: ThemeGradients.brushWarm,
                accessibilityLabel: AppStrings.completedCounterAccessibility(completedCount),
                accessibilityHint: AppStrings.completedCounterHint
            ) {
                onCompletedTap()
            }

            HistoryNavCounterView(
                value: streakCount,
                systemImage: "flame.fill",
                iconGradient: ThemeGradients.brushWarmStrong,
                accessibilityLabel: AppStrings.streakCounterAccessibility(streakCount),
                accessibilityHint: AppStrings.streakCounterHint
            ) {
                onStreakTap()
            }

            Button {
                onSettingsTap()
            } label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(ColorTokens.textPrimary)
            }
            .accessibilityLabel(AppStrings.openSettingsAccessibility)
        }
    }
}
