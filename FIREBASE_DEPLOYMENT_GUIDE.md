# Firebase Deployment Guide - Manchoice App

**Date:** October 16, 2025
**App:** Manchoice Flutter App + Laravel Backend

---

## Overview

This guide covers deploying your Manchoice app to Firebase. Since you have both a Flutter frontend and Laravel backend, we'll cover:

1. **Flutter Web** → Firebase Hosting
2. **Android/iOS Apps** → Firebase App Distribution (for testing) or Google Play/App Store
3. **Laravel Backend** → Alternative hosting solutions (Firebase doesn't support PHP)

---

## Part 1: Firebase Project Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `manchoice` or `manchoice-app`
4. Enable Google Analytics (optional but recommended)
5. Click **"Create project"**

### Step 2: Install Firebase CLI

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login

# Verify installation
firebase --version
```

---

## Part 2: Deploy Flutter Web to Firebase Hosting

### Step 1: Enable Web Support in Flutter

```bash
cd /home/smith/Desktop/MAN/manchoice

# Check if web is enabled
flutter devices

# If web is not listed, enable it
flutter config --enable-web

# Create web build
flutter create . --platforms=web
```

### Step 2: Update API Configuration for Production

**File:** `lib/config/api_config.dart`

```dart
class ApiConfig {
  // Development
  static const String devBaseUrl = 'http://192.168.100.65:8000/api';

  // Production (update this with your actual backend URL)
  static const String prodBaseUrl = 'https://your-backend-domain.com/api';

  // Use production URL when building for release
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // Endpoints
  static const String products = '/products';
  static const String loans = '/loans';
  static const String customers = '/customers';
  static const String payments = '/payments';
}
```

### Step 3: Build Flutter Web App

```bash
# Build for production
flutter build web --release

# The output will be in: build/web/
```

### Step 4: Initialize Firebase in Your Flutter Project

```bash
# Make sure you're in the Flutter app directory
cd /home/smith/Desktop/MAN/manchoice

# Initialize Firebase
firebase init

# Select these options:
# ◯ Hosting: Configure files for Firebase Hosting
#
# Choose: Use an existing project
# Select: manchoice (or your project name)
#
# What do you want to use as your public directory? build/web
# Configure as a single-page app? Yes
# Set up automatic builds and deploys with GitHub? No
```

This creates:
- `firebase.json` - Firebase configuration
- `.firebaserc` - Project settings

### Step 5: Deploy to Firebase Hosting

```bash
# Deploy to Firebase
firebase deploy --only hosting

# You'll get a URL like: https://manchoice-app.web.app
```

### Step 6: Custom Domain (Optional)

1. Go to Firebase Console → Hosting
2. Click **"Add custom domain"**
3. Follow the DNS configuration steps
4. Example: `app.manchoice.com`

---

## Part 3: Android/iOS App Distribution

### Option A: Firebase App Distribution (For Testing)

Firebase App Distribution is perfect for distributing beta versions to testers.

#### Step 1: Install Firebase App Distribution

```bash
# In your Flutter project
flutter pub add firebase_core
flutter pub add firebase_app_distribution
```

#### Step 2: Configure Firebase for Mobile

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Android and iOS
flutterfire configure
```

This will:
- Create `firebase_options.dart`
- Configure Android app in `android/app/build.gradle`
- Configure iOS app in `ios/Runner/Info.plist`

#### Step 3: Build Android APK/AAB

```bash
# Build APK (for testing)
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output locations:
# APK: build/app/outputs/flutter-apk/app-release.apk
# AAB: build/app/outputs/bundle/release/app-release.aab
```

#### Step 4: Upload to Firebase App Distribution

```bash
# Install Firebase CLI if not already done
npm install -g firebase-tools

# Login
firebase login

# Upload APK to App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "testers" \
  --release-notes "Initial release with product-based loans"
```

Or use the Firebase Console:
1. Go to Firebase Console → App Distribution
2. Click **"Distribute app"**
3. Upload your APK/AAB
4. Add tester emails
5. Send invitation

#### Step 5: Build iOS App (Requires macOS)

```bash
# Build iOS
flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select "Any iOS Device"
# 2. Product → Archive
# 3. Upload to App Store Connect or export IPA
```

### Option B: Google Play Store / Apple App Store

For production release:

**Google Play Store:**
1. Create developer account ($25 one-time fee)
2. Build app bundle: `flutter build appbundle --release`
3. Upload to Play Console
4. Fill in store listing details
5. Submit for review

**Apple App Store:**
1. Create Apple Developer account ($99/year)
2. Build and archive in Xcode
3. Upload to App Store Connect
4. Fill in app information
5. Submit for review

---

## Part 4: Laravel Backend Deployment

**IMPORTANT:** Firebase Hosting does NOT support PHP/Laravel. You need alternative hosting.

### Option 1: Traditional VPS (Recommended)

**Providers:**
- DigitalOcean ($5-10/month)
- Linode ($5/month)
- Vultr ($5/month)
- AWS Lightsail ($3.50/month)

**Steps:**
1. Create Ubuntu 22.04 VPS
2. Install LAMP stack (Linux, Apache, MySQL, PHP)
3. Configure domain (e.g., `api.manchoice.com`)
4. Upload Laravel app
5. Configure SSL with Let's Encrypt
6. Set up database

**Quick Setup Script:**
```bash
# On your VPS (Ubuntu)
sudo apt update
sudo apt install -y apache2 mysql-server php8.2 php8.2-mysql php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip composer

# Clone your repo
git clone YOUR_REPO_URL /var/www/manchoice-backend
cd /var/www/manchoice-backend

# Install dependencies
composer install --no-dev --optimize-autoloader

# Configure environment
cp .env.example .env
php artisan key:generate

# Configure Apache virtual host
# Set document root to: /var/www/manchoice-backend/public

# Set permissions
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache

# Run migrations
php artisan migrate --force

# Create storage symlink
php artisan storage:link
```

### Option 2: Heroku (Easy Setup)

```bash
# Install Heroku CLI
curl https://cli-assets.heroku.com/install.sh | sh

# Login
heroku login

# Create app
cd /home/smith/Desktop/MAN/manchoice-backend
heroku create manchoice-api

# Add Procfile
echo "web: vendor/bin/heroku-php-apache2 public/" > Procfile

# Deploy
git add .
git commit -m "Prepare for Heroku deployment"
git push heroku main

# Set environment variables
heroku config:set APP_KEY=$(php artisan key:generate --show)
heroku config:set APP_ENV=production
heroku config:set APP_DEBUG=false

# Add database (free tier)
heroku addons:create cleardb:ignite

# Run migrations
heroku run php artisan migrate --force
```

### Option 3: Shared Hosting (Budget Option)

**Providers:**
- Hostinger ($2-3/month)
- Namecheap
- Bluehost

**Requirements:**
- PHP 8.1+
- MySQL/MariaDB
- SSH access (preferred)
- Composer support

### Option 4: Firebase Cloud Functions (Advanced)

Convert Laravel API to Node.js Firebase Cloud Functions (requires rewriting backend).

---

## Part 5: Post-Deployment Configuration

### Update Flutter App with Backend URL

After deploying backend, update Flutter app:

**File:** `lib/config/api_config.dart`

```dart
class ApiConfig {
  // Production backend URL
  static const String baseUrl = 'https://api.manchoice.com/api';
  // or
  // static const String baseUrl = 'https://manchoice-api.herokuapp.com/api';

  static const String products = '/products';
  static const String loans = '/loans';
  static const String customers = '/customers';
  static const String payments = '/payments';
}
```

Rebuild and redeploy Flutter app:
```bash
flutter build web --release
firebase deploy --only hosting
```

### Configure CORS in Laravel

**File:** `config/cors.php`

```php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'https://manchoice-app.web.app',
        'https://manchoice-app.firebaseapp.com',
        'http://localhost:*', // For local development
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

### Update .env on Backend

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.manchoice.com

# Update database credentials
DB_CONNECTION=mysql
DB_HOST=your-db-host
DB_PORT=3306
DB_DATABASE=manchoice_db
DB_USERNAME=your-username
DB_PASSWORD=your-password

# CORS origins
SANCTUM_STATEFUL_DOMAINS=manchoice-app.web.app,manchoice-app.firebaseapp.com
SESSION_DOMAIN=.manchoice.com
```

---

## Part 6: Testing Your Deployment

### Test Flutter Web App

1. Visit your Firebase URL: `https://manchoice-app.web.app`
2. Test login/logout
3. Test product browsing
4. Test loan creation
5. Verify API calls work

### Test Mobile App

1. Install APK on Android device
2. Test all features
3. Check network requests
4. Verify data persistence

### Test Backend API

```bash
# Test categories endpoint
curl https://api.manchoice.com/api/products/categories

# Test products endpoint
curl https://api.manchoice.com/api/products

# Should return JSON responses
```

---

## Part 7: Continuous Deployment (Optional)

### Setup GitHub Actions for Auto-Deploy

**File:** `.github/workflows/deploy.yml` (in Flutter repo)

```yaml
name: Deploy to Firebase

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Build web
        run: flutter build web --release

      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: manchoice-app
```

---

## Summary Checklist

### Flutter Web on Firebase Hosting
- [ ] Create Firebase project
- [ ] Install Firebase CLI
- [ ] Enable web support in Flutter
- [ ] Update API config with production URL
- [ ] Build Flutter web app
- [ ] Initialize Firebase in project
- [ ] Deploy to Firebase Hosting
- [ ] Test deployed web app

### Mobile App Distribution
- [ ] Configure Firebase for mobile
- [ ] Build Android APK/AAB
- [ ] Upload to Firebase App Distribution or Play Store
- [ ] Build iOS app (if applicable)
- [ ] Test on real devices

### Backend Deployment
- [ ] Choose hosting provider (VPS/Heroku/Shared)
- [ ] Set up server with PHP 8.2+
- [ ] Deploy Laravel backend
- [ ] Configure database
- [ ] Run migrations
- [ ] Set up SSL certificate
- [ ] Configure CORS
- [ ] Update environment variables
- [ ] Test API endpoints

### Post-Deployment
- [ ] Update Flutter app with backend URL
- [ ] Redeploy Flutter app
- [ ] Test complete flow (Frontend → Backend)
- [ ] Set up monitoring (optional)
- [ ] Configure custom domains (optional)

---

## Costs Estimate

### Free Tier
- Firebase Hosting: Free (10GB storage, 360MB/day transfer)
- Firebase App Distribution: Free
- Backend: $0 (if using free tier services)

### Paid Options
- Custom domain: $10-15/year
- VPS hosting: $5-10/month
- Google Play Developer: $25 one-time
- Apple Developer: $99/year
- SSL Certificate: Free (Let's Encrypt) or $10-50/year

---

## Support & Troubleshooting

### Common Issues

**Issue:** "Firebase CLI not found"
```bash
npm install -g firebase-tools
```

**Issue:** "Permission denied during deploy"
```bash
firebase login --reauth
```

**Issue:** "CORS error in browser"
- Update `config/cors.php` in Laravel
- Add Firebase domains to `allowed_origins`

**Issue:** "API not reachable from mobile app"
- Check API URL in `api_config.dart`
- Verify backend is running
- Check CORS configuration

---

## Next Steps

1. **Choose your backend hosting** (I recommend starting with Heroku for ease)
2. **Deploy backend first** (get the API URL)
3. **Update Flutter app** with production API URL
4. **Build and deploy Flutter web** to Firebase
5. **Test thoroughly** before distributing to users

---

## Need Help?

If you need assistance with any step:
1. Check the Firebase documentation: https://firebase.google.com/docs
2. Flutter deployment guide: https://docs.flutter.dev/deployment
3. Laravel deployment: https://laravel.com/docs/deployment

---

**Ready to deploy?** Start with Part 1 and work through each section systematically!
