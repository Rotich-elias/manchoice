# Fresh Start Instructions - Guarantor Motorcycle Fields

## ✅ Database Cleaned Successfully!

All customer, loan, and payment data has been cleared from the backend database.

**Current Status:**
- Customers: 0
- Loans: 0
- Payments: 0
- Documents: Cleared

---

## 📱 Clear Flutter App Data

To completely start fresh on the mobile app, you need to **clear the app data**:

### Option 1: Uninstall and Reinstall (Recommended)
1. **Uninstall the app** from your device/emulator
2. **Reinstall** by running:
   ```bash
   flutter run
   ```

### Option 2: Clear App Data Manually (Android)
1. Go to **Settings** → **Apps** → **MansChoice**
2. Tap **Storage**
3. Tap **Clear Data** and **Clear Cache**
4. Restart the app

### Option 3: Clear SharedPreferences Programmatically
If you want to clear on app startup, you can add this code temporarily to `main.dart`:

```dart
// Add to main() function before runApp()
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

---

## 🆕 New Fields Now Available

The app now includes **Guarantor Motorcycle Details**:

### Form Fields Added:
1. **Number Plate** - Guarantor's bike registration
2. **Chassis Number** - Guarantor's bike chassis
3. **Model** - Guarantor's bike model
4. **Type** - Guarantor's bike type
5. **Engine CC** - Guarantor's bike engine capacity
6. **Colour** - Guarantor's bike color
7. **Bike Photo** - Photo of guarantor's motorcycle
8. **Logbook Photo** - Photo of guarantor's bike logbook

### Backend Database:
- ✅ Migration executed
- ✅ New columns added to `customers` table
- ✅ Customer model updated
- ✅ API validation updated

---

## 🧪 Testing the New Fields

1. **Register or Login** as a new user
2. **Navigate to Profile Completion** (or start a loan application)
3. **Fill in all sections** including:
   - Personal Information
   - Motorcycle Details (yours)
   - Next of Kin
   - **Guarantor Personal Details**
   - **Guarantor Motorcycle Details** ⬅️ NEW SECTION
4. **Upload all photos** including guarantor's bike photos
5. **Submit the application**
6. **Verify** the data is saved correctly in the database

### Check Database After Submission:
```bash
cd /home/smith/Desktop/MAN/manchoice-backend
php artisan tinker --execute="
\$customer = \App\Models\Customer::latest()->first();
echo 'Guarantor Bike Details:' . PHP_EOL;
echo 'Number Plate: ' . \$customer->guarantor_motorcycle_number_plate . PHP_EOL;
echo 'Chassis: ' . \$customer->guarantor_motorcycle_chassis_number . PHP_EOL;
echo 'Model: ' . \$customer->guarantor_motorcycle_model . PHP_EOL;
"
```

---

## 📊 Profile Completion Tracker

The profile completion percentage now tracks **36 total fields**:
- 23 text fields (including 6 new guarantor bike fields)
- 13 photos (including 2 new guarantor bike photos)

---

## 🎯 Important Notes

1. **Guarantor Requirement Note**: The app now displays a prominent blue notice stating:
   > "Note: The guarantor must be a fellow stage member or stage chairman, and must own a motorcycle."

2. **All Fields Required**: All guarantor motorcycle fields are required for form submission

3. **Validation**: Both backend and frontend validate all guarantor motorcycle fields

4. **User Isolation**: Cart data remains isolated per user (from previous security fix)

---

## 🚀 Next Steps

1. Clear the app data (choose one of the options above)
2. Run the app: `flutter run`
3. Test the complete flow with new guarantor motorcycle fields
4. Verify data is saved correctly in the backend

---

**Created:** October 24, 2025  
**Purpose:** Fresh start for testing new guarantor motorcycle fields  
**Status:** ✅ Ready for testing
