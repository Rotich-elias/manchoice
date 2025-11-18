# Android Release Keystore Setup Guide

## Overview

To publish your app to the Google Play Store or distribute a signed APK, you need to create a **release keystore** and configure your app to use it.

⚠️ **IMPORTANT**: Keep your keystore file safe! If you lose it, you cannot update your app on the Play Store.

---

## Step 1: Generate a Keystore

Run this command on your development machine:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### What each parameter means:
- `-keystore ~/upload-keystore.jks`: Creates keystore in your home directory
- `-keyalg RSA`: Uses RSA algorithm
- `-keysize 2048`: 2048-bit key size
- `-validity 10000`: Valid for 10,000 days (~27 years)
- `-alias upload`: Alias name for the key

### You will be prompted for:
1. **Keystore password**: Choose a strong password (remember this!)
2. **Key password**: Can be same as keystore password
3. **Your details**: Name, organization, city, etc.

### Example:
```bash
$ keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

Enter keystore password: ********
Re-enter new password: ********
What is your first and last name?
  [Unknown]:  John Doe
What is the name of your organizational unit?
  [Unknown]:  IT
What is the name of your organization?
  [Unknown]:  Man's Choice Enterprise
What is the name of your City or Locality?
  [Unknown]:  Nairobi
What is the name of your State or Province?
  [Unknown]:  Nairobi
What is the two-letter country code for this unit?
  [Unknown]:  KE
Is CN=John Doe, OU=IT, O=Man's Choice Enterprise, L=Nairobi, ST=Nairobi, C=KE correct?
  [no]:  yes

Enter key password for <upload>
        (RETURN if same as keystore password):
```

---

## Step 2: Create key.properties File

Create a file named `key.properties` in the `android/` directory:

```bash
cd /home/smith/Desktop/MAN/manschoice/android
nano key.properties
```

Add the following content:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/home/yourusername/upload-keystore.jks
```

Replace:
- `YOUR_KEYSTORE_PASSWORD` with the password you chose
- `YOUR_KEY_PASSWORD` with the key password (usually same as keystore password)
- `/home/yourusername/upload-keystore.jks` with the actual path to your keystore

### Example key.properties:
```properties
storePassword=MyStr0ng!P@ssw0rd
keyPassword=MyStr0ng!P@ssw0rd
keyAlias=upload
storeFile=/home/smith/upload-keystore.jks
```

---

## Step 3: Secure the Files

### Add key.properties to .gitignore

The `key.properties` file is **ALREADY** in `.gitignore`. Verify:

```bash
cd /home/smith/Desktop/MAN/manschoice
grep -n "key.properties" .gitignore
```

If it's not there, add it:

```bash
echo "android/key.properties" >> .gitignore
echo "*.jks" >> .gitignore
echo "*.keystore" >> .gitignore
```

### Set Proper Permissions

```bash
chmod 600 android/key.properties
chmod 600 ~/upload-keystore.jks
```

---

## Step 4: Backup Your Keystore

⚠️ **CRITICAL**: Store your keystore in multiple secure locations:

1. **External Hard Drive** (encrypted)
2. **Cloud Storage** (encrypted, like 1Password, LastPass)
3. **Secure USB Drive** (locked in safe)

**If you lose this file, you CANNOT update your app on Google Play Store!**

### Save These Details Securely:
- Keystore file location
- Keystore password
- Key alias: `upload`
- Key password
- Keystore creation date

---

## Step 5: Build Release APK/AAB

Once `key.properties` is configured, build your release:

### For APK (Direct Installation):
```bash
cd /home/smith/Desktop/MAN/manschoice
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### For App Bundle (Google Play Store):
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

---

## Step 6: Verify Signing

Verify your APK is signed correctly:

```bash
# Check APK signature
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Should show:
# jar verified.
```

Check app bundle:

```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

---

## Troubleshooting

### Error: "key.properties not found"
- Make sure the file is in the `android/` directory
- Check the file path in build.gradle.kts

### Error: "Keystore file not found"
- Verify the `storeFile` path in `key.properties`
- Use absolute path to keystore file

### Error: "Invalid keystore format"
- Make sure you used `keytool` to generate the keystore
- Verify it's a `.jks` file

### Error: "Incorrect password"
- Double-check passwords in `key.properties`
- Try regenerating the keystore

### Build still using debug signing
- Clean the project: `flutter clean`
- Delete build folder: `rm -rf build/`
- Rebuild: `flutter build apk --release`

---

## Google Play Store Upload

### First Time Upload:

1. **Create App Listing** on Google Play Console
2. **Upload App Bundle** (.aab file)
3. **Fill in Store Listing**:
   - App name: Man's Choice Enterprise
   - Short description
   - Full description
   - Screenshots (required)
   - Feature graphic (required)
4. **Set Content Rating**
5. **Set Pricing** (Free or Paid)
6. **Publish**

### Updating Existing App:

1. **Increment version** in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # Increment build number
   ```
2. **Build new bundle**:
   ```bash
   flutter build appbundle --release
   ```
3. **Upload to Play Console**
4. **Submit for Review**

---

## Security Best Practices

1. ✅ **NEVER commit keystore files to git**
2. ✅ **NEVER commit key.properties to git**
3. ✅ **Store backups in multiple secure locations**
4. ✅ **Use strong, unique passwords**
5. ✅ **Encrypt backups**
6. ✅ **Document keystore details securely**
7. ❌ **NEVER share keystore files**
8. ❌ **NEVER email keystore files**

---

## Quick Reference

### Generate Keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### key.properties Template:
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

### Build Release:
```bash
flutter build apk --release              # For APK
flutter build appbundle --release        # For Play Store
```

### Verify Signature:
```bash
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

---

## Need Help?

- Flutter Documentation: https://docs.flutter.dev/deployment/android
- Android Studio Guide: https://developer.android.com/studio/publish/app-signing
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter+android-signing

---

**Created:** 2025-10-29
**Last Updated:** 2025-10-29
