# Simple Setup Guide for Flutter App

## Step 1: Install Flutter on Your Mac

Flutter is like the engine that makes your app run. You need to install it first.

1. **Download Flutter:**
   - Go to: https://docs.flutter.dev/get-started/install/macos
   - Click the big download button
   - It will download a file called `flutter_macos.zip`

2. **Unzip and Move Flutter:**
   - Double-click the zip file to unzip it
   - Move the `flutter` folder to a place you'll remember (like your Documents folder or your home folder)
   - Remember where you put it!

3. **Add Flutter to Your Computer's Path:**
   - Open Terminal (press Cmd+Space, type "Terminal", press Enter)
   - Type this command (replace YOUR_USERNAME with your actual username):
     ```
     echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
     ```
   - If you put Flutter somewhere else, use that path instead
   - Then type: `source ~/.zshrc`

4. **Check if it worked:**
   - Close and reopen Terminal
   - Type: `flutter --version`
   - If you see version numbers, it worked! ✅

## Step 2: Install Xcode (for iPhone/iPad Simulator)

Xcode is Apple's tool for making iPhone and iPad apps. You need it to test your app.

1. **Download Xcode:**
   - Open the App Store on your Mac
   - Search for "Xcode"
   - Click "Get" or "Install" (it's free but BIG - might take a while)
   - Wait for it to download and install

2. **Open Xcode Once:**
   - After it installs, open Xcode from your Applications folder
   - It will ask you to install extra tools - say YES
   - Wait for that to finish

3. **Accept the License:**
   - Open Terminal
   - Type: `sudo xcodebuild -license`
   - Type your computer password (you won't see it typing - that's normal!)
   - Type "agree" and press Enter

## Step 3: Install Extensions in Cursor

Extensions are like add-ons that help Cursor understand Flutter code better.

1. **Open Extensions in Cursor:**
   - Click the square icon on the left side (or press Cmd+Shift+X)
   - This opens the Extensions marketplace

2. **Install These Extensions:**
   - Search for "Flutter" and install the one by "Dart Code" (it's the official one)
   - Search for "Dart" and install the one by "Dart Code" (usually installs with Flutter)
   - After installing, Cursor might ask you to restart - click "Restart"

## Step 4: Get Your App Ready

1. **Open Your Project Folder in Cursor:**
   - File → Open Folder
   - Choose the `als_aac_keyboard` folder

2. **Get the Dependencies:**
   - Open Terminal in Cursor (Terminal → New Terminal, or press Ctrl+`)
   - Type: `flutter pub get`
   - Wait for it to finish (it downloads the code libraries your app needs)

## Step 5: Run Your App in the Simulator

1. **Check if Flutter is Happy:**
   - In Terminal, type: `flutter doctor`
   - This checks if everything is set up correctly
   - Fix any red X marks it shows (it will tell you how)

2. **Start the iPhone Simulator:**
   - In Terminal, type: `open -a Simulator`
   - Wait for a phone screen to appear on your computer

3. **Run Your App:**
   - In Terminal, make sure you're in your project folder: `cd /Users/minjeongkim/Documents/Dev/aac_keyboard/als_aac_keyboard`
   - Type: `flutter run`
   - Wait for it to build (first time takes a few minutes)
   - Your app will appear in the simulator! 🎉

## Troubleshooting

**If Flutter says "command not found":**
- You might need to add Flutter to your path (see Step 1, part 3)
- Try closing and reopening Terminal

**If the simulator doesn't open:**
- Make sure Xcode is installed and you opened it at least once
- Try: `flutter doctor` to see what's wrong

**If the app won't run:**
- Make sure you ran `flutter pub get` first
- Check that you're in the right folder (the one with `pubspec.yaml`)

## Quick Commands to Remember

- `flutter doctor` - Check if everything is set up
- `flutter pub get` - Download code libraries
- `flutter run` - Run your app
- `flutter clean` - Clean up if things get messy (then run `flutter pub get` again)

