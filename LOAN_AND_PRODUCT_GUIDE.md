# Loan Approval & Product Management Guide

## ✅ What's Working

Both features are fully implemented and tested:
- ✅ **Loan Approval** - Approve pending loans
- ✅ **Product Management** - Create, update, and manage products/spare parts
- ✅ **Stock Management** - Track and update product inventory

## 📦 1. Loan Approval

### Backend API
The loan approval endpoint is already implemented: `POST /api/loans/{id}/approve`

### Flutter Usage

```dart
import 'package:manchoice/services/loan_repository.dart';

final loanRepo = LoanRepository();

// Approve a loan
Future<void> approveLoan(int loanId) async {
  try {
    final loan = await loanRepo.approveLoan(loanId);

    if (loan != null) {
      print('✅ Loan ${loan.loanNumber} approved!');
      print('Status: ${loan.status}');
      print('Approved by: ${loan.approver?.name}');
      print('Total amount: KES ${loan.totalAmount}');
      print('Customer total borrowed: KES ${loan.customer?.totalBorrowed}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Example Flow

```dart
// 1. Get all pending loans
final pendingLoans = await loanRepo.getAllLoans(status: 'pending');

// 2. Display them in a list
for (var loan in pendingLoans) {
  print('${loan.loanNumber}: ${loan.customer?.name} - KES ${loan.totalAmount}');
}

// 3. Approve selected loan
await approveLoan(selectedLoanId);

// 4. Loan is now approved and customer's total_borrowed is updated
```

### What Happens on Approval?

1. Loan status changes from `pending` → `approved`
2. Disbursement date is set to today
3. Approved by user ID is recorded
4. Customer's `total_borrowed` is increased
5. Approval timestamp is saved

### UI Example

```dart
ListTile(
  title: Text(loan.loanNumber),
  subtitle: Text('${loan.customer?.name} - KES ${loan.totalAmount}'),
  trailing: loan.status == 'pending'
      ? ElevatedButton(
          onPressed: () async {
            await approveLoan(loan.id);
            // Refresh list
          },
          child: Text('Approve'),
        )
      : Chip(
          label: Text(loan.status.toUpperCase()),
          backgroundColor: loan.status == 'approved'
              ? Colors.green
              : Colors.grey,
        ),
)
```

## 🛍️ 2. Product Management

### Backend API Endpoints

```
GET    /api/products                     - List all products
POST   /api/products                     - Create product
GET    /api/products/{id}                - Get product
PUT    /api/products/{id}                - Update product
DELETE /api/products/{id}                - Delete product
POST   /api/products/{id}/update-stock   - Update stock quantity
POST   /api/products/{id}/toggle-availability - Toggle availability
GET    /api/products/category/{category} - Get by category
```

### Flutter Usage

#### Get All Products

```dart
import 'package:manchoice/services/product_repository.dart';

final productRepo = ProductRepository();

// Get all products
final products = await productRepo.getAllProducts();

// Filter by category
final spareparts = await productRepo.getAllProducts(category: 'Spare Parts');

// Search by name
final chains = await productRepo.getAllProducts(search: 'chain');

// Get only available products
final available = await productRepo.getAllProducts(available: true);

// Get only in-stock products
final inStock = await productRepo.getAllProducts(inStock: true);
```

#### Create Product

```dart
final product = await productRepo.createProduct(
  name: 'Motorcycle Chain',
  description: 'Heavy duty motorcycle chain - 520 series',
  category: 'Spare Parts',
  price: 2500,
  imageUrl: 'https://example.com/chain.jpg',
  stockQuantity: 50,
  isAvailable: true,
);

if (product != null) {
  print('Product created: ${product.name}');
}
```

#### Update Product

```dart
final updatedProduct = await productRepo.updateProduct(
  id: productId,
  name: 'Updated Chain',
  price: 2800,
  stockQuantity: 45,
);
```

#### Update Stock

```dart
// Add stock (e.g., new shipment arrived)
await productRepo.updateStock(
  id: productId,
  quantity: 20,
  action: 'add', // Adds 20 to current stock
);

// Reduce stock (e.g., sold items)
await productRepo.updateStock(
  id: productId,
  quantity: 5,
  action: 'reduce', // Subtracts 5 from current stock
);

// Set exact stock (e.g., after physical count)
await productRepo.updateStock(
  id: productId,
  quantity: 30,
  action: 'set', // Sets stock to exactly 30
);
```

#### Toggle Availability

```dart
// Make product unavailable (e.g., discontinued)
await productRepo.toggleAvailability(productId);

// Toggle again to make available
await productRepo.toggleAvailability(productId);
```

### Complete Product Management Screen Example

```dart
import 'package:flutter/material.dart';
import 'package:manchoice/services/product_repository.dart';
import 'package:manchoice/models/product.dart';

class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final productRepo = ProductRepository();
  List<Product> products = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await productRepo.getAllProducts();
      setState(() => products = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateStock(int productId, int quantity, String action) async {
    try {
      await productRepo.updateStock(
        id: productId,
        quantity: quantity,
        action: action,
      );
      await loadProducts(); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: product.imageUrl != null
                        ? Image.network(product.imageUrl!, width: 50, height: 50)
                        : Icon(Icons.inventory),
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: KES ${product.price}'),
                        Text('Stock: ${product.stockQuantity}'),
                        Text(
                          product.isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: product.isAvailable
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => updateStock(product.id, 1, 'reduce'),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => updateStock(product.id, 1, 'add'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add product screen
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## 🔍 Testing Examples

### Test Loan Approval (Terminal)

```bash
TOKEN="YOUR_TOKEN_HERE"

# Create a loan
curl -X POST http://localhost:8000/api/loans \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_id": 1,
    "principal_amount": 10000,
    "interest_rate": 10,
    "duration_days": 30,
    "purpose": "Business"
  }'

# Approve the loan (use ID from above)
curl -X POST http://localhost:8000/api/loans/3/approve \
  -H "Authorization: Bearer $TOKEN"
```

### Test Product Management (Terminal)

```bash
TOKEN="YOUR_TOKEN_HERE"

# Create a product
curl -X POST http://localhost:8000/api/products \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Brake Pads",
    "description": "High quality brake pads",
    "category": "Spare Parts",
    "price": 1500,
    "stock_quantity": 100
  }'

# Update stock (reduce by 10)
curl -X POST http://localhost:8000/api/products/1/update-stock \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 10,
    "action": "reduce"
  }'

# Get all products
curl -X GET http://localhost:8000/api/products \
  -H "Authorization: Bearer $TOKEN"
```

## 📊 Database Tables

### Loans Table
- `status` can be: pending, approved, active, completed, defaulted, cancelled
- `approved_by` - ID of user who approved
- `approved_at` - Timestamp of approval

### Products Table
- `name` - Product name (required)
- `description` - Product description
- `category` - Product category
- `price` - Price in KES
- `image_url` - Product image URL
- `stock_quantity` - Current stock level
- `is_available` - Whether product is available for sale

## 🎯 Summary

**Loan Approval:**
- ✅ Use `loanRepo.approveLoan(id)` in Flutter
- ✅ Backend endpoint: `POST /api/loans/{id}/approve`
- ✅ Automatically updates customer's total borrowed amount

**Product Management:**
- ✅ Full CRUD operations
- ✅ Stock management (add/reduce/set)
- ✅ Availability toggle
- ✅ Category filtering
- ✅ Search functionality

Both features are production-ready and tested! 🚀
