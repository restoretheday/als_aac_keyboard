# ALS Binary Keyboard (Flutter)

Offline iPad productivity app with a 6-button binary keyboard, predictive typing in French, local storage, and iOS text-to-speech.

## Prereqs (Windows)
- Flutter SDK (stable)
- VS Code / Cursor
- iPad with AltStore (for local install) and a Lightning/USB-C cable

Quick check:
```powershell
flutter --version
```

## Project Commands (local)
```powershell
# From project root (D:\cursor\worskpaces\aac_keyboard)
flutter pub get
flutter test
```

---

## Build iOS via Codemagic (no Mac required)
You’ll use Codemagic’s cloud to produce a signed `.ipa`.

### 1) Push code to a Git provider
- Create a private repo on GitHub/GitLab/Bitbucket
- Commit and push this project (include `pubspec.yaml`, `lib/`, `test/`, `codemagic.yaml`)

### 2) Create Codemagic account
- Sign in at `https://codemagic.io`
- Connect your Git provider and select this repository

### 3) Configure iOS code signing
Two common options:
- Automatic code signing with App Store Connect API Key (recommended)
  - Requires Apple Developer Program account
  - In Codemagic app settings → Code signing → iOS code signing → Select Automatic
  - Add App Store Connect API key (Issuer ID, Key ID, Private key as secure file)
  - Codemagic will generate provisioning profiles and signing certs for you
- Manual code signing (upload your own .p12 and provisioning profile)

Notes:
- Set your iOS bundle identifier in `ios/Runner.xcodeproj` or via Codemagic UI variables as needed.
- You can keep the workflow simple with `flutter build ipa --release` in the YAML.

### 4) Start a build
- Codemagic will detect `codemagic.yaml`
- Run the `ios_release` workflow
- On success, download the `.ipa` artifact from Codemagic

---

## Install on iPad with AltStore (Windows)
1) Install AltServer for Windows
   - Download from `https://altstore.io` and install
   - Sign in with your Apple ID in AltServer (recommended to use an app-specific password)
2) Install AltStore on your iPad
   - Connect iPad to the PC via cable (or Wi‑Fi sync enabled)
   - In AltServer (system tray) → Install AltStore → choose your iPad
   - On iPad, trust the developer if prompted (Settings → General → VPN & Device Management)
3) Sideload your `.ipa`
   - Send the `.ipa` to Files app or open it via AltStore on iPad
   - In AltStore → My Apps → + (Add) → pick the `.ipa`
   - Wait for installation to finish

Renewal:
- Free Apple IDs require app re-signing every 7 days. Keep AltServer running on your PC periodically to refresh via AltStore.

---

## Scripts
From the project root:
```powershell
# Prepare environment and run tests
./scripts/setup_windows.ps1
./scripts/run_tests.ps1
```

---

## Troubleshooting
- If `flutter test` can’t find packages, run `flutter pub get` again
- If Codemagic fails on signing, verify Apple Developer account, bundle ID, and signing method
- If AltStore fails to install, reconnect the device and ensure AltServer is running and signed in
