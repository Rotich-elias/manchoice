# Man's Choice Enterprise - Production Deployment Checklist

## Created: 2025-10-29

---

## ⚠️ CRITICAL - MUST DO BEFORE PRODUCTION

### Backend Configuration

- [ ] **Update `.env` file with production settings**
  - [ ] Set `APP_ENV=production`
  - [ ] Set `APP_DEBUG=false`
  - [ ] Update `APP_URL` to production domain (e.g., `https://api.manschoice.com`)
  - [ ] Set `LOG_LEVEL=error` or `warning`
  - [ ] Update database credentials (use strong password)
  - [ ] Configure M-PESA production credentials:
    - [ ] Set `MPESA_ENV=production`
    - [ ] Update `MPESA_CONSUMER_KEY` with live credentials
    - [ ] Update `MPESA_CONSUMER_SECRET` with live credentials
    - [ ] Update `MPESA_SHORTCODE` with your paybill number
    - [ ] Update `MPESA_PASSKEY` with production passkey
    - [ ] Update callback URLs to use production domain
  - [ ] Update `MAIL_FROM_ADDRESS` to your business email

- [ ] **Change Default Admin Password**
  ```bash
  php artisan tinker
  $admin = \App\Models\User::find(1);
  $admin->password = bcrypt('YOUR_STRONG_PASSWORD_HERE');
  $admin->save();
  ```

- [ ] **Delete or Secure Sensitive Files**
  - [ ] Delete `ADMIN_CREDENTIALS.md` from production server
  - [ ] Delete all `*.sh` test scripts
  - [ ] Remove or archive `.sql` dump files

- [ ] **Set Proper File Permissions**
  ```bash
  chmod 600 .env
  chmod -R 755 storage
  chmod -R 755 bootstrap/cache
  ```

- [ ] **Clear and Cache Configuration**
  ```bash
  php artisan config:clear
  php artisan cache:clear
  php artisan route:clear
  php artisan config:cache
  php artisan route:cache
  ```

- [ ] **Run Migrations**
  ```bash
  php artisan migrate --force
  ```

