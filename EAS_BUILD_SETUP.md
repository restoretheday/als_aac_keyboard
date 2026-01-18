# EAS Build Setup (Easiest Option - Handles Signing Automatically!)

EAS (Expo Application Services) can build and sign your Flutter app automatically, even with a free Apple Developer account. This is the **easiest option** since it handles all the code signing for you!

## Prerequisites

1. **Free Apple Developer Account**
   - Sign up at: https://developer.apple.com/account/
   - Use your existing Apple ID

2. **Node.js installed on Windows**
   - Download from: https://nodejs.org/
   - Install it (includes npm)

3. **Expo account** (free)
   - Sign up at: https://expo.dev/signup

## Setup Steps

### 1. Install EAS CLI

Open PowerShell and run:
```powershell
npm install -g eas-cli
```

### 2. Login to Expo

```powershell
eas login
```

Enter your Expo account credentials.

### 3. Configure EAS Build

In your project directory, run:
```powershell
eas build:configure
```

This will create an `eas.json` file in your project.

### 4. Build for iOS

```powershell
eas build --platform ios --profile development
```

**What happens:**
- EAS will ask you to log in with your Apple ID (the one with free developer account)
- EAS will automatically create certificates and provisioning profiles
- EAS will build your app in the cloud
- You'll get a download link for the signed `.ipa` file

### 5. Install on iPad

1. Download the `.ipa` file from the EAS dashboard
2. Transfer it to your iPad (email, AirDrop, or cloud storage)
3. Use **AltStore** to install it (see main guide)

## EAS Build Profiles

You can customize build settings in `eas.json`. For testing, the `development` profile is perfect.

## Cost

- **Free tier**: 30 builds per month
- **Paid tier**: More builds if needed (but free tier is plenty for testing!)

## Advantages

✅ No Mac needed  
✅ Automatic code signing  
✅ Works with free Apple Developer account  
✅ Handles all certificates automatically  
✅ Builds in the cloud  

## Next Steps

After your first build, you can:
- Set up automatic builds on git push
- Configure different build profiles
- Add to CI/CD pipeline

See: https://docs.expo.dev/build/introduction/



