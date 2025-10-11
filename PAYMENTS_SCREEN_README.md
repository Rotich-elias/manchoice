# Payments & Installments Screen - Documentation

## 📋 Overview

The **Payments Screen** (`lib/screens/payments_screen.dart`) is a comprehensive loan payment management interface for the MAN'S CHOICE ENTERPRISE Flutter app. It allows customers to track their loan repayments, make M-PESA payments, and manage installments.

**Created:** October 10, 2025
**File Location:** `lib/screens/payments_screen.dart`
**Total Lines:** 1,136 lines of code
**Status:** ✅ Fully implemented and tested

---

## 🎯 Features Implemented

### 1. **Loan Summary Card** (Lines 149-301)
- **Product Name Display:** Shows the motorcycle/product being financed (e.g., "Yamaha YBR 125")
- **Financial Overview:**
  - Total Loan Amount
  - Amount Paid So Far
  - Remaining Balance
  - Daily Payment Amount
- **Next Payment Due:** Date with countdown (e.g., "5 days left")
- **Beautiful Gradient Design:** Blue-grey gradient with icons and proper spacing

### 2. **Visual Progress Bar** (Lines 343-414)
- **Percentage-based Progress:** Shows exact repayment percentage (e.g., 30.0%)
- **Color-coded Bar:** Animated progress indicator
- **Amount Labels:** Shows paid amount vs total loan
- **Responsive Design:** Adapts to different screen sizes

### 3. **M-PESA Payment Section** (Lines 416-602)
- **Step-by-Step Instructions:** 7 clear steps to make payment
- **Paybill Number Display:** Large, prominent paybill (currently placeholder: 123456)
- **Copy-to-Clipboard:** Quick copy button for paybill number
- **Transaction Code Input:**
  - Text field for M-PESA confirmation code
  - Auto-capitalize input
  - 10 character limit
  - Helper text with instructions
- **Confirm Payment Button:**
  - Validates transaction code
  - Simulates payment verification
  - Shows loading dialog
  - Displays success confirmation with receipt option

### 4. **Daily Payment Tracker** (Lines 639-783)
- **Payment History List:** Shows recent payments with:
  - Payment date (formatted: "Oct 09, 2025")
  - Payment amount (formatted currency: "KES 500.00")
  - Status indicators: ✅ **Paid** / ❌ **Missed**
  - Transaction codes for paid items
- **Color-coded Cards:**
  - Green border/icons for paid payments
  - Red border/icons for missed payments
- **View All Button:** Opens full payment history in bottom sheet
- **Expandable History:** Shows 5 recent, tap "View All" for complete list

### 5. **Reminders & Notifications Section** (Lines 785-888)
- **SMS Reminder Status:** Active indicator with checkmark
- **Upcoming Payments List:**
  - Next 3 upcoming payment dates
  - Amount due for each payment
  - Days countdown (e.g., "in 5 days")
  - Orange color scheme for pending payments
- **Notification Settings Button:** Quick access to preferences (placeholder)

---

## 🚀 How to Run the App

### Prerequisites
- Flutter SDK installed
- Android device connected OR emulator running OR Chrome browser

### Quick Start

1. **Navigate to Project Directory:**
   ```bash
   cd /home/smith/Desktop/myproject/manchoice
   ```

2. **Check Available Devices:**
   ```bash
   flutter devices
   ```

3. **Run on Specific Device:**
   ```bash
   # Android Phone
   flutter run -d 27915e84ec217ece

   # Chrome Browser
   flutter run -d chrome

   # Linux Desktop
   flutter run -d linux
   ```

### Current Configuration
The app is configured to **skip directly to the Dashboard** for easier testing.

**File:** `lib/main.dart:22`
```dart
initialRoute: '/dashboard', // Skip directly to dashboard for testing
```

To restore original flow (Splash → Login → Dashboard):
```dart
initialRoute: '/splash', // Original flow
```

---

## 📱 Navigation Guide

### Accessing the Payments Screen

**From Dashboard:**
1. App launches → **Dashboard Screen**
2. Scroll to "Main Menu" section
3. Tap the **green card** labeled:
   > **"My Payments / Installments"**
   > View and manage your payments
4. Payments Screen opens

**Programmatic Navigation:**
```dart
Get.toNamed('/payments');
```

**Route Definition:**
`lib/config/app_routes.dart:20`

---

## 📂 Code Structure

### Main Components

