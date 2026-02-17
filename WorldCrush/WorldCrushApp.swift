/*
 BEGINNER NOTES (AUTO):
 - Archivo: WorldCrush/WorldCrushApp.swift
 - Rol principal: Soporte general de arquitectura: tipos, configuracion o pegamento entre modulos.
 - Flujo simplificado: Entrada: contexto de modulo. | Proceso: ejecutar responsabilidad local del archivo. | Salida: tipo/valor usado por otras piezas.
 - Tipos clave en este archivo: WorldCrushApp
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

//
//  WorldCrushApp.swift
//  WorldCrush
//
//  Created by Pedro Carrasco lopez brea on 8/2/26.
//

import SwiftUI
import UIKit
import DesignSystem

private final class OrientationLockAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        .portrait
    }
}

@main
struct WorldCrushApp: App {
    @UIApplicationDelegateAdaptor(OrientationLockAppDelegate.self) private var appDelegate
    @StateObject private var container = AppContainer.live

    var body: some Scene {
        WindowGroup {
            ThemeProvider {
                ContentView(container: container)
            }
        }
    }
}
