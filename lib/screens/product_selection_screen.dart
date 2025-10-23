import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/loan_item.dart';
import '../services/product_repository.dart';

class ProductSelectionScreen extends StatefulWidget {
  final int customerId;
  final double? initialAmount;

  const ProductSelectionScreen({
    super.key,
    required this.customerId,
    this.initialAmount,
  });

  @override
  _ProductSelectionScreenState createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final ProductRepository _productRepository = ProductRepository();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final List<LoanItemRequest> _selectedItems = [];
  List<String> _categories = [];

  String? _selectedCategory;
  bool _isLoading = true;
  bool _isLoadingCategories = true;
  final String _searchQuery = '';
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _productRepository.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productRepository.getAllProducts(
        inStock: true,
        category: _selectedCategory,
      );
      setState(() {
        _products = products;
        _filterProducts();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch =
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.description?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ??
                false);
        return matchesSearch;
      }).toList();
    });
  }

  void _addProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => _QuantityDialog(
        product: product,
        onConfirm: (quantity) {
          setState(() {
            final existingIndex = _selectedItems.indexWhere(
              (item) => item.productId == product.id,
            );

            if (existingIndex >= 0) {
              // Update existing item
              _selectedItems[existingIndex] = LoanItemRequest(
                productId: product.id,
                quantity: _selectedItems[existingIndex].quantity + quantity,
                product: product,
              );
            } else {
              // Add new item
              _selectedItems.add(
                LoanItemRequest(
                  productId: product.id,
                  quantity: quantity,
                  product: product,
                ),
              );
            }
            _calculateTotal();
          });
        },
      ),
    );
  }

  void _removeProduct(int index) {
    setState(() {
      _selectedItems.removeAt(index);
      _calculateTotal();
    });
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _selectedItems.removeAt(index);
      } else {
        final item = _selectedItems[index];
        _selectedItems[index] = LoanItemRequest(
          productId: item.productId,
          quantity: quantity,
          product: item.product,
        );
      }
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _totalAmount = _selectedItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  void _proceedToLoanCreation() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product')),
      );
      return;
    }

    Navigator.pop(context, {
      'items': _selectedItems,
      'totalAmount': _totalAmount,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ProductSearchDelegate(_products, _addProduct),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          if (!_isLoadingCategories)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: 'All',
                    isSelected: _selectedCategory == null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                      _loadProducts();
                    },
                  ),
                  ..._categories.map(
                    (category) => _CategoryChip(
                      label: category,
                      isSelected: _selectedCategory == category,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        _loadProducts();
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Products list
          Expanded(
            flex: 2,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? const Center(child: Text('No products available'))
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final isSelected = _selectedItems.any(
                        (item) => item.productId == product.id,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: product.imageUrl != null
                              ? Image.network(
                                  product.imageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported),
                                )
                              : const Icon(Icons.inventory_2, size: 50),
                          title: Text(product.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('KSh ${product.price.toStringAsFixed(2)}'),
                              Text(
                                'Stock: ${product.stockQuantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: product.stockQuantity < 10
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.add_circle_outline,
                              color: isSelected ? Colors.green : null,
                            ),
                            onPressed: () => _addProduct(product),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Selected items summary
          if (_selectedItems.isNotEmpty)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Selected Items (${_selectedItems.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _selectedItems.length,
                        itemBuilder: (context, index) {
                          final item = _selectedItems[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              item.product?.name ??
                                  'Product #${item.productId}',
                            ),
                            subtitle: Text(
                              'KSh ${item.subtotal.toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _updateQuantity(index, item.quantity - 1),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _updateQuantity(index, item.quantity + 1),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeProduct(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'KSh ${_totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_selectedItems.length} items selected',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedItems.isEmpty
                        ? null
                        : _proceedToLoanCreation,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Proceed to Loan Application',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Category chip widget
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

// Quantity dialog
class _QuantityDialog extends StatefulWidget {
  final Product product;
  final Function(int) onConfirm;

  const _QuantityDialog({required this.product, required this.onConfirm});

  @override
  _QuantityDialogState createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.product.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Price: KSh ${widget.product.price.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          Text('Available: ${widget.product.stockQuantity} units'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (quantity > 1) setState(() => quantity--);
                },
              ),
              Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (quantity < widget.product.stockQuantity) {
                    setState(() => quantity++);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Subtotal: KSh ${(widget.product.price * quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(quantity);
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Product search delegate
class _ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;
  final Function(Product) onProductSelected;

  _ProductSearchDelegate(this.products, this.onProductSelected);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          (product.description?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: product.imageUrl != null
              ? Image.network(
                  product.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                )
              : const Icon(Icons.inventory_2),
          title: Text(product.name),
          subtitle: Text(
            'KSh ${product.price.toStringAsFixed(2)} • Stock: ${product.stockQuantity}',
          ),
          onTap: () {
            onProductSelected(product);
            close(context, product);
          },
        );
      },
    );
  }
}
