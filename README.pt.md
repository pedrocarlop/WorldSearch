# WorldCrush

> Desafios diarios de caca-palavras para iPhone e widget de tela inicial, desenvolvido com SwiftUI e arquitetura limpa modular.

**Ler em outros idiomas:** [English](README.md) | [Español](README.es.md) | [Français](README.fr.md)

## Resumo para lancamento na App Store
WorldCrush e um jogo iOS de caca-palavras focado em um desafio diario, com acesso rapido pelo widget da tela inicial.

Este repositorio inclui o app de producao, a extensao de widget, os modulos compartilhados e a configuracao de CI usada nos fluxos de lancamento da App Store.

## Funcionalidades principais
- Um desafio diario com acompanhamento de progresso.
- Estatisticas de progresso com desafios concluidos e sequencia.
- Modos de dica: mostrar a palavra alvo ou sua definicao.
- Suporte a widget na tela inicial para abrir com um toque.
- Opcoes de aparencia e feedback (tema, intensidade de celebracao, haptics, som).
- Idiomas do app: ingles, espanhol, frances e portugues.

## Visao tecnica
- Target do app: `WorldCrush`
- Target do widget: `WordSearchWidgetExtension`
- Modulos compartilhados no pacote local: `Packages/AppModules` (`Core`, `DesignSystem`, `FeatureDailyPuzzle`, `FeatureHistory`, `FeatureSettings`)
- Scripts do Xcode Cloud: `ci_scripts/`

## Executar localmente
1. Abra `WorldCrush.xcodeproj` no Xcode.
2. Selecione o scheme `WorldCrush`.
3. Compile e execute em simulador de iPhone ou dispositivo.

## Documentacao
- [Arquitetura](Docs/Architecture.md)
- [Mapa de arquitetura](Docs/ArchitectureMap.md)
- [Configuracao do Xcode Cloud](Docs/XcodeCloud.md)
- [Auditoria de otimizacao](Docs/OptimizationAudit.md)
