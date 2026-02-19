/*
 BEGINNER NOTES (AUTO):
 - Archivo: WorldCrush/Home/HomeScreenLayout.swift
 - Rol principal: Soporte general de arquitectura: tipos, configuracion o pegamento entre modulos.
 - Flujo simplificado: Entrada: contexto de modulo. | Proceso: ejecutar responsabilidad local del archivo. | Salida: tipo/valor usado por otras piezas.
 - Tipos clave en este archivo: HomeScreenLayout,HomeToolbarContent
 - Funciones clave en este archivo: (sin funciones directas visibles; revisa propiedades/constantes/extensiones)
 - Como leerlo sin experiencia:
   1) Busca primero los tipos clave para entender 'quien vive aqui'.
   2) Revisa propiedades (let/var): indican que datos mantiene cada tipo.
   3) Sigue funciones publicas: son la puerta de entrada para otras capas.
   4) Luego mira funciones privadas: implementan detalles internos paso a paso.
   5) Si ves guard/if/switch, son decisiones que controlan el flujo.
 - Recordatorio rapido de sintaxis:
   - let = valor fijo; var = valor que puede cambiar.
   - guard = valida pronto; si falla, sale de la funcion.
   - return = devuelve un resultado y cierra esa funcion.
*/

import SwiftUI
import DesignSystem
import FeatureDailyPuzzle
import FeatureHistory

struct HomeScreenLayout: View {
    private enum LayoutConstants {
        static let compactHeightThreshold: CGFloat = 700
        static let veryCompactHeightThreshold: CGFloat = 620

        static let dayCarouselHeight: CGFloat = 106
        static let compactDayCarouselHeight: CGFloat = 92
        static let minimumCarouselHeight: CGFloat = 260
        static let compactMinimumCarouselHeight: CGFloat = 220
        static let veryCompactMinimumCarouselHeight: CGFloat = 190
        static let maximumCarouselHeight: CGFloat = 424
    }

    let challengeCards: [DailyPuzzleChallengeCardState]
    let dayCarouselOffsets: [Int]
    @Binding var selectedOffset: Int?
    let todayOffset: Int
    let unlockedOffsets: Set<Int>
    let launchingCardOffset: Int?
    let showsWidgetOnboardingBanner: Bool
    let onCardTap: (Int) -> Void
    let onWidgetOnboardingTap: () -> Void
    let onWidgetOnboardingDismiss: () -> Void
    let dateForOffset: (Int) -> Date
    let progressForOffset: (Int) -> Double
    let hoursUntilAvailable: (Int) -> Int?

    var body: some View {
        GeometryReader { geometry in
            let isCompactHeight = geometry.size.height < LayoutConstants.compactHeightThreshold
            let isVeryCompactHeight = geometry.size.height < LayoutConstants.veryCompactHeightThreshold

            let verticalInset = min(
                SpacingTokens.xxxl,
                max(
                    isVeryCompactHeight ? SpacingTokens.xs : SpacingTokens.md,
                    geometry.size.height * (isVeryCompactHeight ? 0.04 : 0.065)
                )
            )
            let interSectionSpacing = min(
                SpacingTokens.xxxl,
                max(
                    SpacingTokens.xs,
                    geometry.size.height * (isVeryCompactHeight ? 0.03 : 0.045)
                )
            )
            let bannerToCardSpacing = interSectionSpacing
            let cardToCalendarSpacing = SpacingTokens.xxl
            let dayCarouselHeight = isCompactHeight
                ? LayoutConstants.compactDayCarouselHeight
                : LayoutConstants.dayCarouselHeight
            let minimumCarouselHeight = isVeryCompactHeight
                ? LayoutConstants.veryCompactMinimumCarouselHeight
                : (isCompactHeight ? LayoutConstants.compactMinimumCarouselHeight : LayoutConstants.minimumCarouselHeight)
            let bannerHeight = showsWidgetOnboardingBanner ? WidgetOnboardingBannerView.preferredHeight : .zero
            let cardWidth = min(geometry.size.width * 0.80, 450)
            let availableCarouselHeightWithDayCarousel = geometry.size.height
                - (verticalInset * 2)
                - bannerHeight
                - dayCarouselHeight
                - (showsWidgetOnboardingBanner ? bannerToCardSpacing : .zero)
                - cardToCalendarSpacing
            let showsDayCarousel = availableCarouselHeightWithDayCarousel >= minimumCarouselHeight
            let occupiedHeight = (verticalInset * 2)
                + bannerHeight
                + (showsWidgetOnboardingBanner ? bannerToCardSpacing : .zero)
                + (showsDayCarousel ? (dayCarouselHeight + cardToCalendarSpacing) : .zero)
            let availableCarouselHeight = max(geometry.size.height - occupiedHeight, 0)
            let preferredCarouselHeight = min(
                max(availableCarouselHeight, minimumCarouselHeight),
                LayoutConstants.maximumCarouselHeight
            )
            // Never request more height than what is really available to avoid clipping on compact screens.
            let carouselHeight = min(preferredCarouselHeight, availableCarouselHeight)
            let focusedOffset = selectedOffset ?? todayOffset
            let carouselIndex = Binding<Int?>(
                get: {
                    guard !challengeCards.isEmpty else { return nil }
                    let targetOffset = selectedOffset ?? todayOffset

                    if let current = challengeCards.firstIndex(where: { $0.offset == targetOffset }) {
                        return current
                    }
                    if let today = challengeCards.firstIndex(where: { $0.offset == todayOffset }) {
                        return today
                    }
                    return challengeCards.startIndex
                },
                set: { index in
                    guard
                        let index,
                        challengeCards.indices.contains(index)
                    else { return }

                    let offset = challengeCards[index].offset
                    guard selectedOffset != offset else { return }
                    selectedOffset = offset
                }
            )

            VStack(spacing: .zero) {
                if showsWidgetOnboardingBanner {
                    WidgetOnboardingBannerView(
                        onTap: onWidgetOnboardingTap,
                        onDismiss: onWidgetOnboardingDismiss
                    )
                    .frame(height: bannerHeight)
                    .padding(.horizontal, SpacingTokens.sm)
                    .padding(.bottom, bannerToCardSpacing)
                }

                CarouselView(
                    items: challengeCards,
                    currentIndex: carouselIndex,
                    itemWidth: cardWidth,
                    itemSpacing: SpacingTokens.sm + 2
                ) { card in
                    DailyPuzzleChallengeCardView(
                        date: card.date,
                        puzzleNumber: card.puzzleNumber,
                        grid: card.grid,
                        words: card.words,
                        foundWords: card.progress.foundWords,
                        solvedPositions: card.progress.solvedPositions,
                        completionSeconds: card.completionSeconds,
                        isLocked: card.isLocked,
                        isMissed: card.isMissed,
                        hoursUntilAvailable: card.hoursUntilAvailable,
                        isLaunching: launchingCardOffset == card.offset,
                        isFocused: card.offset == focusedOffset
                    ) {
                        onCardTap(card.offset)
                    }
                    .frame(height: carouselHeight)
                    .scaleEffect(launchingCardOffset == card.offset ? 1.10 : 1)
                    .opacity(launchingCardOffset == nil || launchingCardOffset == card.offset ? 1 : 0.45)
                    .zIndex(launchingCardOffset == card.offset ? 5 : 0)
                }
                .frame(height: carouselHeight)

                if showsDayCarousel {
                    DailyPuzzleDayCarouselView(
                        offsets: dayCarouselOffsets,
                        selectedOffset: $selectedOffset,
                        todayOffset: todayOffset,
                        unlockedOffsets: unlockedOffsets,
                        dateForOffset: dateForOffset,
                        progressForOffset: progressForOffset,
                        hoursUntilAvailable: hoursUntilAvailable,
                        onDayTap: { _ in }
                    )
                    .frame(height: dayCarouselHeight)
                    .padding(.horizontal, SpacingTokens.sm)
                    .padding(.top, cardToCalendarSpacing)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.vertical, verticalInset)
        }
    }
}

private struct WidgetOnboardingBannerView: View {
    static let preferredHeight: CGFloat = 112

