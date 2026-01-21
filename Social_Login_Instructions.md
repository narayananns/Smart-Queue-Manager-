# Social Login Configuration Guide

I have already configured the **code** for your Android project (`build.gradle.kts`, `AndroidManifest.xml`, `strings.xml`), but you must perform the following **external** steps to make it work.

## 1. Google Sign-In Setup

### Step A: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and name it `koku`.    
3. Disable Google Analytics (for simplicity) and create the project.

### Step B: Add Android App
1. Inside the project, click the **Android** icon.
2. **Package Name**: `com.example.koku` (from your build files).
3. **Debug Signing Certificate SHA-1**:
   Run this command in your terminal inside the `koku/android` folder:
   ```bash
   ./gradlew signingReport
   ```
   *If on Windows CMD, use `gradlew signingReport`.*
   Copy the `SHA1` from the output and paste it into the Firebase console.

### Step C: Download Config File
1. Download `google-services.json`.
2. Move this file into: `d:\Smart Queue Manager\koku\android\app\google-services.json`.

---

## 2. Facebook Login Setup

### Step A: Create Meta App
1. Go to [Meta for Developers](https://developers.facebook.com/).
2. Create a new app (Select Type: **Consumer** or **Business**).
3. In "Add products to your app", click "Set up" on **Facebook Login**.
4. Select **Android**.

### Step B: Android Configuration
1. **Package Name**: `com.example.koku`
2. **Default Activity Class**: `com.example.koku.MainActivity`
3. **Key Hashes**:
   You create this from the SHA-1 you got earlier. Usually, for debug, you can use this generic one (or generate your own using OpenSSL):
   *(If you have openSSL installed)*:
   ```bash
   keytool -exportcert -alias androiddebugkey -keystore "C:\Users\YOUR_USER\.android\debug.keystore" | openssl sha1 -binary | openssl base64
   ```
   *Password is usually `android`.*

### Step C: Update Your IDs (Crucial)
I created a file for you at `android/app/src/main/res/values/strings.xml`.
Open it and replace the placeholders:

1. Copy **App ID** from Facebook Dashboard -> Paste into `facebook_app_id`.
2. Copy **Client Token** (Settings -> Advanced -> Client Token) -> Paste into `facebook_client_token`.
3. Update `fb_login_protocol_scheme` -> It must be `fb` followed immediately by your App ID (e.g., `fb123456789`).

---

## 3. iOS Setup (If needed)
If you plan to run on iOS Simulator or iPhone:
1. Drag `GoogleService-Info.plist` into your `ios/Runner` folder via Xcode.
2. Add URL Schemes to `ios/Runner/Info.plist` for both Google (reversed client ID) and Facebook.
