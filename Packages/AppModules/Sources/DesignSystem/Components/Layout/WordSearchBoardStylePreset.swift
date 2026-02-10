import SwiftUI

public enum WordSearchBoardStylePreset {
    public static let challengePreview = SharedWordSearchBoardPalette(
        boardBackground: ColorTokens.surfacePaperGrid,
        boardCellBackground: ColorTokens.surfacePaperMuted,
        boardGridStroke: ColorTokens.boardGridStroke,
        boardOuterStroke: ColorTokens.boardOuterStroke,
        letterColor: ColorTokens.textPrimary,
        selectionFill: ColorTokens.selectionFill,
        foundOutlineStroke: ColorTokens.boardGridStroke,
        feedbackCorrect: ColorTokens.feedbackCorrect,
        feedbackIncorrect: ColorTokens.feedbackIncorrect,
        anchorBorder: ColorTokens.accentPrimary
    )

    public static let gameBoard = SharedWordSearchBoardPalette(
        boardBackground: ColorTokens.surfacePaperGrid,
        boardCellBackground: ColorTokens.surfacePaperMuted,
        boardGridStroke: ColorTokens.boardGridStroke,
        boardOuterStroke: ColorTokens.boardOuterStroke,
        letterColor: ColorTokens.textPrimary,
        selectionFill: ColorTokens.accentCoral.opacity(0.15),
        foundOutlineStroke: ColorTokens.boardGridStroke,
        feedbackCorrect: ColorTokens.feedbackCorrect,
        feedbackIncorrect: ColorTokens.feedbackIncorrect,
        anchorBorder: ColorTokens.textSecondary.opacity(0.75)
    )

    public static func widget(isDark: Bool) -> SharedWordSearchBoardPalette {
        SharedWordSearchBoardPalette(
            boardBackground: ColorTokens.surfacePaperGrid,
            boardCellBackground: ColorTokens.surfacePaperMuted,
            boardGridStroke: ColorTokens.boardGridStroke,
            boardOuterStroke: ColorTokens.boardOuterStroke,
            letterColor: ColorTokens.textPrimary,
            selectionFill: ColorTokens.selectionFill,
            foundOutlineStroke: ColorTokens.textPrimary.opacity(0.82),
            feedbackCorrect: ColorTokens.feedbackCorrect,
            feedbackIncorrect: ColorTokens.feedbackIncorrect,
            anchorBorder: isDark
                ? ColorTokens.textPrimary.opacity(0.62)
                : ColorTokens.textSecondary.opacity(0.75)
        )
    }
}
