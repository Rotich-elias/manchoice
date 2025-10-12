import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartService extends GetxController {
  final RxList<CartItem> _items = <CartItem>[].obs;
  final RxInt _loanId = 0.obs;
  final RxInt _customerId = 0.obs;

  // Customer documents
  final RxString _bikePhotoPath = ''.obs;
  final RxString _logbookPhotoPath = ''.obs;
  final RxString _passportPhotoPath = ''.obs;
  final RxString _idPhotoPath = ''.obs;
  final RxString _kinIdPhotoPath = ''.obs;
  final RxString _guarantorIdPhotoPath = ''.obs;

  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  int? get loanId => _loanId.value == 0 ? null : _loanId.value;
  int? get customerId => _customerId.value == 0 ? null : _customerId.value;

  // Document getters
  String? get bikePhotoPath => _bikePhotoPath.value.isEmpty ? null : _bikePhotoPath.value;
  String? get logbookPhotoPath => _logbookPhotoPath.value.isEmpty ? null : _logbookPhotoPath.value;
  String? get passportPhotoPath => _passportPhotoPath.value.isEmpty ? null : _passportPhotoPath.value;
  String? get idPhotoPath => _idPhotoPath.value.isEmpty ? null : _idPhotoPath.value;
  String? get kinIdPhotoPath => _kinIdPhotoPath.value.isEmpty ? null : _kinIdPhotoPath.value;
  String? get guarantorIdPhotoPath => _guarantorIdPhotoPath.value.isEmpty ? null : _guarantorIdPhotoPath.value;

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get interestRate => 0.30; // 30% interest
  double get interestAmount => subtotal * interestRate;
  double get total => subtotal + interestAmount;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  void setLoanContext({int? loanId, int? customerId}) {
    if (loanId != null) _loanId.value = loanId;
    if (customerId != null) _customerId.value = customerId;
    _saveCart();
  }

  void setCustomerId(int customerId) {
    _customerId.value = customerId;
    _saveCart();
  }

  void setCustomerDocuments({
    required String bikePhoto,
    required String logbookPhoto,
    required String passportPhoto,
    required String idPhoto,
    required String kinIdPhoto,
    required String guarantorIdPhoto,
  }) {
    _bikePhotoPath.value = bikePhoto;
    _logbookPhotoPath.value = logbookPhoto;
    _passportPhotoPath.value = passportPhoto;
    _idPhotoPath.value = idPhoto;
    _kinIdPhotoPath.value = kinIdPhoto;
    _guarantorIdPhotoPath.value = guarantorIdPhoto;
    _saveCart();
  }

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.id == item.id);

    if (existingIndex >= 0) {
      // Item already exists, increase quantity
      _items[existingIndex].quantity++;
      _items.refresh();
    } else {
      // Add new item
      _items.add(item);
    }

    _saveCart();
    Get.snackbar(
      'Added to Cart',
      '${item.name} has been added to your cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _saveCart();
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      _items.refresh();
      _saveCart();
    }
  }

  void incrementQuantity(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index].quantity++;
      _items.refresh();
      _saveCart();
    }
  }

  void decrementQuantity(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        _items.refresh();
        _saveCart();
      } else {
        removeItem(itemId);
      }
    }
  }

  void clearCart() {
    _items.clear();
    _loanId.value = 0;
    _customerId.value = 0;
    _bikePhotoPath.value = '';
    _logbookPhotoPath.value = '';
    _passportPhotoPath.value = '';
    _idPhotoPath.value = '';
    _kinIdPhotoPath.value = '';
    _guarantorIdPhotoPath.value = '';
    _saveCart();
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = {
        'items': _items.map((item) => item.toJson()).toList(),
        'loanId': _loanId.value,
        'customerId': _customerId.value,
        'bikePhotoPath': _bikePhotoPath.value,
        'logbookPhotoPath': _logbookPhotoPath.value,
        'passportPhotoPath': _passportPhotoPath.value,
        'idPhotoPath': _idPhotoPath.value,
        'kinIdPhotoPath': _kinIdPhotoPath.value,
        'guarantorIdPhotoPath': _guarantorIdPhotoPath.value,
      };
      await prefs.setString('shopping_cart', jsonEncode(cartData));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('shopping_cart');

      if (cartString != null) {
        final cartData = jsonDecode(cartString) as Map<String, dynamic>;
        final itemsList = cartData['items'] as List<dynamic>;

        _items.value = itemsList
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();

        _loanId.value = cartData['loanId'] as int? ?? 0;
        _customerId.value = cartData['customerId'] as int? ?? 0;
        _bikePhotoPath.value = cartData['bikePhotoPath'] as String? ?? '';
        _logbookPhotoPath.value = cartData['logbookPhotoPath'] as String? ?? '';
        _passportPhotoPath.value = cartData['passportPhotoPath'] as String? ?? '';
        _idPhotoPath.value = cartData['idPhotoPath'] as String? ?? '';
        _kinIdPhotoPath.value = cartData['kinIdPhotoPath'] as String? ?? '';
        _guarantorIdPhotoPath.value = cartData['guarantorIdPhotoPath'] as String? ?? '';
      }
    } catch (e) {
      // Handle error silently - start with empty cart
      _items.clear();
    }
  }

  bool isInCart(String itemId) {
    return _items.any((item) => item.id == itemId);
  }

  int getItemQuantity(String itemId) {
    final item = _items.firstWhereOrNull((item) => item.id == itemId);
    return item?.quantity ?? 0;
  }
}
