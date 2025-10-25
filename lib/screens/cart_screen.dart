import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/loan_item.dart';
import '../services/cart_service.dart';
import '../services/customer_repository.dart';
import '../services/loan_repository.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartService cartService = Get.find<CartService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        centerTitle: true,
        actions: [
          Obx(
            () => cartService.itemCount > 0
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _showClearCartDialog(context, cartService),
                    tooltip: 'Clear Cart',
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (cartService.items.isEmpty) {
          return _buildEmptyCart(context);
        }

        return Column(
          children: [
            // Profile Completed Banner
            if (cartService.customerId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Profile completed! Add items and checkout to create your loan.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // No Profile Completed Banner (if no customer ID)
            if (cartService.customerId == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.orange.shade50,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Complete your profile to checkout these items',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(
                          '/new-loan-application',
                          arguments: {'fromCart': true},
                        );
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Complete Profile Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ],
                ),
              ),

            // Cart Items List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cartService.items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = cartService.items[index];
                  return _buildCartItem(context, item, cartService);
                },
              ),
            ),

            // Price Summary
            _buildPriceSummary(context, cartService),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Cart is Empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add products to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Browse Products'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    CartService cartService,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.build_circle_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'KES ${item.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls & Remove
            Column(
              children: [
                // Remove Button
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => cartService.removeItem(item.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.red,
                ),
                const SizedBox(height: 12),

                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: () => cartService.decrementQuantity(item.id),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => cartService.incrementQuantity(item.id),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Item Total
                Text(
                  'KES ${item.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(BuildContext context, CartService cartService) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subtotal
              _buildPriceRow('Subtotal', cartService.subtotal, isRegular: true),
              const SizedBox(height: 8),

              // Interest
              _buildPriceRow(
                'Interest (${(cartService.interestRate * 100).toStringAsFixed(0)}%)',
                cartService.interestAmount,
                isRegular: true,
                color: Colors.orange,
              ),
              const Divider(height: 24),

              // Total
              _buildPriceRow('Total', cartService.total, isRegular: false),
              const SizedBox(height: 16),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: cartService.customerId != null
                      ? () => _handleCheckout(context, cartService)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    cartService.customerId != null
                        ? 'Proceed to Checkout'
                        : 'Complete Profile First',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    required bool isRegular,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isRegular ? 14 : 18,
            fontWeight: isRegular ? FontWeight.w500 : FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          'KES ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: isRegular ? 14 : 18,
            fontWeight: isRegular ? FontWeight.w600 : FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, CartService cartService) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              cartService.clearCart();
              Get.back();
              Get.snackbar(
                'Cart Cleared',
                'All items have been removed from your cart',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckout(
    BuildContext context,
    CartService cartService,
  ) async {
    if (cartService.customerId == null) {
      Get.snackbar(
        'Profile Incomplete',
        'Please complete your profile first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Show loading dialog while checking credit limit
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Fetch customer profile to check credit limit
      final customerRepo = CustomerRepository();
      final customer = await customerRepo.getMyProfile();

      // Close loading dialog
      Get.back();

      if (customer == null) {
        Get.snackbar(
          'Error',
          'Unable to fetch your profile. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Check customer status
      if (customer.status == 'blacklisted') {
        Get.snackbar(
          'Account Restricted',
          'Your account has been blacklisted. Please contact admin.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      if (customer.status == 'inactive') {
        Get.snackbar(
          'Account Inactive',
          'Your account is inactive. Please contact admin.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      // Check credit limit (only if credit_limit > 0)
      if (customer.creditLimit > 0) {
        final outstandingBalance = customer.outstandingBalance;
        final availableCredit = customer.creditLimit - outstandingBalance;
        final cartTotal = cartService.total;

        if (cartTotal > availableCredit) {
          Get.dialog(
            AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 28),
                  SizedBox(width: 12),
                  Text('Credit Limit Exceeded'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your cart total exceeds your available credit limit.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  _buildCreditInfoRow(
                    'Credit Limit:',
                    'KSh ${customer.creditLimit.toStringAsFixed(2)}',
                  ),
                  _buildCreditInfoRow(
                    'Outstanding Balance:',
                    'KSh ${outstandingBalance.toStringAsFixed(2)}',
                  ),
                  _buildCreditInfoRow(
                    'Available Credit:',
                    'KSh ${availableCredit.toStringAsFixed(2)}',
                    highlight: true,
                  ),
                  const Divider(height: 24),
                  _buildCreditInfoRow(
                    'Cart Total:',
                    'KSh ${cartTotal.toStringAsFixed(2)}',
                    error: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please reduce your cart total by KSh ${(cartTotal - availableCredit).toStringAsFixed(2)} or pay off existing loans.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to verify credit limit: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // If all checks pass, show checkout confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary:'),
            const SizedBox(height: 12),
            Text('Items: ${cartService.itemCount}'),
            Text('Subtotal: KES ${cartService.subtotal.toStringAsFixed(0)}'),
            Text(
              'Interest: KES ${cartService.interestAmount.toStringAsFixed(0)}',
            ),
            const Divider(height: 20),
            Text(
              'Total: KES ${cartService.total.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'A loan application will be created with these products and submitted to admin for approval.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => _confirmCheckout(cartService),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCheckout(CartService cartService) async {
    try {
      Get.back(); // Close dialog

      // Show loading indicator
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Creating loan application...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Create loan with cart total and documents
      final loanRepo = LoanRepository();

      // Convert cart items to loan items
      final loanItems = cartService.items
          .map(
            (item) => LoanItemRequest(
              productId: int.parse(item.id),
              quantity: item.quantity,
            ),
          )
          .toList();

      final loan = await loanRepo.createLoan(
        customerId: cartService.customerId!,
        principalAmount: cartService
            .subtotal, // Send subtotal as principal, backend will add interest
        interestRate: cartService.interestRate * 100, // Convert to percentage
        durationDays: 30,
        purpose: 'Purchase of motorcycle parts and accessories',
        notes:
            'Products: ${cartService.items.map((item) => '${item.name} (x${item.quantity})').join(', ')}',
        items: loanItems,
        bikePhotoPath: cartService.bikePhotoPath,
        logbookPhotoPath: cartService.logbookPhotoPath,
        passportPhotoPath: cartService.passportPhotoPath,
        idPhotoFrontPath: cartService.idPhotoFrontPath,
        idPhotoBackPath: cartService.idPhotoBackPath,
        nextOfKinIdFrontPath: cartService.kinIdPhotoFrontPath,
        nextOfKinIdBackPath: cartService.kinIdPhotoBackPath,
        nextOfKinPassportPhotoPath: cartService.kinPassportPhotoPath,
        guarantorIdFrontPath: cartService.guarantorIdPhotoFrontPath,
        guarantorIdBackPath: cartService.guarantorIdPhotoBackPath,
        guarantorPassportPhotoPath: cartService.guarantorPassportPhotoPath,
        guarantorBikePhotoPath: cartService.guarantorBikePhotoPath,
        guarantorLogbookPhotoPath: cartService.guarantorLogbookPhotoPath,
      );

      Get.back(); // Close loading dialog

      if (loan != null) {
        cartService.clearCart();

        // Check if we need to show info popup (for new users with credit_limit = 0)
        // The backend sends show_info_popup in the response
        // We need to get the full response, not just the loan object
        // For now, show the popup if it's a new user scenario

        // Show success snackbar first
        Get.snackbar(
          'Loan Created Successfully',
          'Your application has been submitted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Small delay then show popup if needed
        Future.delayed(const Duration(milliseconds: 500), () {
          // Check loan status to determine if we should show popup
          if (loan.status == 'awaiting_registration_fee' || loan.status == 'pending') {
            _showSuccessInfoPopup();
          } else {
            // Navigate to deposit payment for approved loans
            Get.offAllNamed('/deposit-payment', arguments: loan);
          }
        });
      } else {
        throw Exception('Failed to create loan application');
      }
    } catch (e) {
      Get.back(); // Close loading dialog

      // Check if this is a structured popup response
      if (e is Map<String, dynamic> && e['show_popup'] == true) {
        _showPopupDialog(e);
      } else {
        // Regular error handling
        Get.snackbar(
          'Checkout Failed',
          'Failed to create loan application: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _showSuccessInfoPopup() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.green.shade50,
        title: Row(
          children: [
            const Text(
              '✅',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Application Submitted',
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your loan application has been submitted successfully!\n\n'
              'Our admin team will review your application and set your loan limit.\n\n'
              'You will be notified once your application is approved and you can proceed with the payment.\n\n'
              'Thank you for choosing us!',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Usually within 24-48 hours',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offAllNamed('/my-loans'); // Navigate to my loans
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('View My Applications'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offAllNamed('/home'); // Go to home
            },
            child: Text(
              'Go Home',
              style: TextStyle(color: Colors.green.shade900),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showPopupDialog(Map<String, dynamic> popupData) {
    final popupType = popupData['popup_type'] ?? 'info';
    final popupTitle = popupData['popup_title'] ?? 'Information';
    final popupIcon = popupData['popup_icon'] ?? 'ℹ️';
    final popupMessage = popupData['popup_message'] ?? popupData['message'] ?? '';
    final estimatedWait = popupData['estimated_wait'];
    final actionButtonText = popupData['action_button_text'];
    final actionRequired = popupData['action_required'];

    // Determine color based on popup type
    Color backgroundColor;
    Color titleColor;
    switch (popupType) {
      case 'warning':
        backgroundColor = Colors.orange.shade50;
        titleColor = Colors.orange.shade900;
        break;
      case 'error':
        backgroundColor = Colors.red.shade50;
        titleColor = Colors.red.shade900;
        break;
      default: // info
        backgroundColor = Colors.blue.shade50;
        titleColor = Colors.blue.shade900;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: backgroundColor,
        title: Row(
          children: [
            Text(
              popupIcon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                popupTitle,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              popupMessage,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            if (estimatedWait != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        estimatedWait,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (actionButtonText != null && actionRequired != null)
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                _handlePopupAction(actionRequired, popupData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: titleColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(actionButtonText),
            ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'OK',
              style: TextStyle(color: titleColor),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _handlePopupAction(String actionRequired, Map<String, dynamic> popupData) {
    switch (actionRequired) {
      case 'pay_registration_fee':
        // Navigate to registration fee payment
        Get.toNamed('/registration-fee-payment', arguments: {
          'amount': popupData['registration_fee_amount'],
        });
        break;
      case 'wait_for_review':
        // Navigate to my applications/loans screen
        Get.offAllNamed('/my-loans');
        break;
      case 'wait_for_admin_approval':
        // Navigate to loan status screen
        Get.offAllNamed('/my-loans');
        break;
      default:
        Get.offAllNamed('/home');
    }
  }

  static Widget _buildCreditInfoRow(
    String label,
    String value, {
    bool highlight = false,
    bool error = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: highlight || error
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: error
                  ? Colors.red
                  : (highlight ? Colors.green.shade700 : Colors.black87),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: error
                  ? Colors.red
                  : (highlight ? Colors.green.shade700 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
