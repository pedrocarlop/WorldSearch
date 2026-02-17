# WorldCrush

> Retos diarios de sopa de letras para iPhone y widget de pantalla de inicio, construido con SwiftUI y una arquitectura limpia modular.

**Leer en otros idiomas:** [English](README.md) | [Français](README.fr.md) | [Português](README.pt.md)

## Resumen para lanzamiento en App Store
WorldCrush es un juego de sopa de letras para iOS centrado en un reto diario con acceso rapido desde un widget.

Este repositorio incluye la app de produccion, la extension de widget, los modulos compartidos y la configuracion de CI para flujos de lanzamiento en App Store.

## Funcionalidades principales
- Un reto diario con seguimiento de progreso.
- Estadisticas de progreso con retos completados y racha.
- Modos de pista: mostrar la palabra objetivo o su definicion.
- Soporte de widget en pantalla de inicio para jugar en un toque.
- Opciones de apariencia y feedback (tema, intensidad de celebracion, haptics, sonido).
- Idiomas de la app: ingles, espanol, frances y portugues.

## Resumen tecnico
- Target de app: `WorldCrush`
- Target de widget: `WordSearchWidgetExtension`
- Modulos compartidos en paquete local: `Packages/AppModules` (`Core`, `DesignSystem`, `FeatureDailyPuzzle`, `FeatureHistory`, `FeatureSettings`)
- Scripts de Xcode Cloud: `ci_scripts/`

## Ejecutar en local
1. Abre `WorldCrush.xcodeproj` en Xcode.
2. Selecciona el esquema `WorldCrush`.
3. Compila y ejecuta en un simulador de iPhone o dispositivo.

## Documentacion
- [Arquitectura](Docs/Architecture.md)
- [Mapa de arquitectura](Docs/ArchitectureMap.md)
- [Configuracion de Xcode Cloud](Docs/XcodeCloud.md)
- [Auditoria de optimizacion](Docs/OptimizationAudit.md)