    let onTap: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: SpacingTokens.sm) {
            Button(action: onTap) {
                HStack(alignment: .top, spacing: SpacingTokens.sm) {
                    Image(systemName: "widget.small")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(ColorTokens.accentCoralStrong)
                        .padding(.top, SpacingTokens.xxs)

                    VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                        Text(AppStrings.widgetOnboardingBannerTitle)
                            .font(TypographyTokens.bodyStrong)
                            .foregroundStyle(ColorTokens.textPrimary)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Text(AppStrings.widgetOnboardingBannerDescription)
                            .font(TypographyTokens.footnote)
                            .foregroundStyle(ColorTokens.textSecondary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AppStrings.widgetOnboardingBannerAccessibilityLabel)
            .accessibilityHint(AppStrings.widgetOnboardingBannerAccessibilityHint)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(ColorTokens.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(
                        ColorTokens.surfacePrimary.opacity(0.72),
                        in: Circle()
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AppStrings.widgetOnboardingBannerCloseAccessibility)
        }
        .padding(.vertical, SpacingTokens.sm)
        .padding(.leading, SpacingTokens.md)
        .padding(.trailing, SpacingTokens.sm)
        .background(
            ColorTokens.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: RadiusTokens.buttonRadius, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: RadiusTokens.buttonRadius, style: .continuous)
                .dsInnerStroke(ColorTokens.borderDefault.opacity(0.55), lineWidth: 1)
        )
    }
}

struct HomeToolbarContent: ToolbarContent {
    let completedCount: Int
    let streakCount: Int
    let onCompletedTap: () -> Void
    let onStreakTap: () -> Void
    let onSettingsTap: () -> Void
    let toolbarActionTransitionNamespace: Namespace.ID?

    private var styledHomeTitle: Text {
        Text(verbatim: "Word")
            .font(TypographyTokens.screenTitle.weight(.regular))
            .foregroundColor(ColorTokens.textTertiary)
        + Text(verbatim: "Crush")
            .font(TypographyTokens.screenTitle.weight(.semibold))
            .foregroundColor(ColorTokens.textPrimary)
    }

    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 0) {
                    styledHomeTitle
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel(AppStrings.homeTitle)
            }
        } else {
            ToolbarItem(placement: .topBarLeading) {
                styledHomeTitle
                    .lineLimit(1)
                    .minimumScaleFactor(0.45)
                    .allowsTightening(true)
                    .truncationMode(.tail)
                    .accessibilityLabel(AppStrings.homeTitle)
            }
        }

        if #available(iOS 26.0, *), let toolbarActionTransitionNamespace {
            ToolbarItemGroup(placement: .topBarTrailing) {
                homeActionsContent
            }
            .matchedTransitionSource(id: "puzzle-nav-actions", in: toolbarActionTransitionNamespace)
        } else {
            ToolbarItemGroup(placement: .topBarTrailing) {
                homeActionsContent
            }
        }
    }

    @ViewBuilder
    private var homeActionsContent: some View {
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
            iconGradient: ThemeGradients.brushWarm,
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
