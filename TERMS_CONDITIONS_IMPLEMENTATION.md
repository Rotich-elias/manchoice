# Terms & Conditions Implementation

## Overview
Added comprehensive Terms & Conditions to the Man's Choice Enterprise mobile app, outlining membership requirements and policies for boda boda operators.

---

## Implementation Details

### 1. Terms & Conditions Screen Created ✅
**File:** `lib/screens/terms_conditions_screen.dart`

**Features:**
- Beautiful, scrollable UI with icons and color coding
- Two main sections:
  1. **Membership Requirements** (6 requirements)
  2. **Policy & Regulations** (5 policies)
- Important notice section
- Contact information
- Optional "Accept" button for registration flow

### 2. Membership Requirements Displayed

#### Requirement 1: National Identity
- Must be a holder of national ID
- Must provide copy of original document

#### Requirement 2: Legal Ownership
- Must be legal owner of motorcycle
- Names in log book must match ID

#### Requirement 3: Boda Boda Stage Member
- Must be recognized member of boda boda stage
- Must be acknowledged by stage chairperson

#### Requirement 4: Full-time Operator
- Boda boda operation must be primary occupation

#### Requirement 5: Registration Fee
- Ksh 300/- registration fee required
- First customers: 10% deposit of first product

#### Requirement 6: Guarantors
- **TWO guarantors required:**
  - One work mate from working stage
  - One Next of Kin (or optional additional)

### 3. Policy & Regulations Displayed

#### Policy 1: Minimum Payment
- Must pay NOT LESS than Ksh 200/- per agreement

#### Policy 2: Payment Timeline
- Must pay within given duration (e.g., 3 weeks)
- **Late payment:** 1% interest daily from due date
- Maximum penalty period: 2 weeks

#### Policy 3: Guarantor Liability
- Guarantor and Next of Kin liable if customer fails to pay
- Timeline: 2 weeks

#### Policy 4: Legal Action
- If all parties fail to pay:
  - Stage chairperson contacted
  - File forwarded to legal team
  - Recovery team action initiated

#### Policy 5: Security Requirement
- **Motorcycle log book acts as security**

---

## Integration Points

### 1. Profile Screen ✅
**File:** `lib/screens/profile_screen.dart`

Added link in "Account Settings" section:
```dart
ListTile(
  leading: Icon(Icons.description, color: Colors.blue),
  title: Text('Terms & Conditions'),
  onTap: () => Get.toNamed('/terms-conditions'),
)
```

### 2. Support Screen ✅
**File:** `lib/screens/support_screen.dart`

Added link in "Quick Actions" section:
```dart
ListTile(
  leading: Icon(Icons.description, color: Colors.blue),
  title: Text('Terms & Conditions'),
  subtitle: Text('View our terms and policies'),
  onTap: () => Get.toNamed('/terms-conditions'),
)
```

### 3. App Routes ✅
**File:** `lib/config/app_routes.dart`

Added route:
```dart
GetPage(
  name: '/terms-conditions',
  page: () => const TermsConditionsScreen()
)
```

---

## User Access Points

Users can access Terms & Conditions from:

1. **Profile Screen**
   - Navigate to Profile
   - Tap "Account Settings"
   - Tap "Terms & Conditions"

2. **Support Screen**
   - Navigate to Support
   - Tap "Quick Actions"
   - Tap "Terms & Conditions"

3. **Direct Navigation**
   - Any screen can navigate using: `Get.toNamed('/terms-conditions')`

---

## Visual Design

### Color Coding
- **Requirements Section:** Blue header with colorful requirement cards
  - Each requirement has unique color and icon
  - Clear numbering (1-6)

- **Policy Section:** Colored cards matching severity
  - Orange/Red for important policies
  - Bold warning icons

### Important Notice
- Red-bordered alert box
- Clear warning about compliance
- Legal action consequences

### Contact Information
- Blue info box at bottom
- Phone: +254 011 0846 828
- Email: manschoiceenterprise@gmail.com

---

## Future Enhancements (Optional)

### 1. Registration Flow Integration
Add T&C acceptance during signup:

```dart
// In signup_screen.dart
CheckboxListTile(
  title: Text('I accept the Terms & Conditions'),
  subtitle: TextButton(
    child: Text('Read Terms'),
    onPressed: () async {
      final accepted = await Get.toNamed('/terms-conditions',
        arguments: {'showAcceptButton': true}
      );
      if (accepted == true) {
        setState(() => _acceptedTC = true);
      }
    },
  ),
  value: _acceptedTC,
  onChanged: (value) {
    setState(() => _acceptedTC = value ?? false);
  },
)
```

### 2. Backend Storage
Add to customers table:

```sql
ALTER TABLE customers
ADD COLUMN accepted_terms BOOLEAN DEFAULT FALSE,
ADD COLUMN accepted_terms_at TIMESTAMP NULL;
```

### 3. Version Tracking
Track T&C versions:

```sql
CREATE TABLE terms_acceptances (
  id BIGINT PRIMARY KEY,
  customer_id BIGINT,
  version VARCHAR(20),
  accepted_at TIMESTAMP,
  ip_address VARCHAR(45)
);
```

---

## Testing Checklist

- [x] Terms & Conditions screen displays correctly
- [x] All 6 requirements shown with proper formatting
- [x] All 5 policies shown with proper formatting
- [x] Important notice displayed prominently
- [x] Contact information visible
- [x] Navigation from Profile works
- [x] Navigation from Support works
- [x] Scrolling works smoothly
- [x] Colors and icons display correctly
- [x] Text is readable and properly formatted

---

## Files Created/Modified

### New Files
1. `lib/screens/terms_conditions_screen.dart` - Main T&C screen
2. `TERMS_CONDITIONS_IMPLEMENTATION.md` - This documentation

### Modified Files
1. `lib/config/app_routes.dart` - Added route
2. `lib/screens/profile_screen.dart` - Added T&C link
3. `lib/screens/support_screen.dart` - Added T&C link

---

## Content Summary

### Membership Requirements (6)
1. National ID holder with original copy
2. Legal motorcycle owner (matching log book)
3. Boda boda stage member (chairperson recognized)
4. Full-time boda boda operator
5. Ksh 300 registration fee (10% deposit for first product)
6. Two guarantors (work mate + next of kin)

### Policies (5)
1. Minimum Ksh 200 payment requirement
2. Payment timeline with 1% daily penalty (max 2 weeks)
3. Guarantor liability within 2 weeks
4. Legal action through recovery team
5. Log book as security

### Key Messages
- **Compliance Required:** All terms must be followed
- **Legal Consequences:** Non-payment leads to legal action
- **Security:** Log book required
- **Support Available:** Contact information provided

---

## Screenshots Locations

When testing, verify these screens:
1. Terms & Conditions main screen
2. Profile > Terms & Conditions link
3. Support > Terms & Conditions link

---

## Deployment Notes

### For Development
1. Screen is ready to use
2. No backend changes required immediately
3. Can add T&C acceptance checkbox later if needed

### For Production
1. Review all text for accuracy
2. Confirm legal compliance
3. Consider adding version number
4. Consider forcing acceptance on first login
5. Consider storing acceptance in database

---

## Support

**For Questions:**
- Phone: +254 011 0846 828
- Email: manschoiceenterprise@gmail.com

**For Issues:**
- Check route configuration in `app_routes.dart`
- Verify import in profile and support screens
- Check navigation syntax: `Get.toNamed('/terms-conditions')`

---

**Date Implemented:** 2025-10-28
**Status:** ✅ COMPLETE - Ready for use
**Version:** 1.0
