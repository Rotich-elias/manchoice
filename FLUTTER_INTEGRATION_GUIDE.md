# Flutter App - Loan-Products Integration Guide

## What's New?

The Flutter app has been updated to support product-based loans with automatic stock management.

---

## Files Added/Updated

### New Files
1. **`lib/models/loan_item.dart`** - LoanItem model for product tracking
2. **`lib/screens/product_selection_screen.dart`** - Complete product selection UI

### Updated Files
1. **`lib/models/loan.dart`** - Added items support
2. **`lib/services/product_repository.dart`** - Added getCategories() method
3. **`lib/services/loan_repository.dart`** - Added items parameter to createLoan()

---

## How to Integrate into Your Loan Flow

### Option 1: Navigate to Product Selection Screen

```dart
import 'package:flutter/material.dart';
import '../screens/product_selection_screen.dart';
import '../services/loan_repository.dart';
import '../models/loan_item.dart';

class LoanApplicationScreen extends StatefulWidget {
  final int customerId;

  const LoanApplicationScreen({Key? key, required this.customerId}) : super(key: key);

  @override
  _LoanApplicationScreenState createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final LoanRepository _loanRepository = LoanRepository();

  List<LoanItemRequest>? _selectedProducts;
  double _totalAmount = 0.0;

  // Navigate to product selection
  Future<void> _selectProducts() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSelectionScreen(
          customerId: widget.customerId,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedProducts = result['items'] as List<LoanItemRequest>;
        _totalAmount = result['totalAmount'] as double;
      });
    }
  }

  // Create loan with products
  Future<void> _createLoan() async {
    try {
      final loan = await _loanRepository.createLoan(
        customerId: widget.customerId,
        principalAmount: _totalAmount,
        interestRate: 10.0,
        durationDays: 30,
        purpose: 'Purchase of motorcycle parts',
        items: _selectedProducts, // <-- Pass selected products
      );

      if (loan != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan application submitted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Application')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _selectProducts,
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Select Products'),
            ),

            if (_selectedProducts != null && _selectedProducts!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Selected Products: ${_selectedProducts!.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Total: KSh ${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedProducts!.length,
                  itemBuilder: (context, index) {
                    final item = _selectedProducts![index];
                    return ListTile(
                      title: Text(item.product?.name ?? 'Product #${item.productId}'),
                      subtitle: Text('Quantity: ${item.quantity}'),
                      trailing: Text(
                        'KSh ${item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedProducts == null || _selectedProducts!.isEmpty
                    ? null
                    : _createLoan,
                child: const Text('Submit Loan Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Option 2: Inline Product Selection

For a simpler integration, you can add a product selection button to your existing loan form:

```dart
// In your existing loan application form
ElevatedButton(
  onPressed: () async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSelectionScreen(
          customerId: customerId,
        ),
      ),
    );

    if (result != null) {
      // Use the selected items
      List<LoanItemRequest> items = result['items'];
      double totalAmount = result['totalAmount'];

      // Include in loan creation
      await _loanRepository.createLoan(
        customerId: customerId,
        principalAmount: totalAmount,
        items: items,
        // ... other parameters
      );
    }
  },
  child: const Text('Add Products to Loan'),
)
```

---

## Displaying Loan with Products

When displaying loan details:

```dart
import 'package:flutter/material.dart';
import '../models/loan.dart';

class LoanDetailScreen extends StatelessWidget {
  final Loan loan;

  const LoanDetailScreen({Key? key, required this.loan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Loan ${loan.loanNumber}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${loan.status}'),
                  Text('Total Amount: KSh ${loan.totalAmount.toStringAsFixed(2)}'),
                  Text('Balance: KSh ${loan.balance.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),

          // Show products if available
          if (loan.hasProducts) ...[
            const SizedBox(height: 16),
            const Text(
              'Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...loan.items!.map((item) => Card(
              child: ListTile(
                leading: item.product?.imageUrl != null
                    ? Image.network(
                        item.product!.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      )
                    : const Icon(Icons.inventory_2),
                title: Text(item.product?.name ?? 'Product #${item.productId}'),
                subtitle: Text('Quantity: ${item.quantity} × KSh ${item.unitPrice.toStringAsFixed(2)}'),
                trailing: Text(
                  'KSh ${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )).toList(),
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Products Value:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'KSh ${loan.totalProductsValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## Category Filter Example

If you want a standalone category filter widget:

```dart
import 'package:flutter/material.dart';
import '../services/product_repository.dart';

class CategoryFilter extends StatefulWidget {
  final Function(String?) onCategorySelected;

  const CategoryFilter({Key? key, required this.onCategorySelected}) : super(key: key);

  @override
  _CategoryFilterState createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  final ProductRepository _productRepository = ProductRepository();
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _productRepository.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: _selectedCategory == null,
              onSelected: (selected) {
                setState(() => _selectedCategory = null);
                widget.onCategorySelected(null);
              },
            ),
          ),
          ..._categories.map((category) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (selected) {
                setState(() => _selectedCategory = selected ? category : null);
                widget.onCategorySelected(_selectedCategory);
              },
            ),
          )),
        ],
      ),
    );
  }
}
```

---

## API Configuration

Make sure your API base URL is correctly configured. Check `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://192.168.100.65:8000/api';

  // Endpoints
  static const String products = '/products';
  static const String loans = '/loans';
  static const String customers = '/customers';
  static const String payments = '/payments';
}
```

---

## Testing

### Test Product Selection
1. Run the app
2. Navigate to loan creation
3. Click "Select Products"
4. Choose category filter
5. Select products and quantities
6. Verify total amount calculation
7. Submit loan application

### Test Loan Display
1. Fetch a loan with products
2. Verify products are displayed
3. Check that images load correctly
4. Verify calculations are correct

---

## Error Handling

The system handles these scenarios:

1. **Insufficient Stock**: Backend will block approval if stock is insufficient
2. **Out of Stock Products**: Products with 0 stock won't appear in selection
3. **Network Errors**: Proper error messages displayed to user
4. **Invalid Data**: Validation at both frontend and backend

---

## Key Features

✅ Category-based product filtering
✅ Search functionality
✅ Real-time stock display
✅ Quantity selection with validation
✅ Running total calculation
✅ Product image support
✅ Responsive UI
✅ Error handling
✅ Product selection summary
✅ Integration with existing loan flow

---

## Notes

- Products are optional - you can still create loans without products
- Stock is only deducted when admin approves the loan (not when created)
- Product prices are locked at loan creation time
- All monetary values are in Kenyan Shillings (KSh)

---

## Need Help?

See the backend documentation:
- `LOAN_PRODUCTS_INTEGRATION.md` - Complete backend integration guide
- `QUICK_START_LOAN_PRODUCTS.md` - Quick reference guide
- `PRODUCTS_API_FLUTTER.md` - Product API documentation
