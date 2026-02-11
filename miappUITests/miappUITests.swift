/*
 BEGINNER NOTES (AUTO):
 - Archivo: miappUITests/miappUITests.swift
 - Rol principal: Valida comportamiento. Ejecuta escenarios y comprueba resultados esperados.
 - Flujo simplificado: Entrada: datos de prueba y condiciones iniciales. | Proceso: ejecutar metodo/flujo bajo test. | Salida: aserciones que deben cumplirse.
 - Tipos clave en este archivo: miappUITests
 - Funciones clave en este archivo: setUpWithError,tearDownWithError testExample,testLaunchPerformance
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
//  miappUITests.swift
//  miappUITests
//
//  Created by Pedro Carrasco lopez brea on 8/2/26.
//

import XCTest
import CoreGraphics

final class miappUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testPuzzleFirstExperienceFlow() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uitesting-reset-first-experience")
        app.launch()

        let playButton = app.buttons["dailyPuzzle.playButton"].firstMatch
        XCTAssertTrue(playButton.waitForExistence(timeout: 8))
        playButton.tap()

        let step1Toast = app.otherElements["dailyPuzzle.firstExperience.toast.step1"]
        XCTAssertTrue(step1Toast.waitForExistence(timeout: 6))

        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        let step2Toast = app.otherElements["dailyPuzzle.firstExperience.toast.step2"]
        XCTAssertTrue(step2Toast.waitForExistence(timeout: 3))

        let objectivesHighlight = app.otherElements["dailyPuzzle.firstExperience.objectivesHighlight"]
        XCTAssertTrue(objectivesHighlight.waitForExistence(timeout: 2))

        let nextButton = app.buttons["dailyPuzzle.firstExperience.nextButton"].firstMatch
        XCTAssertTrue(nextButton.waitForExistence(timeout: 2))
        nextButton.tap()

        let step3Toast = app.otherElements["dailyPuzzle.firstExperience.toast.step3"]
        XCTAssertTrue(step3Toast.waitForExistence(timeout: 3))

        let skipButton = app.buttons["dailyPuzzle.firstExperience.skipAllButton"].firstMatch
        XCTAssertTrue(skipButton.waitForExistence(timeout: 2))
        skipButton.tap()
        XCTAssertFalse(step3Toast.waitForExistence(timeout: 1))

        let closeButton = app.buttons["dailyPuzzle.closeButton"].firstMatch
        XCTAssertTrue(closeButton.waitForExistence(timeout: 3))
        closeButton.tap()

        XCTAssertTrue(playButton.waitForExistence(timeout: 6))
        playButton.tap()

        XCTAssertFalse(step1Toast.waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
