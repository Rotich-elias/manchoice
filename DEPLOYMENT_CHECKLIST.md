# Deployment Checklist - Manchoice App

Quick checklist for deploying your Manchoice app to Firebase.

---

## Pre-Deployment Setup (One-time)

### 1. Install Required Tools
```bash
# Install Node.js and npm (if not installed)
# Visit: https://nodejs.org/

# Install Firebase CLI
npm install -g firebase-tools

# Verify installation
firebase --version
flutter --version
```

### 2. Create Firebase Project
- [ ] Go to [Firebase Console](https://console.firebase.google.com/)
- [ ] Click "Add project"
- [ ] Name: `manchoice` or `manchoice-app`
- [ ] Enable/disable Google Analytics (your choice)
- [ ] Click "Create project"

### 3. Enable Web Support in Flutter
```bash
cd /home/smith/Desktop/MAN/manchoice
flutter config --enable-web
flutter create . --platforms=web
```

### 4. Initialize Firebase in Project
```bash
cd /home/smith/Desktop/MAN/manchoice

# Login to Firebase
firebase login

# Initialize Firebase Hosting
firebase init hosting

# Configuration:
# - Use existing project: manchoice
# - Public directory: build/web
# - Single-page app: Yes
# - GitHub deploys: No
```

---

## Backend Deployment (Choose One)

### Option A: Heroku (Recommended for Quick Start)

```bash
cd /home/smith/Desktop/MAN/manchoice-backend

# Install Heroku CLI (if not installed)
# Visit: https://devcenter.heroku.com/articles/heroku-cli

# Login
heroku login

# Create app
heroku create manchoice-api

# Add Procfile
echo "web: vendor/bin/heroku-php-apache2 public/" > Procfile

# Deploy
git add .
git commit -m "Deploy to Heroku"
git push heroku main

# Set environment variables
heroku config:set APP_KEY=$(php artisan key:generate --show)
heroku config:set APP_ENV=production
heroku config:set APP_DEBUG=false

# Add MySQL database
heroku addons:create cleardb:ignite

# Get database URL and configure
heroku config:get CLEARDB_DATABASE_URL

# Run migrations
heroku run php artisan migrate --force
heroku run php artisan storage:link
```

**Your backend URL:** `https://manchoice-api.herokuapp.com/api`

### Option B: DigitalOcean VPS

- [ ] Create Ubuntu 22.04 droplet ($5/month)
- [ ] Install LAMP stack
- [ ] Upload Laravel backend
- [ ] Configure domain (e.g., `api.manchoice.com`)
- [ ] Install SSL certificate (Let's Encrypt)
- [ ] Run migrations

**Your backend URL:** `https://api.manchoice.com/api`

---

## Flutter App Configuration

### 1. Update API URL
**File:** `lib/config/api_config.dart`

```dart
// Update this line with your deployed backend URL:
static const String _prodBaseUrl = 'https://manchoice-api.herokuapp.com/api';
// or
// static const String _prodBaseUrl = 'https://api.manchoice.com/api';
```

### 2. Update Laravel CORS
**File (Backend):** `config/cors.php`

```php
'allowed_origins' => [
    'https://manchoice-app.web.app',
    'https://manchoice-app.firebaseapp.com',
    'http://localhost:*', // For local dev
],
```

### 3. Update Laravel .env
**File (Backend):** `.env`

```env
SANCTUM_STATEFUL_DOMAINS=manchoice-app.web.app,manchoice-app.firebaseapp.com
SESSION_DOMAIN=.manchoice.com
```

---

## Deploy Flutter Web App

### Using the Deployment Script (Recommended)
```bash
cd /home/smith/Desktop/MAN/manchoice
./deploy.sh
```

### Manual Deployment
```bash
cd /home/smith/Desktop/MAN/manchoice

# Clean and build
flutter clean
flutter pub get
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

**Your web app URL:** `https://manchoice-app.web.app`

---

## Deploy Android App

### Build APK
```bash
cd /home/smith/Desktop/MAN/manchoice

# Build release APK
flutter build apk --release

# APK location:
# build/app/outputs/flutter-apk/app-release.apk
```

### Distribute APK

**Option 1: Firebase App Distribution**
```bash
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "testers"
```

**Option 2: Google Play Store**
- [ ] Create Google Play Developer account ($25)
- [ ] Build app bundle: `flutter build appbundle --release`
- [ ] Upload to Play Console
- [ ] Fill store listing
- [ ] Submit for review

**Option 3: Direct Distribution**
- [ ] Share APK file directly with users
- [ ] Users must enable "Install from unknown sources"

---

## Post-Deployment Testing

### Test Web App
- [ ] Visit Firebase URL: `https://manchoice-app.web.app`
- [ ] Test login/logout
- [ ] Test product browsing
- [ ] Test loan creation with products
- [ ] Test payments
- [ ] Check all images load correctly
- [ ] Test on different browsers (Chrome, Firefox, Safari)

### Test Mobile App
- [ ] Install APK on Android device
- [ ] Test all features
- [ ] Verify API connectivity
- [ ] Test offline behavior
- [ ] Check image loading
- [ ] Test M-Pesa integration (if applicable)

### Test Backend API
```bash
# Test categories
curl https://manchoice-api.herokuapp.com/api/products/categories

# Test products
curl https://manchoice-api.herokuapp.com/api/products

# Should return JSON responses
```

---

## Monitoring & Maintenance

### Firebase Console Monitoring
- [ ] Check Firebase Console → Hosting → Usage
- [ ] Monitor traffic and bandwidth
- [ ] Check for errors in Firebase Console

### Backend Monitoring
- [ ] Monitor server resources (CPU, RAM, Disk)
- [ ] Check Laravel logs: `storage/logs/laravel.log`
- [ ] Set up uptime monitoring (e.g., UptimeRobot)

### Regular Updates
- [ ] Update Flutter dependencies: `flutter pub upgrade`
- [ ] Update Laravel dependencies: `composer update`
- [ ] Apply security patches
- [ ] Back up database regularly

---

## Quick Commands Reference

```bash
# Firebase
firebase login                    # Login to Firebase
firebase projects:list            # List all projects
firebase deploy --only hosting    # Deploy to hosting
firebase hosting:sites:list       # List hosting URLs

# Flutter
flutter clean                     # Clean build files
flutter pub get                   # Get dependencies
flutter build web --release       # Build web app
flutter build apk --release       # Build Android APK
flutter build appbundle --release # Build Android AAB

# Laravel (on server)
php artisan migrate --force       # Run migrations
php artisan config:cache          # Cache config
php artisan route:cache           # Cache routes
php artisan view:cache            # Cache views
php artisan storage:link          # Create storage symlink
```

---

## Troubleshooting

### "Firebase CLI not found"
```bash
npm install -g firebase-tools
```

### "Permission denied" during deployment
```bash
firebase login --reauth
```

### "CORS error" in browser console
- Update `config/cors.php` in Laravel backend
- Add your Firebase domains to `allowed_origins`

### "API not reachable"
- Check API URL in `lib/config/api_config.dart`
- Verify backend server is running
- Check firewall/security groups

### "Build failed"
```bash
flutter clean
rm -rf build/
flutter pub get
flutter build web --release
```

---

## Estimated Costs

### Free Tier (Sufficient for Testing)
- Firebase Hosting: Free (10GB storage, 360MB/day)
- Firebase App Distribution: Free
- Heroku: Free tier (with some limitations)

### Production Tier
- Firebase Hosting: Free or $0.026/GB (pay as you go)
- Heroku: $7/month (Hobby tier)
- DigitalOcean VPS: $5-10/month
- Custom domain: $10-15/year
- Google Play: $25 one-time
- Apple Developer: $99/year

---

## Need Help?

### Documentation
- Firebase: https://firebase.google.com/docs/hosting
- Flutter: https://docs.flutter.dev/deployment
- Laravel: https://laravel.com/docs/deployment

### Community
- Flutter Discord: https://discord.gg/flutter
- Laravel Discord: https://discord.gg/laravel
- Stack Overflow

---

## Summary

**Quick Start Steps:**
1. Install Firebase CLI and login
2. Deploy Laravel backend (Heroku/VPS)
3. Update API URL in Flutter app
4. Initialize Firebase in Flutter project
5. Run `./deploy.sh` or build manually
6. Test thoroughly
7. Distribute mobile apps

**You're now ready to deploy!** 🚀

Start with the backend deployment, then move to the Flutter web deployment, and finally build mobile apps.