```
PaymentsScreen (StatefulWidget)
├── _PaymentsScreenState
│   ├── Controllers
│   │   └── _transactionCodeController (TextEditingController)
│   │
│   ├── Data (TODO: Replace with API calls)
│   │   ├── productName: String
│   │   ├── totalLoanAmount: double
│   │   ├── amountPaid: double
│   │   ├── nextPaymentDue: DateTime
│   │   ├── dailyPaymentAmount: double
│   │   ├── mpesaPaybill: String
│   │   ├── paymentHistory: List<Map>
│   │   └── upcomingPayments: List<Map>
│   │
│   ├── Widget Methods
│   │   ├── _buildLoanSummaryCard()
│   │   ├── _buildProgressSection()
│   │   ├── _buildMakePaymentSection()
│   │   ├── _buildPaymentTrackerSection()
│   │   ├── _buildRemindersSection()
│   │   ├── _buildPaymentItem()
│   │   ├── _buildUpcomingPaymentItem()
│   │   └── _buildPaymentStep()
│   │
│   └── Action Methods
│       ├── _confirmPayment()
│       ├── _showFullPaymentHistory()
│       ├── _formatCurrency()
│       └── _daysUntil()
```

### Key Files

| File | Purpose |
|------|---------|
| `lib/screens/payments_screen.dart` | Main Payments Screen implementation |
| `lib/config/app_routes.dart` | Route definitions (line 20) |
| `lib/main.dart` | App entry point, initial route configuration |
| `lib/config/app_theme.dart` | Theme and color scheme |
| `lib/config/app_colors.dart` | Color constants |

---

## 🎨 Design Specifications

