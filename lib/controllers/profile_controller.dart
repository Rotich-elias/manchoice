import 'package:get/get.dart';
import '../models/user.dart';
import '../models/customer_api.dart';
import '../services/auth_service.dart';
import '../services/customer_repository.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();
  final CustomerRepository _customerRepository = CustomerRepository();

  final Rx<User?> currentUser = Rx<User?>(null);
  final Rx<CustomerApi?> customerProfile = Rx<CustomerApi?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authService.getCurrentUser();
      currentUser.value = user;

      // Load customer profile if user has a customer_id
      if (user?.customerId != null) {
        final customer = await _customerRepository.getMyProfile();
        customerProfile.value = customer;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  Future<void> updateMotorcycleInfo({
    String? numberPlate,
    String? chassisNumber,
    String? model,
    String? type,
    String? engineCC,
    String? colour,
  }) async {
    try {
      if (customerProfile.value == null) {
        throw Exception('No customer profile found');
      }

      isLoading.value = true;
      final updatedCustomer = await _customerRepository.updateCustomer(
        id: customerProfile.value!.id,
        motorcycleNumberPlate: numberPlate,
        motorcycleChassisNumber: chassisNumber,
        motorcycleModel: model,
        motorcycleType: type,
        motorcycleEngineCC: engineCC,
        motorcycleColour: colour,
      );

      if (updatedCustomer != null) {
        customerProfile.value = updatedCustomer;
        Get.snackbar(
          'Success',
          'Motorcycle information updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
