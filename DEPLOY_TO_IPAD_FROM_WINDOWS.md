# Deploy Flutter App to iPad from Windows 10

Since you're on Windows 10 without access to a Mac, here are your options to get your app on your iPad:

## 🎉 Good News: You Can Test for FREE!

**You DON'T need a paid Apple Developer account ($99/year) to test on your iPad!**

Apple offers a **FREE Apple Developer account** that lets you:
- ✅ Sign and install apps on your own devices
- ✅ Test apps for 7 days (then re-sign)
- ✅ Build up to 3 apps at a time
- ❌ Can't publish to App Store (need paid account for that)

**Sign up for free account:** https://developer.apple.com/account/ (use your Apple ID)

---

## Option 1: EAS Build (EASIEST - Handles Everything Automatically! ⭐)

**This is the recommended option!** EAS Build handles code signing automatically, so you don't need to worry about certificates.

### Prerequisites:
1. **Free Apple Developer Account** (see above)
2. **Node.js** installed on Windows
3. **Expo account** (free)

### Steps:

1. **Install EAS CLI:**
   ```powershell
   npm install -g eas-cli
   ```

2. **Login and configure:**
   ```powershell
   eas login
   eas build:configure
   ```

3. **Build your app:**
   ```powershell
   eas build --platform ios --profile development
   ```
   - EAS will ask for your Apple ID (free developer account)
   - It automatically creates certificates and signs your app
   - Builds in the cloud (no Mac needed!)

4. **Download and install:**
   - Download the signed `.ipa` from EAS dashboard
   - Install on iPad using AltStore (see Method 2 below)

**See `EAS_BUILD_SETUP.md` for detailed instructions!**

---

## Option 2: GitHub Actions (FREE & Your Code is on GitHub! 🚀)

Since your code is on GitHub, you can use GitHub Actions to build your app.

**Note:** GitHub Actions can build the app, but code signing is tricky. For easiest experience, use EAS Build (Option 1) or Codemagic (Option 3).

### Steps:

1. **Workflow is already created!** (`.github/workflows/ios-build.yml`)

2. **Run the workflow:**
   - Go to Actions tab in GitHub
   - Click "Build iOS App" → "Run workflow"
   - Download the `.ipa` artifact

