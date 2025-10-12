import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/customer_repository.dart';
import '../services/loan_repository.dart';
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
  int _currentStep = 0;
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
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        setState(() {
          switch (imageType) {
            case 'bike':
              _bikePhoto = File(pickedFile.path);
              break;
            case 'logbook':
              _logbookPhoto = File(pickedFile.path);
              break;
            case 'passport':
              _passportPhoto = File(pickedFile.path);
              break;
            case 'id':
              _idPhoto = File(pickedFile.path);
              break;
            case 'kinId':
              _kinIdPhoto = File(pickedFile.path);
              break;
            case 'guarantorId':
              _guarantorIdPhoto = File(pickedFile.path);
              break;
          }
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
      final loanRepo = LoanRepository();

      // Step 1: Create or Update customer with complete application info
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

      // Step 2: Create loan application with photo paths
      final loan = await loanRepo.createLoan(
        customerId: customer.id,
        principalAmount: 0.0, // Will be set after product selection
        interestRate: 30.0, // 30% default
        durationDays: 30, // 30 days default
        purpose: 'Motorcycle Loan Application',
        notes: 'Application submitted from mobile app. Pending admin verification.',
        bikePhotoPath: _bikePhoto!.path,
        logbookPhotoPath: _logbookPhoto!.path,
        passportPhotoPath: _passportPhoto!.path,
        idPhotoPath: _idPhoto!.path,
        nextOfKinIdPhotoPath: _kinIdPhoto!.path,
        guarantorIdPhotoPath: _guarantorIdPhoto!.path,
      );

      if (loan == null) {
        throw Exception('Failed to create loan application');
      }

      // Step 3: Mark user's profile as completed
      final authService = AuthService();
      await authService.completeProfile(customerId: customer.id);

      if (!mounted) return;

      // If coming from cart, associate cart with loan and return to cart
      if (_fromCart && _cartService != null) {
        _cartService!.setLoanContext(
          loanId: loan.id,
          customerId: customer.id,
        );

        Get.snackbar(
          'Success',
          'Profile completed! Continue to checkout.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(seconds: 1));
        Get.back(); // Return to cart/products screen
      } else {
        // Default flow: Show success and navigate to products
        Get.snackbar(
          'Success',
          'Profile completed! Now select products.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(seconds: 1));
        Get.offNamed('/products', arguments: {
          'loanId': loan.id,
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
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < 4) {
                    setState(() => _currentStep++);
                  } else {
                    _submitApplication();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                  }
                },
                onStepTapped: (step) => setState(() => _currentStep = step),
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : details.onStepContinue,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_currentStep == 4 ? 'Submit' : 'Continue'),
                        ),
                        const SizedBox(width: 12),
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: _isSubmitting ? null : details.onStepCancel,
                            child: const Text('Back'),
                          ),
                      ],
                    ),
                  );
                },
                steps: [
                  // Step 1: Personal Information
                  Step(
                    title: const Text('Personal Information'),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                    content: _buildPersonalInfoStep(),
                  ),
                  // Step 2: Motorcycle Details
                  Step(
                    title: const Text('Motorcycle Details'),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                    content: _buildMotorcycleDetailsStep(),
                  ),
                  // Step 3: Photos
                  Step(
                    title: const Text('Upload Photos'),
                    isActive: _currentStep >= 2,
                    state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                    content: _buildPhotosStep(),
                  ),
                  // Step 4: Next of Kin
                  Step(
                    title: const Text('Next of Kin'),
                    isActive: _currentStep >= 3,
                    state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                    content: _buildNextOfKinStep(),
                  ),
                  // Step 5: Guarantor
                  Step(
                    title: const Text('Guarantor Details'),
                    isActive: _currentStep >= 4,
                    state: StepState.indexed,
                    content: _buildGuarantorStep(),
                  ),
                ],
              ),
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
