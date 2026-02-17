/*
 BEGINNER NOTES (AUTO):
 - Archivo: WorldCrushTests/WorldCrushTests.swift
 - Rol principal: Valida comportamiento. Ejecuta escenarios y comprueba resultados esperados.
 - Flujo simplificado: Entrada: datos de prueba y condiciones iniciales. | Proceso: ejecutar metodo/flujo bajo test. | Salida: aserciones que deben cumplirse.
 - Tipos clave en este archivo: WorldCrushTests
 - Funciones clave en este archivo: testLoupeStateVisibility,testLoupeStateClampsPosition testLoupeStateSmoothingLerpsTowardTarget
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

//
//  WorldCrushTests.swift
//  WorldCrushTests
//
//  Created by Pedro Carrasco lopez brea on 8/2/26.
//

import CoreGraphics
import XCTest
import Core
@testable import WorldCrush

final class WorldCrushTests: XCTestCase {
    func testLoupeStateVisibility() {
        var state = LoupeState(configuration: .default)
        let bounds = CGRect(x: 0, y: 0, width: 200, height: 200)

        XCTAssertFalse(state.isVisible)
        state.update(
            fingerLocation: CGPoint(x: 40, y: 60),
            in: bounds,
            configuration: .default
        )
        XCTAssertTrue(state.isVisible)

        state.hide()
        XCTAssertFalse(state.isVisible)
    }

    func testLoupeStateClampsPosition() {
        var config = LoupeConfiguration.default
        config.size = CGSize(width: 100, height: 100)
        config.offset = CGSize(width: 0, height: -70)
        config.edgePadding = 8

        var state = LoupeState(configuration: config)
        let bounds = CGRect(x: 0, y: 0, width: 200, height: 200)

        state.update(
            fingerLocation: CGPoint(x: 5, y: 5),
            in: bounds,
            configuration: config
        )

        let insetX = config.size.width * 0.5 + config.edgePadding
        let insetY = config.size.height * 0.5 + config.edgePadding
        XCTAssertGreaterThanOrEqual(state.loupeScreenPosition.x, insetX - 0.001)
        XCTAssertGreaterThanOrEqual(state.loupeScreenPosition.y, insetY - 0.001)
    }

    func testLoupeStateSmoothingLerpsTowardTarget() {
        var config = LoupeConfiguration.default
        config.smoothing = 0.2

        var state = LoupeState(configuration: config)
        let bounds = CGRect(x: 0, y: 0, width: 240, height: 240)

        state.update(
            fingerLocation: CGPoint(x: 60, y: 60),
            in: bounds,
            configuration: config
        )

        let initial = state.loupeScreenPosition

        state.update(
            fingerLocation: CGPoint(x: 180, y: 180),
            in: bounds,
            configuration: config
        )

        let updated = state.loupeScreenPosition
        XCTAssertNotEqual(initial, updated)
        XCTAssertLessThan(updated.x, 180 + config.offset.width)
        XCTAssertLessThan(updated.y, 180 + config.offset.height)
    }

    func testWidgetOnboardingBannerShowsOnFirstOpen() {
        let defaults = makeTestDefaults()
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        XCTAssertTrue(WidgetOnboardingBannerState.shouldShow(defaults: defaults, now: now))
        XCTAssertEqual(defaults.object(forKey: WidgetOnboardingBannerState.firstOpenDateKey) as? Date, now)
    }

    func testWidgetOnboardingBannerDismissHidesPermanently() {
        let defaults = makeTestDefaults()
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        XCTAssertTrue(WidgetOnboardingBannerState.shouldShow(defaults: defaults, now: now))
        WidgetOnboardingBannerState.dismiss(defaults: defaults)

        let afterDismiss = now.addingTimeInterval(60)
        XCTAssertFalse(WidgetOnboardingBannerState.shouldShow(defaults: defaults, now: afterDismiss))
    }

    func testWidgetOnboardingBannerAutoHidesAfterSevenDays() {
        let defaults = makeTestDefaults()
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let hideDate = Calendar.current.date(byAdding: .day, value: WidgetOnboardingBannerState.autoHideDays, to: now)!

        XCTAssertTrue(WidgetOnboardingBannerState.shouldShow(defaults: defaults, now: now))
        XCTAssertTrue(WidgetOnboardingBannerState.shouldShow(defaults: defaults, now: hideDate.addingTimeInterval(-1)))
        XCTAssertFalse(WidgetOnboardingBannerState.shouldShow(defaults: defaults, now: hideDate))
    }

    private func makeTestDefaults() -> UserDefaults {
        let suiteName = "WorldCrushTests.WidgetOnboarding.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
