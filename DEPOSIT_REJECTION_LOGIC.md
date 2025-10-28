# Deposit Payment Rejection Logic - Implementation Guide

## Overview
This document outlines the comprehensive deposit payment rejection logic implementation for both mobile app (Flutter) and backend (Laravel) sides.

---

## Mobile App Changes (COMPLETED)

### 1. Enhanced Deposit Model
**File:** `lib/models/deposit.dart`

Added new fields:
- `rejectionReason` (String?) - Detailed reason for rejection
- `rejectedAt` (DateTime?) - Timestamp when rejected
- `rejectedBy` (int?) - Admin ID who rejected
- `rejectionCount` (int) - Total number of rejections
- `rejector` (User?) - Admin user who rejected

New helper methods:
- `isRejected` - Check if deposit is rejected
- `hasReachedRejectionLimit` - Check if 3+ rejections
- `canRetry` - Check if retry is allowed

### 2. Enhanced Deposit Repository
**File:** `lib/services/deposit_repository.dart`

New methods:
- `getRejectionHistory(loanId)` - Get all rejected deposits for a loan
- `getRejectionCount(loanId)` - Get total rejection count
- `hasReachedRejectionLimit(loanId)` - Check if limit reached (3 rejections)
- `getDepositStatusWithRejectionInfo(loanId)` - Get status with rejection details

### 3. Enhanced Deposit Status Screen
**File:** `lib/screens/deposit_status_screen.dart`

New features:
- Shows rejection history (up to 3 most recent)
- Displays rejection count with remaining attempts
- Shows warning when approaching limit
- Disables retry button after 3 rejections
- Prominent "Contact Support" button when limit reached
- "Dispute This Rejection" button for rejected payments

### 4. Deposit Notification Service (NEW)
**File:** `lib/services/deposit_notification_service.dart`

Notification methods:
- `showRejectionNotification()` - Alert when deposit rejected
- `showRejectionLimitWarning()` - Warn about remaining attempts
- `showVerificationSuccessNotification()` - Success message
- `showPendingVerificationReminder()` - Pending reminder
- `showRejectionLimitDialog()` - Dialog when limit reached

### 5. Support Ticket Integration
**File:** `lib/services/support_ticket_repository.dart`

New methods:
- `submitDepositRejectionDispute()` - Create dispute ticket
- `submitRejectionLimitSupport()` - Request help when limit reached

---

## Backend Implementation Required (Laravel)

### 1. Database Migration

**Add to `deposits` table:**

```sql
ALTER TABLE deposits ADD COLUMN rejection_reason TEXT NULL;
ALTER TABLE deposits ADD COLUMN rejected_at TIMESTAMP NULL;
ALTER TABLE deposits ADD COLUMN rejected_by INT NULL;
ALTER TABLE deposits ADD COLUMN rejection_count INT DEFAULT 0;
ALTER TABLE deposits ADD INDEX idx_rejected_by (rejected_by);
```

**Migration file example:**
```php
Schema::table('deposits', function (Blueprint $table) {
    $table->text('rejection_reason')->nullable()->after('notes');
    $table->timestamp('rejected_at')->nullable()->after('rejection_reason');
    $table->unsignedBigInteger('rejected_by')->nullable()->after('rejected_at');
    $table->integer('rejection_count')->default(0)->after('rejected_by');

    $table->foreign('rejected_by')->references('id')->on('users');
    $table->index('rejected_by', 'idx_rejected_by');
});
```

### 2. Update Deposit Model

**File:** `app/Models/Deposit.php`

```php
class Deposit extends Model
{
    protected $fillable = [
        // ... existing fields
        'rejection_reason',
        'rejected_at',
        'rejected_by',
        'rejection_count',
    ];

    protected $casts = [
        // ... existing casts
        'rejected_at' => 'datetime',
    ];

    // Relationship to admin who rejected
    public function rejector()
    {
        return $this->belongsTo(User::class, 'rejected_by');
    }

    // Check if rejection limit reached
    public function hasReachedRejectionLimit()
    {
        return $this->rejection_count >= 3;
    }

    // Check if can be retried
    public function canRetry()
    {
        return ($this->status === 'rejected' || $this->status === 'failed')
            && !$this->hasReachedRejectionLimit();
    }
}
```

