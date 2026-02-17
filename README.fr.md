# WorldCrush

> Defis quotidiens de mots caches pour iPhone et widget d ecran d accueil, construits avec SwiftUI et une architecture propre modulaire.

**Lire dans d autres langues :** [English](README.md) | [Español](README.es.md) | [Português](README.pt.md)

## Resume pour la sortie App Store
WorldCrush est un jeu iOS de mots caches centre sur un defi quotidien, avec acces rapide depuis un widget d ecran d accueil.

Ce depot contient l application de production, l extension widget, les modules partages et la configuration CI utilises pour les workflows de sortie App Store.

## Fonctionnalites principales
- Un defi quotidien avec suivi de progression.
- Statistiques de progression avec defis termines et serie en cours.
- Modes d indice : afficher le mot cible ou sa definition.
- Support du widget d ecran d accueil pour lancer en un geste.
- Options d apparence et de feedback (theme, intensite des celebrations, haptics, son).
- Langues de l app : anglais, espagnol, francais et portugais.

## Vue technique
- Cible app : `WorldCrush`
- Cible widget : `WordSearchWidgetExtension`
- Modules partages du package local : `Packages/AppModules` (`Core`, `DesignSystem`, `FeatureDailyPuzzle`, `FeatureHistory`, `FeatureSettings`)
- Scripts Xcode Cloud : `ci_scripts/`

## Execution en local
1. Ouvrez `WorldCrush.xcodeproj` dans Xcode.
2. Selectionnez le schema `WorldCrush`.
3. Compilez et lancez sur simulateur iPhone ou appareil reel.

## Documentation
- [Architecture](Docs/Architecture.md)
- [Carte d architecture](Docs/ArchitectureMap.md)
- [Configuration Xcode Cloud](Docs/XcodeCloud.md)
- [Audit d optimisation](Docs/OptimizationAudit.md)
