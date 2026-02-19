# WordCrush

**A calm daily word search. One puzzle per day.**

WordCrush is a focused iOS word-search experience designed around intention, not addiction.
You get one puzzle each day. Complete it, build your streak, and come back tomorrow.

**Read in other languages:** [Espanol](README.es.md)

## App Store Release Summary
This repository contains the production app, widget extension, shared modules, and CI setup used for App Store release workflows.

## Core Player Features
- One daily puzzle challenge with completion tracking.
- Progress stats including completed challenges and streaks.
- Hint modes: show the target word or its definition.
- Home Screen widget support for one-tap launch.
- Appearance and feedback options (theme, celebration intensity, haptics, sound).
- App language support: English and Spanish.
- No login required.

## Designed for Intentional Play
WordCrush is built around restraint:
- No endless gameplay loops.
- No artificial pressure.
- No manipulative reward systems.

## Technical Overview
- Built with Swift and SwiftUI.
- App target: `WorldCrush`
- Widget target: `WordSearchWidgetExtension`
- Shared package modules: `Packages/AppModules` (`Core`, `DesignSystem`, `FeatureDailyPuzzle`, `FeatureHistory`, `FeatureSettings`)
- Xcode Cloud scripts: `ci_scripts/`
- GitHub Actions workflows: `.github/workflows/`

## Run Locally
1. Open `WorldCrush.xcodeproj` in Xcode.
2. Select the `WorldCrush` scheme.
3. Build and run on an iPhone simulator or device.

## Documentation
- [Architecture](Docs/Architecture.md)
- [Architecture Map](Docs/ArchitectureMap.md)
- [Xcode Cloud Setup](Docs/XcodeCloud.md)
- [GitHub to TestFlight Automation](Docs/TestFlightAutomation.md)
- [Optimization Audit](Docs/OptimizationAudit.md)

## Support
For questions, feedback, or support: `pedro.design.engineer@gmail.com`

## Privacy
WordCrush:
- Does not require account creation.
- Does not collect personal data for sale.
- Stores gameplay progress locally on your device.

## License
All rights reserved (c) 2026 Pedro Carrasco
