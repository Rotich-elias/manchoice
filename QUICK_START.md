# Payments Screen - Quick Start Guide

## 🚀 Running the App

```bash
cd /home/smith/Desktop/myproject/manchoice

# Android Phone
flutter run -d 27915e84ec217ece

# Chrome Browser
flutter run -d chrome

# Any available device
flutter run
```

## 📱 Accessing Payments Screen

1. App opens → **Dashboard**
2. Tap green card: **"My Payments / Installments"**
3. Payments screen opens!

## 📄 Files Created

- **Main Screen:** `lib/screens/payments_screen.dart` (1,136 lines)
- **Documentation:** `PAYMENTS_SCREEN_README.md` (full guide)
- **Quick Guide:** `QUICK_START.md` (this file)

## ✅ Features Completed

- ✅ Loan Summary Card (product, amounts, due date)
- ✅ Progress Bar (30% visual indicator)
- ✅ M-PESA Payment (Paybill: 123456, transaction input)
- ✅ Payment History (✅ Paid / ❌ Missed)
- ✅ Reminders & Upcoming Payments

## 📋 TODO: Connect to Backend

### Update These Lines:

**Line 16-22:** Replace hardcoded loan data
```dart
// TODO: Fetch from API: GET /api/loans/{loanId}
```

**Line 24-56:** Replace payment history
```dart
// TODO: Fetch from API: GET /api/payments/history
```

**Line 58-75:** Replace upcoming payments
```dart
// TODO: Fetch from API: GET /api/payments/upcoming
```

**Line 966:** Add payment verification
```dart
// TODO: POST /api/payments/verify
```

**Line 22:** Update M-PESA Paybill
```dart
final String mpesaPaybill = "123456"; // Change to real number
```

## 🔥 Hot Reload Commands

While app is running:
- **r** = Hot reload (fast)
- **R** = Hot restart (full restart)
- **q** = Quit app

## 🎯 API Endpoints Needed

1. `GET /api/loans/{loanId}` - Loan details
2. `GET /api/payments/history` - Payment history
3. `GET /api/payments/upcoming` - Upcoming payments
4. `POST /api/payments/verify` - Verify M-PESA payment
5. `GET /api/config/mpesa` - Get paybill number

## 📞 Need Help?

See full documentation: **PAYMENTS_SCREEN_README.md**

---

**Happy Coding! 🎉**
