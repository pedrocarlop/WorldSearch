/*
 BEGINNER NOTES (AUTO):
 - Archivo: Packages/AppModules/Sources/FeatureDailyPuzzle/Presentation/Views/DailyPuzzleLoupeView.swift
 - Rol principal: Define interfaz SwiftUI: estructura visual, estados observados y eventos del usuario.
 - Flujo simplificado: Entrada: estado observable + eventos de usuario. | Proceso: SwiftUI recalcula body y compone vistas. | Salida: interfaz actualizada en pantalla.
 - Tipos clave en este archivo: DailyPuzzleLoupeView
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
import Core
import DesignSystem

struct DailyPuzzleLoupeView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    @Binding var state: LoupeState
    let configuration: LoupeConfiguration
    let selectedText: String

    init(
        state: Binding<LoupeState>,
        configuration: LoupeConfiguration,
        selectedText: String
    ) {
        _state = state
        self.configuration = configuration
        self.selectedText = selectedText
    }

    var body: some View {
        if state.isVisible {
            let bubbleShape = Capsule(style: .continuous)
            let bubbleText = selectedText.isEmpty ? " " : selectedText

            Text(bubbleText)
                .font(TypographyTokens.bodyStrong)
                .foregroundStyle(ColorTokens.inkPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .padding(.horizontal, SpacingTokens.md)
                .padding(.vertical, SpacingTokens.xs)
                .background(
                    bubbleShape.fill(
                        reduceTransparency
                        ? AnyShapeStyle(ColorTokens.surfaceTertiary)
                        : AnyShapeStyle(.thinMaterial)
                    )
                )
                .overlay(
                    bubbleShape.stroke(
                        colorSchemeContrast == .increased
                        ? ColorTokens.textPrimary.opacity(0.45)
                        : ColorTokens.textSecondary.opacity(0.24),
                        lineWidth: configuration.borderWidth
                    )
                )
                .shadow(
                    color: colorSchemeContrast == .increased
                    ? ColorTokens.textPrimary.opacity(0.16)
                    : ColorTokens.textPrimary.opacity(0.1),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .position(state.loupeScreenPosition)
                .allowsHitTesting(false)
                .transition(.opacity)
                .accessibilityHidden(true)
        }
    }
}
