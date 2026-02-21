# Xcode Cloud Setup

This project is prepared for Xcode Cloud with custom workflow scripts in `ci_scripts/`.

## Included scripts
- `ci_scripts/ci_post_clone.sh`
  - Installs SwiftLint with Homebrew when available.
  - Can be disabled with `CI_INSTALL_SWIFTLINT=0`.
- `ci_scripts/ci_pre_xcodebuild.sh`
  - Runs `Scripts/lint.sh` before the build/test action.
  - Can be disabled with `CI_RUN_SWIFTLINT=0`.
  - By default lint is non-blocking in CI (`CI_FAIL_ON_LINT=0`).
  - Set `CI_FAIL_ON_LINT=1` to fail the workflow when lint violations are found.
  - Set `CI_REQUIRE_SWIFTLINT=1` to fail the workflow if SwiftLint is missing.

## Create the workflow in Xcode Cloud
1. Open `WorldCrush.xcodeproj` in Xcode.
2. Go to `Product` -> `Xcode Cloud` -> `Create Workflow...`.
3. Select app target `WorldCrush` and scheme `WorldCrush`.
4. Choose your branch trigger (recommended: pull requests for CI validation).
5. Select an action that includes tests.
6. Confirm signing and distribution settings in the workflow editor.
7. Save and start the workflow.

## Recommended workflow environment variables
- `CI_INSTALL_SWIFTLINT=1`
- `CI_RUN_SWIFTLINT=1`
- `CI_FAIL_ON_LINT=0` (set to `1` to enforce lint errors as failures)
- `CI_REQUIRE_SWIFTLINT=0` (set to `1` if you want missing SwiftLint to fail)

## Notes
- Shared schemes already exist in `WorldCrush.xcodeproj/xcshareddata/xcschemes/`.
- Xcode Cloud discovers scripts automatically when they live in `ci_scripts/` at repo root.