- [ ] **Configure SSL/HTTPS**
  - [ ] Obtain SSL certificate (Let's Encrypt, Cloudflare, etc.)
  - [ ] Configure web server (Nginx/Apache) to use HTTPS
  - [ ] Set up automatic HTTP to HTTPS redirect
  - [ ] Update `APP_URL` in `.env` to use https://

- [ ] **Set Up Database Backups**
  - [ ] Configure automated daily backups
  - [ ] Test backup restoration process
  - [ ] Store backups in secure offsite location

### Frontend Configuration

- [ ] **Update API URLs**
  - [ ] Open `/home/smith/Desktop/MAN/manschoice/lib/config/api_config.dart`
  - [ ] Update `_prodBaseUrl` to your production backend URL
  - [ ] Example: `'https://api.manschoice.com/api'`

- [ ] **Update M-PESA Paybill Number**
  - [ ] Open `/home/smith/Desktop/MAN/manschoice/lib/screens/payments_screen.dart`
  - [ ] Update `mpesaPaybill` (line 33) with your actual paybill number

- [ ] **Update Package Name** (if not done)
  - [ ] The package name has been changed to `com.manschoice.enterprise`
  - [ ] If you want a different name, update:
    - [ ] `android/app/build.gradle.kts` (namespace and applicationId)
    - [ ] `android/app/src/main/kotlin/com/manschoice/enterprise/MainActivity.kt` (package)
    - [ ] Move MainActivity.kt to new package folder structure

- [ ] **Create Android Release Keystore**
  ```bash
  # Generate keystore
  keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
    -keysize 2048 -validity 10000 -alias upload

  # Create key.properties file in android/ directory
  # DO NOT commit this file to git!
  ```

- [ ] **Create `android/key.properties` file**
  ```properties
  storePassword=YOUR_KEYSTORE_PASSWORD
  keyPassword=YOUR_KEY_PASSWORD
  keyAlias=upload
  storeFile=/path/to/upload-keystore.jks
  ```

- [ ] **Disable Cleartext Traffic**
  - [ ] Open `android/app/src/main/AndroidManifest.xml`
  - [ ] Change `android:usesCleartextTraffic="true"` to `"false"`
  - [ ] ONLY do this after backend is using HTTPS!

- [ ] **Build Release APK/AAB**
  ```bash
  # For APK (direct installation)
  flutter build apk --release

  # For App Bundle (Google Play Store)
  flutter build appbundle --release
  ```

---

## HIGH PRIORITY

### Security

- [ ] **Verify No Debug Code**
  - [ ] Remove all `print()` and `debugPrint()` statements
  - [ ] Remove `test_backend_connection.dart` or exclude from build
  - [ ] Verify no test credentials in code

- [ ] **Enable Rate Limiting**
  - [ ] Configure Laravel rate limiting middleware
  - [ ] Set appropriate limits for API endpoints

- [ ] **Configure CORS**
  - [ ] Review `config/cors.php` settings
  - [ ] Allow only necessary origins in production

- [ ] **Session Security**
  - [ ] Consider setting `SESSION_ENCRYPT=true` in `.env`
  - [ ] Configure secure session cookies

### Testing

- [ ] **Test Critical Flows**
  - [ ] User registration
  - [ ] Login/logout
  - [ ] Loan application
  - [ ] Registration fee payment
  - [ ] Deposit payment
  - [ ] Daily payment flow
  - [ ] M-PESA integration (if live)
  - [ ] Admin panel access
  - [ ] Loan approval workflow

- [ ] **Test on Real Devices**
  - [ ] Test on multiple Android devices
  - [ ] Test on different network conditions
  - [ ] Test with production API

### Monitoring

- [ ] **Set Up Error Monitoring**
  - [ ] Configure error logging
  - [ ] Set up email notifications for critical errors
  - [ ] Monitor `storage/logs/laravel.log`

- [ ] **Set Up Performance Monitoring**
  - [ ] Monitor API response times
  - [ ] Monitor database query performance
  - [ ] Set up uptime monitoring

---

## MEDIUM PRIORITY

### Optimization

- [ ] **Optimize Database**
  - [ ] Add indexes to frequently queried columns
  - [ ] Configure database connection pooling
  - [ ] Set up query caching

- [ ] **Optimize Assets**
  - [ ] Compress images in Flutter app
  - [ ] Minimize app size
  - [ ] Enable ProGuard/R8 (already configured)

- [ ] **Configure Queue Workers**
  - [ ] Set up queue worker for background jobs
  - [ ] Configure supervisor to keep workers running

### Documentation

- [ ] **Create Admin Documentation**
  - [ ] Document admin panel features
  - [ ] Document loan approval process
  - [ ] Document payment verification process

- [ ] **Create Deployment Documentation**
  - [ ] Document server setup process
  - [ ] Document deployment steps
  - [ ] Document rollback procedure

- [ ] **Create Backup Documentation**
  - [ ] Document backup process
  - [ ] Document restore process
  - [ ] Document disaster recovery plan

---

## DEPLOYMENT STEPS

### 1. Backend Deployment

```bash
# 1. Upload code to server
git clone <repository> /var/www/manschoice-backend
cd /var/www/manschoice-backend

# 2. Install dependencies
composer install --optimize-autoloader --no-dev

# 3. Configure environment
cp .env.example .env
nano .env  # Update with production settings

# 4. Set permissions
chmod 600 .env
chmod -R 755 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# 5. Generate key (if needed)
php artisan key:generate

# 6. Run migrations
php artisan migrate --force

# 7. Create storage link
php artisan storage:link

# 8. Cache configuration
php artisan config:cache
php artisan route:cache

# 9. Configure web server (Nginx/Apache)
# 10. Configure SSL certificate
# 11. Start PHP-FPM/web server
```

### 2. Frontend Deployment

```bash
# 1. Update production URLs
nano lib/config/api_config.dart  # Update _prodBaseUrl

# 2. Build release APK/AAB
flutter build appbundle --release

# 3. Sign APK (if building APK directly)
# This is automatic if key.properties is configured

# 4. Test release build
flutter install --release

# 5. Upload to Google Play Store (if using)
# Or distribute APK directly to users
```

---

## POST-DEPLOYMENT

### Immediate Actions

- [ ] **Monitor Logs**
  - [ ] Check `storage/logs/laravel.log` for errors
  - [ ] Monitor server error logs
  - [ ] Check application performance

- [ ] **Verify All Features**
  - [ ] Test user registration
  - [ ] Test login
  - [ ] Test loan application
  - [ ] Test payments (use test amounts first)
  - [ ] Test admin panel

- [ ] **Create First Backup**
  - [ ] Backup database
  - [ ] Backup uploaded files
  - [ ] Store backups securely

### Ongoing Maintenance

- [ ] **Daily**
  - [ ] Check application logs
  - [ ] Monitor server resources
  - [ ] Verify automated tasks are running

- [ ] **Weekly**
  - [ ] Review error logs
  - [ ] Check backup integrity
  - [ ] Update dependencies (security patches)

- [ ] **Monthly**
  - [ ] Review security
  - [ ] Optimize database
  - [ ] Review and archive old logs

---

## ROLLBACK PLAN

If deployment fails:

1. **Stop the application**
2. **Restore previous version from git**
3. **Restore database from backup** (if migrations were run)
4. **Clear all caches**
5. **Test critical functionality**
6. **Investigate and fix issues**
7. **Re-deploy when ready**

---

## SUPPORT CONTACTS

### Technical Issues
- Laravel Logs: `storage/logs/laravel.log`
- Server Logs: `/var/log/nginx/` or `/var/log/apache2/`

### Safaricom M-PESA Support
- Daraja Support: https://developer.safaricom.co.ke/
- Contact: developer@safaricom.co.ke

---

## IMPORTANT REMINDERS

1. **NEVER use default passwords in production**
2. **ALWAYS use HTTPS in production**
3. **ALWAYS backup before making changes**
4. **NEVER commit sensitive files to git** (.env, key.properties, keystores)
5. **TEST payment integration thoroughly before going live**
6. **Keep dependencies updated** (security patches)
7. **Monitor logs regularly** for errors and security issues

---

## STATUS TRACKING

Deployment Date: ___________
Deployed By: ___________
Production URL: ___________
App Version: ___________

Last Updated: 2025-10-29