### Color Scheme
- **Primary:** Blue Grey 700 (#455A64)
- **Secondary:** Blue Grey 500 (#607D8B)
- **Accent:** Cyan (#00BCD4)
- **Success:** Green (Paid payments, M-PESA)
- **Error:** Red (Missed payments)
- **Warning:** Orange (Upcoming payments)

### Typography
- **Font Family:** Roboto (Material Design default)
- **Headings:** Bold, Primary color
- **Body Text:** Regular weight, OnSurface color
- **Labels:** Small, Secondary color with 0.7-0.8 opacity

### Spacing
- **Screen Padding:** 16px horizontal
- **Card Margins:** 16px
- **Card Padding:** 20-24px
- **Section Gaps:** 16-24px
- **Element Spacing:** 8-12px

---

## ⚙️ Sample Data Structure

### Payment History Item
```dart
{
  'date': DateTime,              // Payment date
  'amount': double,              // Payment amount
  'status': 'paid' | 'missed',   // Payment status
  'transactionCode': String?,    // M-PESA code (null if missed)
}
```

### Upcoming Payment Item
```dart
{
  'date': DateTime,              // Due date
  'amount': double,              // Amount due
  'description': String,         // Payment description
}
```

---

## 🔧 Integration Points (TODOs)

### 1. Backend API Integration

**Replace hardcoded data with API calls:**

```dart
// Line 16-22: Loan Details
// TODO: Fetch from API endpoint: GET /api/loans/{loanId}
final String productName;
final double totalLoanAmount;
final double amountPaid;
final DateTime nextPaymentDue;
final double dailyPaymentAmount;
final String mpesaPaybill;  // TODO: Get from settings/config

// Line 24-56: Payment History
// TODO: Fetch from API: GET /api/payments/history
final List<Map<String, dynamic>> paymentHistory;

// Line 58-75: Upcoming Payments
// TODO: Fetch from API: GET /api/payments/upcoming
final List<Map<String, dynamic>> upcomingPayments;
```

### 2. M-PESA Payment Verification

**Line 966: Payment Verification**
```dart
// TODO: Verify payment with backend API
// Endpoint: POST /api/payments/verify
// Body: {
//   "transactionCode": "QAX1B2C3D4",
//   "amount": 500.0,
//   "customerId": "...",
//   "loanId": "..."
// }
```

### 3. Laravel Backend Endpoints Needed

#### Required API Endpoints:

1. **Get Loan Details**
   ```
   GET /api/loans/{loanId}
   Response: {
     "productName": "Yamaha YBR 125",
     "totalAmount": 150000.0,
     "amountPaid": 45000.0,
     "remainingBalance": 105000.0,
     "dailyPayment": 500.0,
     "nextPaymentDue": "2025-10-15"
   }
   ```

2. **Get Payment History**
   ```
   GET /api/payments/history?loanId={loanId}&limit=10
   Response: {
     "payments": [
       {
         "date": "2025-10-09",
         "amount": 500.0,
         "status": "paid",
         "transactionCode": "QAX1B2C3D4"
       },
       ...
     ]
   }
   ```

3. **Get Upcoming Payments**
   ```
   GET /api/payments/upcoming?loanId={loanId}&limit=5
   Response: {
     "upcomingPayments": [
       {
         "dueDate": "2025-10-15",
         "amount": 500.0,
         "description": "Daily installment payment"
       },
       ...
     ]
   }
   ```

4. **Verify Payment**
   ```
   POST /api/payments/verify
   Body: {
     "transactionCode": "QAX1B2C3D4",
     "amount": 500.0,
     "loanId": "123",
     "customerId": "456"
   }
   Response: {
     "success": true,
     "paymentId": "789",
     "message": "Payment verified successfully"
   }
   ```

5. **Get App Configuration**
   ```
   GET /api/config/mpesa
   Response: {
     "paybillNumber": "123456",
     "accountName": "MAN'S CHOICE ENTERPRISE"
   }
   ```

---

## 📊 Testing Checklist

### UI Testing
- [x] Loan summary card displays correctly
- [x] Progress bar shows accurate percentage
- [x] M-PESA section has clear instructions
- [x] Payment history shows with correct status icons
- [x] Reminders section displays upcoming payments
- [x] All cards are responsive
- [x] Dark/Light theme support works

### Functionality Testing
- [x] Transaction code input validation works
- [x] Copy paybill button copies to clipboard
- [x] Confirm payment shows loading and success dialogs
- [x] View All button opens full payment history
- [x] Currency formatting displays correctly
- [x] Date formatting is consistent
- [ ] API integration (pending backend)
- [ ] Real payment verification (pending M-PESA)

### Device Testing
- [x] Android phone (SM N9600) - Tested ✅
- [ ] iOS device
- [ ] Web browser
- [ ] Tablet layout

---

## 🐛 Known Issues & Limitations

1. **Mock Data:** Currently uses hardcoded sample data
2. **No Real M-PESA Integration:** Payment verification is simulated
3. **No SMS Sending:** Reminder system is placeholder
4. **No Receipt Generation:** Download receipt button shows placeholder
5. **No Filter Functionality:** Payment history filter not implemented

---

## 🔐 Security Considerations

### Before Production:
1. **Validate Transaction Codes:** Server-side validation required
2. **Secure API Calls:** Use HTTPS and authentication tokens
3. **Input Sanitization:** Validate all user inputs
4. **Rate Limiting:** Prevent payment verification spam
5. **Error Handling:** Don't expose sensitive error details

---

## 📈 Future Enhancements

### Planned Features:
- [ ] Payment receipt generation (PDF)
- [ ] Payment history filtering (date range, status)
- [ ] Export payment statement
- [ ] Multiple payment methods (Card, Bank)
- [ ] Payment reminders via push notifications
- [ ] Automatic M-PESA STK Push
- [ ] Payment analytics and charts
- [ ] Loan repayment calculator
- [ ] Early payment incentives display
- [ ] Payment proof upload

---

## 📞 Support & Maintenance

### For Issues:
- Review code comments (marked with `// TODO:`)
- Check Flutter console for errors
- Run `flutter analyze` for code quality
- Use `flutter doctor` for environment issues

### Code Quality:
- ✅ No analysis errors
- ✅ Follows Material Design 3 guidelines
- ✅ Proper null safety handling
- ✅ Context mounted checks for async operations
- ✅ Clean code structure with reusable widgets

---

## 📝 Changelog

### Version 1.0.0 (2025-10-10)
- ✅ Initial implementation of Payments Screen
- ✅ Loan summary card with product details
- ✅ Visual progress bar for repayment tracking
- ✅ M-PESA payment integration (UI)
- ✅ Payment history with status indicators
- ✅ Reminders and upcoming payments section
- ✅ Full payment history bottom sheet
- ✅ Transaction code verification flow
- ✅ Currency and date formatting utilities
- ✅ Dark/Light theme support
- ✅ Responsive design for mobile devices

---

## 🤝 Contributing

When making changes:
1. Follow existing code structure and naming conventions
2. Add comments for complex logic
3. Update this README if adding new features
4. Test on multiple devices before committing
5. Run `flutter analyze` to ensure code quality

---

## 📄 License

Part of the MAN'S CHOICE ENTERPRISE Credit Management System
© 2025 MAN'S CHOICE ENTERPRISE

---

## 🎓 Quick Reference

### Important Line Numbers:
- Loan Summary Card: Lines 149-301
- Progress Section: Lines 343-414
- M-PESA Payment: Lines 416-602
- Payment Tracker: Lines 639-783
- Reminders Section: Lines 785-888
- Payment Verification: Lines 952-1046

### Key Methods:
- `_confirmPayment()` - Line 952
- `_formatCurrency()` - Line 1124
- `_daysUntil()` - Line 1131

### Sample Data:
- Payment History: Lines 25-56
- Upcoming Payments: Lines 59-75

---

**Created with ❤️ using Flutter & Claude Code**

For questions or support, contact the development team.
