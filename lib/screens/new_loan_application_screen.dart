import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/customer_repository.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../models/customer_api.dart';

class NewLoanApplicationScreen extends StatefulWidget {
  const NewLoanApplicationScreen({super.key});

  @override
  State<NewLoanApplicationScreen> createState() =>
      _NewLoanApplicationScreenState();
}

class _NewLoanApplicationScreenState extends State<NewLoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  bool _isSubmitting = false;
  bool _fromCart = false;
  bool _isLoading = true;
  CartService? _cartService;
  CustomerApi? _existingCustomer;
  double _profileCompletion = 0.0;

  @override
  void initState() {
    super.initState();
    // Check if coming from cart
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _fromCart = args['fromCart'] == true;
      if (_fromCart) {
        try {
          _cartService = Get.find<CartService>();
        } catch (e) {
          _fromCart = false;
        }
      }
    }
    _loadExistingProfile();
    _setupListeners();
  }

  void _setupListeners() {
    // Add listeners to all text controllers to update completion percentage
    _fullNameController.addListener(_calculateCompletionPercentage);
    _phoneController.addListener(_calculateCompletionPercentage);
    _nationalIdController.addListener(_calculateCompletionPercentage);
    _workingStationController.addListener(_calculateCompletionPercentage);
    _numberPlateController.addListener(_calculateCompletionPercentage);
    _chassisNumberController.addListener(_calculateCompletionPercentage);
    _modelController.addListener(_calculateCompletionPercentage);
    _typeController.addListener(_calculateCompletionPercentage);
    _engineCCController.addListener(_calculateCompletionPercentage);
    _colourController.addListener(_calculateCompletionPercentage);
    _kinNameController.addListener(_calculateCompletionPercentage);
    _kinPhoneController.addListener(_calculateCompletionPercentage);
    _kinRelationshipController.addListener(_calculateCompletionPercentage);
    _guarantorNameController.addListener(_calculateCompletionPercentage);
    _guarantorPhoneController.addListener(_calculateCompletionPercentage);
    _guarantorRelationshipController.addListener(_calculateCompletionPercentage);
  }

  Future<void> _loadExistingProfile() async {
    try {
      final customerRepo = CustomerRepository();
      final customer = await customerRepo.getMyProfile();

      if (customer != null && mounted) {
        setState(() {
          _existingCustomer = customer;
          _preFillForm(customer);
          _calculateCompletionPercentage();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }

      // Load saved photos
      await _loadSavedPhotos();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadSavedPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final bikePath = prefs.getString('bike_photo_path');
      final logbookPath = prefs.getString('logbook_photo_path');
      final passportPath = prefs.getString('passport_photo_path');
      final idPath = prefs.getString('id_photo_path');
      final kinIdPath = prefs.getString('kin_id_photo_path');
      final guarantorIdPath = prefs.getString('guarantor_id_photo_path');

      if (mounted) {
        setState(() {
          if (bikePath != null && File(bikePath).existsSync()) {
            _bikePhoto = File(bikePath);
          }
          if (logbookPath != null && File(logbookPath).existsSync()) {
            _logbookPhoto = File(logbookPath);
          }
          if (passportPath != null && File(passportPath).existsSync()) {
            _passportPhoto = File(passportPath);
          }
          if (idPath != null && File(idPath).existsSync()) {
            _idPhoto = File(idPath);
          }
          if (kinIdPath != null && File(kinIdPath).existsSync()) {
            _kinIdPhoto = File(kinIdPath);
          }
          if (guarantorIdPath != null && File(guarantorIdPath).existsSync()) {
            _guarantorIdPhoto = File(guarantorIdPath);
          }
          _calculateCompletionPercentage();
        });
      }
    } catch (e) {
      // Error loading photos, continue without them
    }
  }

  String _getPhotoKey(String imageType) {
    switch (imageType) {
      case 'bike':
        return 'bike_photo_path';
      case 'logbook':
        return 'logbook_photo_path';
      case 'passport':
        return 'passport_photo_path';
      case 'id':
        return 'id_photo_path';
      case 'kinId':
        return 'kin_id_photo_path';
      case 'guarantorId':
        return 'guarantor_id_photo_path';
      default:
        return '${imageType}_photo_path';
    }
  }

  Future<String> _saveImagePermanently(File tempFile, String imageType) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final permanentDir = Directory('${appDir.path}/loan_documents');

      if (!await permanentDir.exists()) {
        await permanentDir.create(recursive: true);
      }

      final fileName = '${imageType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final permanentPath = '${permanentDir.path}/$fileName';

      await tempFile.copy(permanentPath);

      // Save path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_getPhotoKey(imageType), permanentPath);

      return permanentPath;
    } catch (e) {
      rethrow;
    }
  }

  void _preFillForm(CustomerApi customer) {
    _fullNameController.text = customer.name ?? '';
    _phoneController.text = customer.phone ?? '';
    _nationalIdController.text = customer.idNumber ?? '';
    _workingStationController.text = customer.address ?? '';
    _numberPlateController.text = customer.motorcycleNumberPlate ?? '';
    _chassisNumberController.text = customer.motorcycleChassisNumber ?? '';
    _modelController.text = customer.motorcycleModel ?? '';
    _typeController.text = customer.motorcycleType ?? '';
    _engineCCController.text = customer.motorcycleEngineCC ?? '';
    _colourController.text = customer.motorcycleColour ?? '';
    _kinNameController.text = customer.nextOfKinName ?? '';
    _kinPhoneController.text = customer.nextOfKinPhone ?? '';
    _kinRelationshipController.text = customer.nextOfKinRelationship ?? '';
    _guarantorNameController.text = customer.guarantorName ?? '';
    _guarantorPhoneController.text = customer.guarantorPhone ?? '';
    _guarantorRelationshipController.text = customer.guarantorRelationship ?? '';
  }

  void _calculateCompletionPercentage() {
    int filledFields = 0;
    int totalFields = 22; // 16 text fields + 6 photos

    // Personal Info (4 fields)
    if (_fullNameController.text.isNotEmpty) filledFields++;
    if (_phoneController.text.isNotEmpty) filledFields++;
    if (_nationalIdController.text.isNotEmpty) filledFields++;
    if (_workingStationController.text.isNotEmpty) filledFields++;

    // Motorcycle Details (6 fields)
    if (_numberPlateController.text.isNotEmpty) filledFields++;
    if (_chassisNumberController.text.isNotEmpty) filledFields++;
    if (_modelController.text.isNotEmpty) filledFields++;
    if (_typeController.text.isNotEmpty) filledFields++;
    if (_engineCCController.text.isNotEmpty) filledFields++;
    if (_colourController.text.isNotEmpty) filledFields++;

    // Next of Kin (3 fields)
    if (_kinNameController.text.isNotEmpty) filledFields++;
    if (_kinPhoneController.text.isNotEmpty) filledFields++;
    if (_kinRelationshipController.text.isNotEmpty) filledFields++;

    // Guarantor (3 fields)
    if (_guarantorNameController.text.isNotEmpty) filledFields++;
    if (_guarantorPhoneController.text.isNotEmpty) filledFields++;
    if (_guarantorRelationshipController.text.isNotEmpty) filledFields++;

    // Photos (6 fields)
    if (_bikePhoto != null) filledFields++;
    if (_logbookPhoto != null) filledFields++;
    if (_passportPhoto != null) filledFields++;
    if (_idPhoto != null) filledFields++;
    if (_kinIdPhoto != null) filledFields++;
    if (_guarantorIdPhoto != null) filledFields++;

    setState(() {
      _profileCompletion = (filledFields / totalFields) * 100;
    });
  }

  // Personal Information Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _workingStationController = TextEditingController();

  // Motorcycle Details Controllers
  final _numberPlateController = TextEditingController();
  final _chassisNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _typeController = TextEditingController();
  final _engineCCController = TextEditingController();
  final _colourController = TextEditingController();

  // Next of Kin Controllers
  final _kinNameController = TextEditingController();
  final _kinPhoneController = TextEditingController();
  final _kinRelationshipController = TextEditingController();

  // Guarantor Controllers
  final _guarantorNameController = TextEditingController();
  final _guarantorPhoneController = TextEditingController();
  final _guarantorRelationshipController = TextEditingController();

  // Image Files
  File? _bikePhoto;
  File? _logbookPhoto;
  File? _passportPhoto;
  File? _idPhoto;
  File? _kinIdPhoto;
  File? _guarantorIdPhoto;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _workingStationController.dispose();
    _numberPlateController.dispose();
    _chassisNumberController.dispose();
    _modelController.dispose();
    _typeController.dispose();
    _engineCCController.dispose();
    _colourController.dispose();
    _kinNameController.dispose();
    _kinPhoneController.dispose();
    _kinRelationshipController.dispose();
    _guarantorNameController.dispose();
    _guarantorPhoneController.dispose();
    _guarantorRelationshipController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String imageType) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        // Save the image permanently
        final permanentPath = await _saveImagePermanently(
          File(pickedFile.path),
          imageType,
        );

        setState(() {
          switch (imageType) {
            case 'bike':
              _bikePhoto = File(permanentPath);
              break;
            case 'logbook':
              _logbookPhoto = File(permanentPath);
              break;
            case 'passport':
              _passportPhoto = File(permanentPath);
              break;
            case 'id':
              _idPhoto = File(permanentPath);
              break;
            case 'kinId':
              _kinIdPhoto = File(permanentPath);
              break;
            case 'guarantorId':
              _guarantorIdPhoto = File(permanentPath);
              break;
          }
          _calculateCompletionPercentage();
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate all required images
    if (_bikePhoto == null ||
        _logbookPhoto == null ||
        _passportPhoto == null ||
        _idPhoto == null ||
        _kinIdPhoto == null ||
        _guarantorIdPhoto == null) {
      Get.snackbar(
        'Missing Photos',
        'Please upload all required photos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final customerRepo = CustomerRepository();

      // Create or Update customer with complete profile info
      final CustomerApi? customer;

      if (_existingCustomer != null) {
        // Update existing customer
        customer = await customerRepo.updateCustomer(
          id: _existingCustomer!.id,
          name: _fullNameController.text,
          phone: _phoneController.text,
          idNumber: _nationalIdController.text,
          address: _workingStationController.text,
          motorcycleNumberPlate: _numberPlateController.text,
          motorcycleChassisNumber: _chassisNumberController.text,
          motorcycleModel: _modelController.text,
          motorcycleType: _typeController.text,
          motorcycleEngineCC: _engineCCController.text,
          motorcycleColour: _colourController.text,
          nextOfKinName: _kinNameController.text,
          nextOfKinPhone: _kinPhoneController.text,
          nextOfKinRelationship: _kinRelationshipController.text,
          guarantorName: _guarantorNameController.text,
          guarantorPhone: _guarantorPhoneController.text,
          guarantorRelationship: _guarantorRelationshipController.text,
          notes: _existingCustomer!.notes ?? 'Profile updated',
        );
      } else {
        // Create new customer
        customer = await customerRepo.createCustomer(
          name: _fullNameController.text,
          phone: _phoneController.text,
          idNumber: _nationalIdController.text,
          address: _workingStationController.text,
          motorcycleNumberPlate: _numberPlateController.text,
          motorcycleChassisNumber: _chassisNumberController.text,
          motorcycleModel: _modelController.text,
          motorcycleType: _typeController.text,
          motorcycleEngineCC: _engineCCController.text,
          motorcycleColour: _colourController.text,
          nextOfKinName: _kinNameController.text,
          nextOfKinPhone: _kinPhoneController.text,
          nextOfKinRelationship: _kinRelationshipController.text,
          guarantorName: _guarantorNameController.text,
          guarantorPhone: _guarantorPhoneController.text,
          guarantorRelationship: _guarantorRelationshipController.text,
          notes: 'Profile completed from mobile app',
        );
      }

      if (customer == null) {
        throw Exception('Failed to ${_existingCustomer != null ? "update" : "create"} customer record');
      }

      // Mark user's profile as completed
      final authService = AuthService();
      await authService.completeProfile(customerId: customer.id);

      if (!mounted) return;

      // Store photo paths in cart service for later loan creation
      if (_cartService != null) {
        _cartService!.setCustomerDocuments(
          bikePhoto: _bikePhoto!.path,
          logbookPhoto: _logbookPhoto!.path,
          passportPhoto: _passportPhoto!.path,
          idPhoto: _idPhoto!.path,
          kinIdPhoto: _kinIdPhoto!.path,
          guarantorIdPhoto: _guarantorIdPhoto!.path,
        );
        _cartService!.setCustomerId(customer.id);
      }

      // Don't clear SharedPreferences - keep photos for user to see

      // Show success message
      Get.snackbar(
        'Success',
        'Profile completed! Continue shopping.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      // If coming from cart, navigate to products page
      if (_fromCart && _cartService != null) {
        // Go back to products page (removing cart and profile screens from stack)
        Get.offAllNamed('/products', arguments: {
          'customerId': customer.id,
        });
      } else {
        // Default flow: Navigate to products
        Get.offNamed('/products', arguments: {
          'customerId': customer.id,
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit application: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Profile Completion Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _profileCompletion >= 75
                            ? Colors.green.shade400
                            : _profileCompletion >= 50
                                ? Colors.orange.shade400
                                : Colors.red.shade400,
                        _profileCompletion >= 75
                            ? Colors.green.shade600
                            : _profileCompletion >= 50
                                ? Colors.orange.shade600
                                : Colors.red.shade600,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _profileCompletion >= 100
                            ? Icons.check_circle
                            : Icons.account_circle,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Completion',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: _profileCompletion / 100,
                                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${_profileCompletion.toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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

                // Cart context banner
                if (_fromCart && _cartService != null && _cartService!.itemCount > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete your loan application',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'You have ${_cartService!.itemCount} item(s) in your cart',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Personal Information Section
                    _buildSectionHeader(
                      context,
                      'Personal Information',
                      Icons.person,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildPersonalInfoStep(),
                    const SizedBox(height: 32),

                    // Motorcycle Details Section
                    _buildSectionHeader(
                      context,
                      'Motorcycle Details',
                      Icons.motorcycle,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildMotorcycleDetailsStep(),
                    const SizedBox(height: 32),

                    // Photos Section
                    _buildSectionHeader(
                      context,
                      'Upload Photos',
                      Icons.camera_alt,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildPhotosStep(),
                    const SizedBox(height: 32),

                    // Next of Kin Section
                    _buildSectionHeader(
                      context,
                      'Next of Kin',
                      Icons.people,
                      Colors.purple,
                    ),
                    const SizedBox(height: 16),
                    _buildNextOfKinStep(),
                    const SizedBox(height: 32),

                    // Guarantor Section
                    _buildSectionHeader(
                      context,
                      'Guarantor Details',
                      Icons.shield,
                      Colors.teal,
                    ),
                    const SizedBox(height: 16),
                    _buildGuarantorStep(),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitApplication,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Submit Application',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.8),
            color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _fullNameController,
          label: 'Full Name',
          icon: Icons.person,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Full name is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Phone number is required';
            if (value!.length < 10) return 'Enter valid phone number';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nationalIdController,
          label: 'National ID Number',
          icon: Icons.badge,
          keyboardType: TextInputType.number,
          validator: (value) =>
              value?.isEmpty ?? true ? 'National ID is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _workingStationController,
          label: 'Working Station',
          icon: Icons.work,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Working station is required' : null,
        ),
      ],
    );
  }

  Widget _buildMotorcycleDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _numberPlateController,
          label: 'Number Plate',
          icon: Icons.pin,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Number plate is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _chassisNumberController,
          label: 'Chassis Number',
          icon: Icons.confirmation_number,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Chassis number is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _modelController,
          label: 'Model',
          icon: Icons.motorcycle,
          validator: (value) => value?.isEmpty ?? true ? 'Model is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _typeController,
          label: 'Type',
          icon: Icons.category,
          validator: (value) => value?.isEmpty ?? true ? 'Type is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _engineCCController,
          label: 'Engine CC',
          icon: Icons.speed,
          keyboardType: TextInputType.number,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Engine CC is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _colourController,
          label: 'Colour',
          icon: Icons.palette,
          validator: (value) => value?.isEmpty ?? true ? 'Colour is required' : null,
        ),
      ],
    );
  }

  Widget _buildPhotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageUpload(
          'Bike Photo',
          _bikePhoto,
          () => _pickImage('bike'),
          Icons.motorcycle,
        ),
        const SizedBox(height: 16),
        _buildImageUpload(
          'Logbook Photo (Security)',
          _logbookPhoto,
          () => _pickImage('logbook'),
          Icons.book,
        ),
        const SizedBox(height: 16),
        _buildImageUpload(
          'Passport Photo',
          _passportPhoto,
          () => _pickImage('passport'),
          Icons.person,
        ),
        const SizedBox(height: 16),
        _buildImageUpload(
          'ID Photo',
          _idPhoto,
          () => _pickImage('id'),
          Icons.badge,
        ),
      ],
    );
  }

  Widget _buildNextOfKinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _kinNameController,
          label: 'Next of Kin Name',
          icon: Icons.person_outline,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Next of kin name is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _kinPhoneController,
          label: 'Next of Kin Phone',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Phone number is required';
            if (value!.length < 10) return 'Enter valid phone number';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _kinRelationshipController,
          label: 'Relationship',
          icon: Icons.people,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Relationship is required' : null,
        ),
        const SizedBox(height: 16),
        _buildImageUpload(
          'Next of Kin ID Photo',
          _kinIdPhoto,
          () => _pickImage('kinId'),
          Icons.badge,
        ),
      ],
    );
  }

  Widget _buildGuarantorStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _guarantorNameController,
          label: 'Guarantor Name',
          icon: Icons.person_outline,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Guarantor name is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _guarantorPhoneController,
          label: 'Guarantor Phone',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Phone number is required';
            if (value!.length < 10) return 'Enter valid phone number';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _guarantorRelationshipController,
          label: 'Relationship',
          icon: Icons.people,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Relationship is required' : null,
        ),
        const SizedBox(height: 16),
        _buildImageUpload(
          'Guarantor ID Photo',
          _guarantorIdPhoto,
          () => _pickImage('guarantorId'),
          Icons.badge,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildImageUpload(
    String label,
    File? imageFile,
    VoidCallback onTap,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: imageFile != null
                      ? Colors.green.shade50
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        icon,
                        size: 32,
                        color: Colors.grey.shade600,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      imageFile != null ? 'Tap to change' : 'Tap to upload',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                imageFile != null ? Icons.check_circle : Icons.upload,
                color: imageFile != null ? Colors.green : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
