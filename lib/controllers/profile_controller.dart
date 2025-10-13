import 'package:get/get.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<User?> currentUser = Rx<User?>(null);
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
    } catch (e) {
      errorMessage.value = 'Failed to load profile: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }
}
