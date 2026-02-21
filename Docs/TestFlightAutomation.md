# GitHub Push -> TestFlight Automation

This repository includes a GitHub Actions workflow that uploads a new TestFlight build whenever you push to `main`:

- Workflow file: `.github/workflows/testflight.yml`
- Trigger: `push` on `main` (plus manual `workflow_dispatch`)
- Build number: set automatically using UTC timestamp format (`yyyyMMddHHmmss`) to prevent duplicate build-number upload errors.

## Local post-push automation (configured in this clone)

This clone is configured to upload to TestFlight automatically after each successful push to `origin/main` using local Xcode credentials:

- Hook path: `.githooks/post-push`
- Upload script: `Scripts/upload_testflight.sh`
- Local git config: `core.hooksPath=.githooks`

This path does not require GitHub secrets, but it only runs when pushes are made from this machine.

The local upload script also assigns the same UTC timestamp build number format by default.
You can override it for one run if needed:

```bash
BUILD_NUMBER_OVERRIDE=20260220113000 Scripts/upload_testflight.sh
```

To skip one upload on demand:

```bash
SKIP_TESTFLIGHT_UPLOAD=1 git push origin main
```

## One-time GitHub setup

Add these repository secrets:

1. `APPSTORE_CERTIFICATES_FILE_BASE64`
2. `APPSTORE_CERTIFICATES_PASSWORD`
3. `APPSTORE_API_PRIVATE_KEY`

Add these repository variables:

1. `APPSTORE_API_KEY_ID`
2. `APPSTORE_ISSUER_ID`

## Secret value details

### `APPSTORE_CERTIFICATES_FILE_BASE64`
Base64 of your Apple Distribution certificate exported as `.p12`.

Example command:

```bash
base64 -i Certificates.p12 | pbcopy
```

### `APPSTORE_CERTIFICATES_PASSWORD`
The password used when exporting the `.p12` file.

### `APPSTORE_API_PRIVATE_KEY`
The full contents of your App Store Connect API key (`.p8`), including header/footer lines.

### `APPSTORE_API_KEY_ID`
The App Store Connect API key ID.

### `APPSTORE_ISSUER_ID`
The App Store Connect issuer ID.

## Fix for non-fast-forward push errors

If push fails with `[rejected] (non-fast-forward)`, sync first and push again:

```bash
git fetch origin
git pull --rebase origin main
git push origin main
```

If conflicts appear during rebase, resolve them, run `git rebase --continue`, then push again.
