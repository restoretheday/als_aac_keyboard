# Setup Checklist ✅

## ✅ DONE (Already Finished!)
- [x] Flutter is installed and working
- [x] App dependencies are downloaded
- [x] Project is ready

## ⏳ TODO (What You Need to Do Next)

### Step 1: Install Xcode (REQUIRED for iPhone/iPad)
**This is the big one!**

1. Open the **App Store** on your Mac
2. Search for **"Xcode"**
3. Click **"Get"** or **"Install"**
4. ⏰ **Wait** - This is HUGE (5+ GB), might take 30-60 minutes
5. After it installs:
   - Open Xcode from your Applications folder
   - Let it install extra tools (click "Install" when asked)
   - Wait for that to finish

### Step 2: Set Up Xcode (After It Installs)
Open Terminal in Cursor and run these commands one at a time:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

Type your computer password when asked (you won't see it typing - that's normal!).

### Step 3: Install CocoaPods (After Xcode is Done)
In Terminal, run:

```bash
sudo gem install cocoapods
```

Wait for it to finish.

### Step 4: Install Cursor Extensions
1. In Cursor, click the **square icon** on the left side (or press **Cmd+Shift+X**)
2. Search for **"Flutter"**
3. Install the one by **"Dart Code"** (it's the official one)
4. Restart Cursor when it asks

### Step 5: Test Everything Works
In Terminal, run:

```bash
cd /Users/minjeongkim/Documents/Dev/aac_keyboard/als_aac_keyboard
flutter doctor
```

Check for any red X marks. If everything looks good, you're ready!

### Step 6: Run Your App! 🎉
1. Open the iPhone Simulator:
   ```bash
   open -a Simulator
   ```

2. Run your app:
   ```bash
   flutter run
   ```

Wait for it to build (first time takes a few minutes), then your app will appear in the simulator!

---

## Quick Reference Commands

- `flutter doctor` - Check if everything is set up
- `flutter pub get` - Download code libraries (already done!)
- `flutter run` - Run your app
- `open -a Simulator` - Open iPhone simulator