3. **Sign and install:**
   - The IPA may be unsigned (that's OK!)
   - Use AltStore to sign and install (AltStore handles signing automatically)
   - Or use EAS Build for proper signing

---

## Option 3: Codemagic (You Already Have Config! 🎉)

You already have a `codemagic.yaml` file! This works great too.

### Prerequisites:
1. **Free Apple Developer Account** (see above) - FREE!
   - Sign up at: https://developer.apple.com/account/
   - Use your existing Apple ID

2. **Codemagic Account** (Free tier available)
   - Sign up at: https://codemagic.io/signup

### Steps:

1. **Set up Codemagic:**
   - Go to https://codemagic.io and sign up/login
   - Connect your Git repository (GitHub, GitLab, Bitbucket, etc.)
   - Select your `aac_keyboard` repository

2. **Configure Code Signing:**
   - In Codemagic dashboard, go to your app settings
   - Navigate to "Code signing identities"
   - Upload your Apple Developer certificates:
     - **Distribution Certificate** (.p12 file)
     - **Provisioning Profile** (.mobileprovision file)
   - Or use Codemagic's automatic code signing (easier!)

3. **Update codemagic.yaml:**
   - Update the email in `codemagic.yaml` (line 33) to your email
   - If using automatic code signing, Codemagic will handle it

4. **Build the app:**
   - Push your code to the `main` branch (or trigger manually in Codemagic)
   - Codemagic will automatically build your iOS app
   - Download the `.ipa` file from Codemagic

5. **Install on iPad:**
   - **Option A: TestFlight (Recommended)**
     - Upload the `.ipa` to App Store Connect
     - Install TestFlight app on your iPad
     - Install your app via TestFlight
   
   - **Option B: Direct Install**
     - Use tools like **AltStore** or **3uTools** to sideload the `.ipa`
     - Requires your iPad to be connected to your Windows PC

---

## Code Signing Options

For the free Apple Developer account, you have these options:

### ✅ EAS Build (Recommended - Easiest!)
- Handles all signing automatically
- No certificates to manage
- See Option 1 above or `EAS_BUILD_SETUP.md`

### ✅ AltStore (Also Easy!)
- Can sign apps when installing
- Works with unsigned IPAs
- See Method 2 in "Installing the .ipa" section

### ⚠️ Manual Certificates (Complex)
- Requires Mac or Mac in cloud
- Need to generate and manage certificates
- Only needed for advanced scenarios

---

## Option 4: Mac in the Cloud (Paid - Not Recommended)

Rent a Mac in the cloud temporarily:

- **MacStadium**: https://www.macstadium.com/
- **AWS EC2 Mac instances**: https://aws.amazon.com/ec2/instance-types/mac/
- **MacinCloud**: https://www.macincloud.com/

Then follow standard iOS build process:
```bash
flutter build ipa --release
```

---

## Option 5: Use a Friend's Mac (Temporary)

If you can borrow a Mac for 30 minutes:
1. Install Flutter on the Mac
2. Run `flutter build ipa --release`
3. Transfer the `.ipa` file to your Windows PC
4. Install on iPad

---

## Installing the .ipa on Your iPad

### Method 1: TestFlight (Easiest & Most Reliable)

1. **Upload to App Store Connect:**
   - Go to https://appstoreconnect.apple.com
   - Create an app (if you haven't)
   - Upload the `.ipa` using Transporter app or Xcode
   - Add it to TestFlight

2. **Install on iPad:**
   - Install TestFlight app from App Store
   - Accept the TestFlight invitation
   - Install your app

### Method 2: AltStore (FREE - Works with Free Apple Developer Account! ⭐)

**This is the easiest way to test without a paid account!**

1. **Install AltStore on Windows:**
   - Download AltServer from: https://altstore.io/
   - Install AltServer on your Windows PC
   - Make sure iTunes or iCloud (with iCloud Drive) is installed
   - Connect your iPad via USB or be on the same WiFi

2. **Install AltStore on iPad:**
   - Open AltServer on your Windows PC
   - Click the AltServer icon in system tray → "Install AltStore" → Select your iPad
   - Enter your Apple ID (the one you used for free developer account)
   - AltStore will install on your iPad

3. **Install your app:**
   - Get the `.ipa` file (from GitHub Actions, Codemagic, or EAS)
   - Transfer it to your iPad (via AirDrop, email, or cloud storage)
   - Open AltStore on iPad → "My Apps" → "+" → Select your `.ipa`
   - Enter your Apple ID when prompted
   - Your app will install!

4. **Refresh every 7 days:**
   - Apps signed with free account expire after 7 days
   - Just open AltStore on iPad → "My Apps" → Tap refresh button
   - Make sure AltServer is running on your PC and iPad is on same network
   - Takes 30 seconds!

**Note:** You can install up to 3 apps at a time with free account. AltStore counts as 1, so you have 2 slots for your apps.

### Method 3: 3uTools (Windows Tool)

1. Download 3uTools: https://www.3u.com/
2. Connect iPad via USB
3. Use "Install IPA" feature to install your `.ipa`

---

## Quick Start: EAS Build + AltStore (Easiest & FREE! ⭐)

Here's the fastest FREE path (recommended):

1. **Sign up for free Apple Developer account**: https://developer.apple.com/account/
   - Use your existing Apple ID
   - It's completely free!

2. **Install EAS CLI:**
   ```powershell
   npm install -g eas-cli
   eas login
   eas build:configure
   ```

3. **Build your app:**
   ```powershell
   eas build --platform ios --profile development
   ```
   - Enter your Apple ID when prompted
   - EAS handles all the signing automatically!

4. **Install AltStore:**
   - Download AltServer: https://altstore.io/
   - Install on Windows PC
   - Install AltStore on your iPad (via AltServer)

5. **Install on iPad:**
   - Download `.ipa` from EAS dashboard
   - Transfer to iPad (email, AirDrop, or cloud)
   - Open AltStore → Install the `.ipa`
   - Done! Refresh every 7 days (takes 30 seconds)

**See `EAS_BUILD_SETUP.md` for detailed EAS instructions!**

---

## Alternative: Using Codemagic (Also Works!)

1. **Sign up for Codemagic**: https://codemagic.io/signup (free tier available)
2. **Connect your GitHub repo**
3. **Update email in codemagic.yaml**:
   ```yaml
   recipients:
     - your-actual-email@example.com  # Change this!
   ```
4. **Set up FREE Apple Developer account** (not paid!)
5. **Configure code signing in Codemagic** (automatic is easiest)
6. **Push to main branch** or trigger build manually
7. **Download .ipa** from Codemagic
8. **Install via AltStore** (see Method 2 above)

---

## Troubleshooting

**"Code signing failed"**
- Make sure you have a valid Apple Developer account
- Check that certificates are properly uploaded to Codemagic
- Verify your bundle identifier matches your provisioning profile

**"Can't install on iPad"**
- Make sure your iPad's UDID is in the provisioning profile
- For TestFlight: Make sure the app is approved in App Store Connect
- For AltStore: Make sure AltServer is running on your PC

**"Build fails"**
- Check Codemagic build logs
- Make sure all dependencies are in `pubspec.yaml`
- Verify Flutter version compatibility

---

## Need Help?

- Codemagic Docs: https://docs.codemagic.io/
- Flutter iOS Deployment: https://docs.flutter.dev/deployment/ios
- Apple Developer: https://developer.apple.com/support/

