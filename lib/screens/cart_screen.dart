import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
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
          Obx(() => cartService.itemCount > 0
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showClearCartDialog(context, cartService),
                  tooltip: 'Clear Cart',
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (cartService.items.isEmpty) {
          return _buildEmptyCart(context);
        }

        return Column(
          children: [
            // Loan Info Banner (if loan context exists)
            if (cartService.loanId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Items will be added to Loan #${cartService.loanId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // No Loan Application Banner (if no loan context)
            if (cartService.loanId == null)
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
                        Get.toNamed('/new-loan-application', arguments: {
                          'fromCart': true,
                        });
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
                separatorBuilder: (context, index) => const SizedBox(height: 12),
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
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
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
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
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
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
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
              _buildPriceRow(
                'Subtotal',
                cartService.subtotal,
                isRegular: true,
              ),
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
              _buildPriceRow(
                'Total',
                cartService.total,
                isRegular: false,
              ),
              const SizedBox(height: 16),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: cartService.loanId != null
                      ? () => _handleCheckout(context, cartService)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    cartService.loanId != null
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

  Widget _buildPriceRow(String label, double amount,
      {required bool isRegular, Color? color}) {
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
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context, CartService cartService) {
    if (cartService.loanId == null) {
      Get.snackbar(
        'No Loan Application',
        'Please submit a loan application first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

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
            Text('Interest: KES ${cartService.interestAmount.toStringAsFixed(0)}'),
            const Divider(height: 20),
            Text(
              'Total: KES ${cartService.total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your loan application will be updated with these products and submitted to admin for approval.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
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
                  Text('Processing checkout...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Update loan with cart total
      final loanRepo = LoanRepository();
      await loanRepo.updateLoan(
        id: cartService.loanId!,
        principalAmount: cartService.total,
        notes: 'Products selected: ${cartService.items.map((item) => '${item.name} (x${item.quantity})').join(', ')}',
      );

      Get.back(); // Close loading dialog
      Get.offAllNamed('/dashboard');

      Get.snackbar(
        'Checkout Successful',
        'Your loan application has been updated and submitted for approval',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      cartService.clearCart();
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Checkout Failed',
        'Failed to update loan application: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
