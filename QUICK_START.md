# Quick Start Guide - Super Simple! 🚀

## What You Need to Do (In Order)

### 1. Install Flutter (The Easy Way)

Since you have Homebrew, this is super easy! Just copy and paste these commands one at a time in Terminal:

```bash
brew install --cask flutter
```

Wait for it to finish (might take a few minutes).

Then check if it worked:
```bash
flutter --version
```

If you see numbers, you're good! ✅

### 2. Install Xcode (For iPhone/iPad Testing)

1. Open the App Store
2. Search for "Xcode"
3. Click "Get" or "Install"
4. Wait... (this is BIG, might take 30+ minutes)
5. After it installs, open Xcode once from Applications
6. Let it install extra tools (click "Install" when asked)

### 3. Install Cursor Extensions

1. In Cursor, click the square icon on the left (or press Cmd+Shift+X)
2. Search for "Flutter" and install the one by "Dart Code"
3. Restart Cursor when it asks

### 4. Get Your App Ready

Open Terminal in Cursor (Terminal → New Terminal, or press Ctrl+`), then type:

```bash
cd /Users/minjeongkim/Documents/Dev/aac_keyboard/als_aac_keyboard
flutter pub get
```

This downloads all the code your app needs.

### 5. Check Everything Works

Type this in Terminal:
```bash
flutter doctor
```

This checks if everything is set up. It might show some yellow warnings - that's usually okay. Red X marks mean you need to fix something.

### 6. Run Your App!

1. Open the iPhone Simulator:
   ```bash
   open -a Simulator
   ```

2. Run your app:
   ```bash
   flutter run
   ```

Wait for it to build (first time takes a few minutes), then your app will appear! 🎉

---

## Need Help?

If something doesn't work:
- Run `flutter doctor` - it will tell you what's wrong
- Make sure you're in the right folder (the one with `pubspec.yaml`)
- Try closing and reopening Terminal

