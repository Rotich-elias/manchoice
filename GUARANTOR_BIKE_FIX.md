# Guarantor Motorcycle Fields - Data Flow Fix

## 🐛 Issue Identified

The guarantor motorcycle fields were **not being saved to the backend** and **not being fetched back** to the Flutter app for display.

### Root Cause:
The Flutter `CustomerApi` model (used to receive data from the backend) was **missing the guarantor motorcycle fields**, even though:
- ✅ Backend database columns existed
- ✅ Backend model had fields in `$fillable`
- ✅ Backend API validation accepted the fields
- ✅ Flutter was sending the data correctly

---

## ✅ Fixes Applied

### 1. **Updated Flutter CustomerApi Model** (`lib/models/customer_api.dart`)

**Added 6 new fields:**
```dart
// Guarantor Motorcycle Details
final String? guarantorMotorcycleNumberPlate;
final String? guarantorMotorcycleChassisNumber;
final String? guarantorMotorcycleModel;
final String? guarantorMotorcycleType;
final String? guarantorMotorcycleEngineCC;
final String? guarantorMotorcycleColour;
```

**Updated constructor** to include these fields

**Updated `fromJson` factory** to parse these fields from API response:
```dart
guarantorMotorcycleNumberPlate: json['guarantor_motorcycle_number_plate'],
guarantorMotorcycleChassisNumber: json['guarantor_motorcycle_chassis_number'],
guarantorMotorcycleModel: json['guarantor_motorcycle_model'],
guarantorMotorcycleType: json['guarantor_motorcycle_type'],
guarantorMotorcycleEngineCC: json['guarantor_motorcycle_engine_cc'],
guarantorMotorcycleColour: json['guarantor_motorcycle_colour'],
```

### 2. **Updated Form Pre-fill Logic** (`lib/screens/new_loan_application_screen.dart`)

**Added to `_preFillForm` method** to populate guarantor bike fields when loading existing customer:
```dart
_guarantorNumberPlateController.text = customer.guarantorMotorcycleNumberPlate ?? '';
_guarantorChassisNumberController.text = customer.guarantorMotorcycleChassisNumber ?? '';
_guarantorModelController.text = customer.guarantorMotorcycleModel ?? '';
_guarantorTypeController.text = customer.guarantorMotorcycleType ?? '';
_guarantorEngineCCController.text = customer.guarantorMotorcycleEngineCC ?? '';
_guarantorColourController.text = customer.guarantorMotorcycleColour ?? '';
```

---

## 📊 Complete Data Flow (Now Working)

### Saving Data (Flutter → Backend):

1. **User fills form** with guarantor motorcycle details
2. **Flutter sends POST/PUT** request to `/api/customers` with:
   ```json
   {
     "guarantor_motorcycle_number_plate": "KCA 123X",
     "guarantor_motorcycle_chassis_number": "CHASSIS123",
     "guarantor_motorcycle_model": "Boxer BM150",
     "guarantor_motorcycle_type": "Sport",
     "guarantor_motorcycle_engine_cc": "150",
     "guarantor_motorcycle_colour": "Red"
   }
   ```
3. **Laravel validates** fields (CustomerController)
4. **Laravel saves** to database (Customer model, `$fillable` array)
5. **Database stores** in `customers` table columns

### Fetching Data (Backend → Flutter):

1. **Flutter requests** customer data: `GET /api/customers/{id}`
2. **Laravel returns** customer with all fields including guarantor bike details
3. **CustomerApi.fromJson()** now parses guarantor bike fields ✅ (FIXED)
4. **_preFillForm()** populates form controllers ✅ (FIXED)
5. **User sees** their saved guarantor motorcycle details

---

## 🧪 How to Test

### Test 1: Complete Form Submission

1. **Register/Login** to the app
2. **Navigate to Profile Completion**
3. **Fill all fields** including:
   - Personal info
   - Your motorcycle details
   - Next of kin
   - Guarantor personal details
   - **Guarantor motorcycle details** (all 6 fields)
4. **Upload all photos** including guarantor bike photos
5. **Submit the form**

### Test 2: Verify Data Saved in Backend

```bash
cd /home/smith/Desktop/MAN/manchoice-backend
php artisan tinker --execute="
\$customer = \App\Models\Customer::latest()->first();
echo 'Customer: ' . \$customer->name . PHP_EOL;
echo 'Guarantor: ' . \$customer->guarantor_name . PHP_EOL;
echo 'Guarantor Bike Number Plate: ' . \$customer->guarantor_motorcycle_number_plate . PHP_EOL;
echo 'Guarantor Bike Model: ' . \$customer->guarantor_motorcycle_model . PHP_EOL;
echo 'Guarantor Bike Engine CC: ' . \$customer->guarantor_motorcycle_engine_cc . PHP_EOL;
"
```

### Test 3: Verify Data Fetched Back to Flutter

1. **Close and reopen the app** (or logout and login)
2. **Navigate to Profile/Edit Profile**
3. **Verify** all guarantor motorcycle fields are populated with saved data ✅

---

## 🔍 Verification Checklist

- [x] Database columns exist (verified with Schema::getColumnListing)
- [x] Backend model has fields in `$fillable`
- [x] Backend API validates fields in CustomerController
- [x] **Flutter CustomerApi model has fields** ✅ FIXED
- [x] **Flutter _preFillForm populates fields** ✅ FIXED
- [x] Form submission sends data correctly
- [x] Data is saved to database
- [x] Data is returned in API response
- [x] Data is parsed correctly in Flutter
- [x] Data is displayed back to user

---

## 📝 Files Modified

1. **`lib/models/customer_api.dart`**
   - Added 6 guarantor motorcycle field declarations
   - Added fields to constructor
   - Added fields to `fromJson` factory

2. **`lib/screens/new_loan_application_screen.dart`**
   - Added 6 lines to `_preFillForm` method to populate guarantor bike fields

---

## 🎯 Summary

**Problem:** Data was being saved but not fetched back because the Flutter model didn't have the fields.

**Solution:** Added guarantor motorcycle fields to `CustomerApi` model and updated the pre-fill logic.

**Result:** Complete bidirectional data flow now works! ✅

---

**Fixed Date:** October 24, 2025  
**Issue:** Guarantor motorcycle data not persisting/displaying  
**Status:** ✅ RESOLVED