### 3. Update API Responses

**Include rejection fields in all deposit responses:**

```php
// In DepositResource.php or controller responses
public function toArray($request)
{
    return [
        'id' => $this->id,
        // ... existing fields
        'rejection_reason' => $this->rejection_reason,
        'rejected_at' => $this->rejected_at,
        'rejected_by' => $this->rejected_by,
        'rejection_count' => $this->rejection_count,
        'rejector' => $this->rejector ? [
            'id' => $this->rejector->id,
            'name' => $this->rejector->name,
        ] : null,
    ];
}
```

### 4. Admin Rejection Logic

**When admin rejects a deposit:**

```php
public function rejectDeposit(Request $request, $depositId)
{
    $request->validate([
        'rejection_reason' => 'required|string|min:10',
    ]);

    $deposit = Deposit::findOrFail($depositId);
    $loan = $deposit->loan;

    // Calculate rejection count for this loan
    $totalRejections = Deposit::where('loan_id', $loan->id)
        ->whereIn('status', ['rejected', 'failed'])
        ->count();

    // Update deposit status
    $deposit->update([
        'status' => 'rejected',
        'rejection_reason' => $request->rejection_reason,
        'rejected_at' => now(),
        'rejected_by' => auth()->id(),
        'rejection_count' => $totalRejections + 1,
    ]);

    // Keep loan in pending_deposit status
    $loan->update(['status' => 'pending_deposit']);

    // Send notification to customer
    $this->sendRejectionNotification($deposit, $loan);

    // If reached limit, notify admins
    if ($deposit->rejection_count >= 3) {
        $this->notifyAdminsAboutRejectionLimit($deposit, $loan);
    }

    return response()->json([
        'success' => true,
        'message' => 'Deposit rejected successfully',
        'data' => [
            'deposit' => $deposit->fresh(['rejector']),
            'rejection_count' => $deposit->rejection_count,
            'has_reached_limit' => $deposit->hasReachedRejectionLimit(),
        ],
    ]);
}
```

### 5. New API Endpoints

**Add these routes:**

```php
// Get rejection history for a loan
GET /api/loans/{loanId}/deposits/rejected

// Get deposit status with rejection info
GET /api/loans/{loanId}/deposit/status (update existing endpoint)
```

**Controller implementation:**

```php
// Get all rejected deposits for a loan
public function getRejectionHistory($loanId)
{
    $loan = Loan::findOrFail($loanId);

    $rejectedDeposits = Deposit::where('loan_id', $loanId)
        ->whereIn('status', ['rejected', 'failed'])
        ->with('rejector')
        ->orderBy('rejected_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $rejectedDeposits,
    ]);
}

// Update getDepositStatus to include rejection info
public function getDepositStatus($loanId)
{
    // ... existing code

    $rejectionCount = Deposit::where('loan_id', $loanId)
        ->whereIn('status', ['rejected', 'failed'])
        ->count();

    return response()->json([
        'success' => true,
        'data' => [
            // ... existing fields
            'rejection_count' => $rejectionCount,
            'has_reached_rejection_limit' => $rejectionCount >= 3,
            'can_retry' => $rejectionCount < 3,
        ],
    ]);
}
```

### 6. Notification System

**Send push notifications when:**

1. **Deposit Rejected:**
```php
private function sendRejectionNotification($deposit, $loan)
{
    $customer = $loan->customer;

    // Push notification
    $customer->notify(new DepositRejectedNotification($deposit, $loan));

    // Optional: SMS notification
    // SMS::send($customer->phone, "Your deposit payment was rejected: " . $deposit->rejection_reason);
}
```

2. **Rejection Limit Reached:**
```php
private function notifyAdminsAboutRejectionLimit($deposit, $loan)
{
    $admins = User::where('role', 'admin')->get();

    foreach ($admins as $admin) {
        $admin->notify(new RejectionLimitReachedNotification($deposit, $loan));
    }
}
```

### 7. Business Rules Implementation

**Rejection Validation:**
- Minimum 10 characters for rejection reason
- Must be an admin to reject
- Cannot reject already completed deposits
- Cannot reject same deposit twice

