import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/part_request_repository.dart';
import '../services/product_repository.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final CartService _cartService = Get.put(CartService());
  final ProductRepository _productRepository = ProductRepository();

  String _selectedCategory = 'All';
  List<Product> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Engine Parts',
    'Body & Frame',
    'Electrical & Lighting',
    'Tires & Wheels',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    // Get loan data from navigation arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      final loanId = args['loanId'] as int?;
      final customerId = args['customerId'] as int?;
      _cartService.setLoanContext(loanId: loanId, customerId: customerId);
    }
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productRepository.getAllProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load products: $e');
    }
  }

  List<Product> get filteredProducts {
    var filtered = _products;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (p.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Get.toNamed('/cart');
                },
              ),
              Obx(() => _cartService.itemCount > 0
                  ? Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${_cartService.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Profile Completed Banner
            if (_cartService.customerId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Application Form Completed!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select products and checkout to create your loan application.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search products',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // Category Filter
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Products Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProducts.isEmpty
                      ? _buildEmptyState(context)
                      : RefreshIndicator(
                          onRefresh: _loadProducts,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return _buildProductCard(context, product);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        // If cart has items
        if (_cartService.itemCount > 0) {
          // Check if profile is complete (customer ID exists)
          if (_cartService.customerId != null) {
            // Profile complete - show "Check Cart" button
            return FloatingActionButton.extended(
              onPressed: () {
                Get.toNamed('/cart');
              },
              backgroundColor: Colors.green,
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Check Cart'),
            );
          } else {
            // Profile not complete - show "Application Form" button
            return FloatingActionButton.extended(
              onPressed: () {
                Get.toNamed('/new-loan-application', arguments: {
                  'fromCart': true,
                });
              },
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.person_add),
              label: const Text('Application Form'),
            );
          }
        }
        // No items in cart - show "Request Part" FAB
        return FloatingActionButton.extended(
          onPressed: () => _showRequestPartDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Request Part'),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No Results Found' : 'No Products Available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try searching with different keywords'
                : 'No products in this category',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showProductDetails(context, product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                            );
                          },
                        )
                      : Icon(
                          Icons.shopping_bag,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
                // Discount Badge
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[600],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discountPercentage}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                // Out of Stock Badge
                if (!product.isInStock)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Out of Stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.category != null)
                      Text(
                        product.category!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    const Spacer(),
                    // Price
                    if (product.hasDiscount && product.originalPrice != null)
                      Text(
                        'KSh ${product.originalPrice!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      'KSh ${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    Get.dialog(
      Dialog(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Stack(
                children: [
                  Container(
                    height: 250,
                    color: Colors.grey[100],
                    child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                              );
                            },
                          )
                        : Icon(
                            Icons.shopping_bag,
                            size: 100,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                  // Discount Badge
                  if (product.hasDiscount)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange[600],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercentage}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (product.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.category!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Price
                    if (product.hasDiscount && product.originalPrice != null)
                      Text(
                        'KSh ${product.originalPrice!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      'KSh ${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (product.hasDiscount)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Save KSh ${((product.originalPrice ?? 0) - product.price).toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (product.description != null && product.description!.isNotEmpty) ...[
                      const Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(product.description!),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Icon(
                          product.isInStock ? Icons.check_circle : Icons.cancel,
                          color: product.isInStock ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.isInStock ? 'In Stock (${product.stockQuantity} available)' : 'Out of Stock',
                          style: TextStyle(
                            color: product.isInStock ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.back();
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Close'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: product.isInStock
                                ? () {
                                    Get.back();
                                    _cartService.addItem(
                                      CartItem(
                                        id: product.id.toString(),
                                        name: product.name,
                                        category: product.category ?? 'Other',
                                        price: product.price,
                                        description: product.description ?? '',
                                        quantity: 1,
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Add to Cart'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestPartDialog(BuildContext context) {
    final TextEditingController partNameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController motorcycleModelController = TextEditingController();
    final TextEditingController yearController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(text: '1');
    final TextEditingController budgetController = TextEditingController();
    final ImagePicker imagePicker = ImagePicker();
    String urgency = 'medium';
    File? selectedImage;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.assignment, color: Colors.orange),
            SizedBox(width: 12),
            Text('Request Part'),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Can\'t find the part you need? Request it here and we\'ll source it for you.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Part Name
                TextField(
                  controller: partNameController,
                  decoration: const InputDecoration(
                    labelText: 'Part Name *',
                    hintText: 'e.g., Brake Pads, Air Filter',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.settings),
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Additional details about the part',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Motorcycle Model and Year
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: motorcycleModelController,
                        decoration: const InputDecoration(
                          labelText: 'Motorcycle Model',
                          hintText: 'e.g., Honda CB 125',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          hintText: '2020',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quantity and Budget
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Budget (KSh)',
                          hintText: 'Optional',
                          border: OutlineInputBorder(),
                          prefixText: 'KSh ',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Urgency
                const Text('Urgency Level *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Low', style: TextStyle(fontSize: 12)),
                            value: 'low',
                            groupValue: urgency,
                            onChanged: (value) => setState(() => urgency = value!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Medium', style: TextStyle(fontSize: 12)),
                            value: 'medium',
                            groupValue: urgency,
                            onChanged: (value) => setState(() => urgency = value!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('High', style: TextStyle(fontSize: 12)),
                            value: 'high',
                            groupValue: urgency,
                            onChanged: (value) => setState(() => urgency = value!),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),
                // Image Upload Section
                const Text('Attach Image (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        if (selectedImage != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              selectedImage!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => setState(() => selectedImage = null),
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            label: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final XFile? image = await imagePicker.pickImage(
                                      source: ImageSource.camera,
                                      imageQuality: 70,
                                    );
                                    if (image != null) {
                                      setState(() => selectedImage = File(image.path));
                                    }
                                  },
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Camera'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final XFile? image = await imagePicker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 70,
                                    );
                                    if (image != null) {
                                      setState(() => selectedImage = File(image.path));
                                    }
                                  },
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Gallery'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (partNameController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter the part name',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              if (quantityController.text.trim().isEmpty || int.tryParse(quantityController.text) == null || int.parse(quantityController.text) < 1) {
                Get.snackbar(
                  'Error',
                  'Please enter a valid quantity',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back(); // Close dialog
              Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

              try {
                final partRequestRepo = PartRequestRepository();
                final partRequest = await partRequestRepo.createRequest(
                  partName: partNameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                  motorcycleModel: motorcycleModelController.text.trim().isEmpty ? null : motorcycleModelController.text.trim(),
                  year: yearController.text.trim().isEmpty ? null : yearController.text.trim(),
                  quantity: int.parse(quantityController.text.trim()),
                  budget: budgetController.text.trim().isEmpty ? null : double.tryParse(budgetController.text.trim()),
                  urgency: urgency,
                  imagePath: selectedImage?.path,
                );

                Get.back(); // Close loading

                if (partRequest != null) {
                  Get.snackbar(
                    'Success',
                    'Your part request has been submitted. We\'ll notify you when it\'s available.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 4),
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to submit part request. Please try again.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                Get.back(); // Close loading
                Get.snackbar(
                  'Error',
                  e.toString().replaceAll('Exception: ', ''),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 5),
                );
              }
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }
}
