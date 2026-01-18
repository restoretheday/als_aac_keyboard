# Web Deployment Strategy for GitHub Pages

## Overview
Deploy the Flutter app as a web application accessible via GitHub Pages, allowing users to access it by entering the GitHub repository URL.

## Current Status
- ✅ Flutter web support is enabled
- ✅ App uses Material Design 3
- ✅ Storage switched to `shared_preferences` (web-compatible)
- ✅ PWA support added (manifest.json + service worker)
- ✅ GitHub Actions workflow created for automated deployment
- ⚠️ TTS service needs web compatibility check (deferred)

## Deployment Options

### Option 1: GitHub Pages (Static Hosting)
**How it works:**
- Build Flutter web app: `flutter build web`
- Deploy `build/web` folder to GitHub Pages
- Users access via: `https://username.github.io/repo-name/`

**Pros:**
- Free hosting
- Simple deployment
- Works with custom domains
- HTTPS by default
- No backend required for static content

**Cons:**
- Static files only (no server-side code)
- Must rebuild and push for updates
- Limited to GitHub's terms

**Implementation Steps:**
1. Build web app: `flutter build web --release`
2. Copy `build/web` contents to `docs/` folder (or `gh-pages` branch)
3. Enable GitHub Pages in repo settings
4. Set source to `docs/` folder or `gh-pages` branch
5. App available at `https://username.github.io/repo-name/`

### Option 2: GitHub Actions (Automated Deployment)
**How it works:**
- GitHub Action automatically builds and deploys on push
- No manual build/deploy steps needed

**Pros:**
- Automated deployment
- Always up-to-date
- CI/CD pipeline

**Cons:**
- Requires GitHub Actions setup
- Slightly more complex initial setup

**Implementation:**
Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to GitHub Pages
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter build web --release
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

### Option 3: Custom Domain
**How it works:**
- Point custom domain to GitHub Pages
- Users access via custom URL (e.g., `https://aac-keyboard.example.com`)

**Pros:**
- Professional URL
- Branded experience
- Better for sharing

**Cons:**
- Requires domain purchase
- DNS configuration needed

## Web Compatibility Considerations

### 1. TTS (Text-to-Speech)
**Current:** Uses `flutter_tts` package
**Web Support:** 
- `flutter_tts` supports web via Web Speech API
- May need browser permissions
- Works in Chrome, Edge, Safari (with limitations)

**Alternative:** Use Web Speech API directly for better web support

### 2. File Storage
**Status:** ✅ **COMPLETED** - Switched to `shared_preferences` for web compatibility
- Automatically uses localStorage on web
- Works on mobile too
- Implementation: `lib/data/storage/local_storage.dart` now uses `shared_preferences`

### 3. Assets
**Current:** Uses `rootBundle.loadString()` for precanned sentences
**Web Support:** ✅ Works fine, assets are bundled in web build

### 4. Responsive Design
**Current:** Already handles landscape/portrait
**Web:** Should work, but may need adjustments for desktop browsers

## Recommended Approach

1. **Switch to `shared_preferences`** for storage (web-compatible)
2. **Test TTS on web** - verify `flutter_tts` works or use Web Speech API
3. **Build and deploy** using GitHub Actions for automation
4. **Add PWA support** (optional) - make it installable as web app

## PWA (Progressive Web App) Enhancement

Make the app installable on devices:
- Add `manifest.json`
- Add service worker for offline support
- Users can "Add to Home Screen" on mobile/desktop

**Benefits:**
- App-like experience
- Offline capability (with service worker)
- Can be "installed" on devices

## Implementation Status

1. ✅ **COMPLETED** - Fixed storage to use `shared_preferences` (web-compatible)
2. ✅ **COMPLETED** - Set up GitHub Actions for auto-deployment (`.github/workflows/deploy.yml`)
3. ✅ **COMPLETED** - Added PWA support (manifest.json enhanced + service worker registration)
4. ⚠️ **DEFERRED** - Test TTS on web browsers (user requested to skip for now)
5. ⚠️ **PENDING** - Enable GitHub Pages in repository settings (manual step required)
6. ⚠️ **PENDING** - Test on various browsers/devices after deployment

## Setup Instructions

### 1. Enable GitHub Pages
1. Go to your GitHub repository settings
2. Navigate to "Pages" in the left sidebar
3. Under "Source", select "GitHub Actions"
4. Save the settings

### 2. Update Base Href (if needed)
If your repository name is NOT `aac_keyboard`, update the base-href in `.github/workflows/deploy.yml`:
- Change `--base-href "/aac_keyboard/"` to match your repo name
- Example: If repo is `my-keyboard`, use `--base-href "/my-keyboard/"`

### 3. Deploy
- Push to `main` or `master` branch - GitHub Actions will automatically build and deploy
- Or manually trigger the workflow from the Actions tab
- App will be available at: `https://[your-username].github.io/aac_keyboard/`

## Access Pattern

Users would access the app via:
- **GitHub Pages URL**: `https://username.github.io/aac_keyboard/`
- **Custom Domain** (if configured): `https://aac-keyboard.example.com`
- **Direct Link**: Share the GitHub Pages URL

No installation required - just open in browser!