**Retry Logic:**
- Customer can retry up to 3 times
- After 3 rejections, must contact support
- Each new submission creates a NEW deposit record
- Old rejected deposits kept for audit trail

**Prevention Logic:**
```php
public function canSubmitNewDeposit($loanId)
{
    $rejectionCount = Deposit::where('loan_id', $loanId)
        ->whereIn('status', ['rejected', 'failed'])
        ->count();

    if ($rejectionCount >= 3) {
        return [
            'allowed' => false,
            'message' => 'Rejection limit reached. Please contact support.',
            'rejection_count' => $rejectionCount,
        ];
    }

    return [
        'allowed' => true,
        'rejection_count' => $rejectionCount,
        'remaining_attempts' => 3 - $rejectionCount,
    ];
}
```

---

## User Flow

### Normal Rejection Flow (< 3 rejections)

1. Customer submits deposit payment
2. Admin reviews and rejects (with reason)
3. Customer receives notification
4. Customer can:
   - View rejection reason
   - See rejection history
   - Retry payment immediately
   - Dispute the rejection
5. Customer submits new payment

### Rejection Limit Reached Flow (3+ rejections)

1. Customer's 3rd payment is rejected
2. System disables retry button
3. Customer sees rejection limit warning
4. Customer must:
   - Contact support team
   - Submit support ticket
   - Wait for admin assistance
5. Admin manually reviews and assists

---

## Support Ticket Types

**New ticket types to handle:**

1. `deposit_dispute` - Customer disputes rejection
   - Priority: HIGH
   - Auto-includes: loan ID, deposit ID, rejection reason

2. `rejection_limit` - Rejection limit reached
   - Priority: HIGH
   - Auto-includes: loan ID, rejection count

---

## Testing Checklist

### Backend Testing

- [ ] Deposit rejection creates proper database records
- [ ] Rejection count increments correctly
- [ ] API returns all rejection fields
- [ ] Rejection history endpoint works
- [ ] Notifications sent on rejection
- [ ] Cannot retry after 3 rejections
- [ ] Support tickets created successfully

### Mobile App Testing

- [ ] Rejection notification displays
- [ ] Rejection history shows correctly
- [ ] Retry button disabled after 3 rejections
- [ ] Dispute button works
- [ ] Contact support button works
- [ ] Rejection count displays accurately
- [ ] Warning messages appear at right times

---

## Security Considerations

1. **Authorization:**
   - Only admins can reject deposits
   - Customers can only view their own rejections
   - Rejection reason required and validated

2. **Audit Trail:**
   - Track who rejected (rejected_by)
   - Track when rejected (rejected_at)
   - Keep all rejected deposits in database
   - Never delete rejected deposits

3. **Abuse Prevention:**
   - Limit to 3 rejection attempts
   - Require support contact after limit
   - Log all rejection activities
   - Monitor repeated rejections

---

## Performance Considerations

1. **Database:**
   - Index on `rejected_by` for admin lookups
   - Index on `loan_id` + `status` for rejection counts
   - Consider archiving very old rejected deposits

2. **API:**
   - Cache rejection counts (5 minute TTL)
   - Paginate rejection history if > 10 records
   - Eager load relationships (rejector, loan)

---

## Future Enhancements (Optional)

1. **Analytics Dashboard:**
   - Track rejection rates by admin
   - Common rejection reasons
   - Average time to resolve disputes

2. **Automated Detection:**
   - Flag suspicious M-PESA codes
   - Detect duplicate transaction IDs
   - Auto-verify with M-PESA API

3. **Customer Education:**
   - Tips for avoiding rejections
   - Common mistakes to avoid
   - How to verify M-PESA codes

---

## Summary

This implementation provides:
- ✅ Complete rejection tracking
- ✅ User-friendly rejection history
- ✅ Automatic retry limit enforcement
- ✅ Integrated support ticket system
- ✅ Comprehensive notifications
- ✅ Audit trail for compliance
- ✅ Dispute resolution workflow

**Next Steps:**
1. Backend team implements database changes
2. Backend team adds API endpoints
3. Test rejection flow end-to-end
4. Deploy to staging for QA testing
5. Monitor rejection metrics in production
