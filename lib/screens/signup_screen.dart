import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

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

  bool _isLoading = false;

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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate that all images are uploaded
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

    setState(() {
      _isLoading = true;
    });

    // TODO: Save data locally or send to API
    // For now, just simulate a save operation
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    Get.snackbar(
      'Success',
      'Registration submitted successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Navigate back to login screen
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Logo
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'lib/assets/images/logo.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'MAN\'S CHOICE ENTERPRISE',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Credit Application Form',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 32),

                // Personal Information Section
                _buildSectionHeader('Personal Information'),
                const SizedBox(height: 16),
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
                    if (value?.isEmpty ?? true) {
                      return 'Phone number is required';
                    }
                    if (value!.length < 10) {
                      return 'Enter a valid phone number';
                    }
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
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Working station is required'
                      : null,
                ),
                const SizedBox(height: 32),

                // Motorcycle Details Section
                _buildSectionHeader('Motorcycle Details'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _numberPlateController,
                  label: 'Number Plate',
                  icon: Icons.confirmation_number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Number plate is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _chassisNumberController,
                  label: 'Chassis Number',
                  icon: Icons.pin,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Chassis number is required'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _modelController,
                  label: 'Model',
                  icon: Icons.motorcycle,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Model is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _typeController,
                  label: 'Type',
                  icon: Icons.category,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Type is required' : null,
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
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Colour is required' : null,
                ),
                const SizedBox(height: 32),

                // Photo Uploads Section
                _buildSectionHeader('Photo Uploads'),
                const SizedBox(height: 16),
                _buildImageUpload(
                  'Bike Photo',
                  _bikePhoto,
                  () => _pickImage('bike'),
                  Icons.motorcycle,
                ),
                const SizedBox(height: 16),
                _buildImageUpload(
                  'Logbook Photo',
                  _logbookPhoto,
                  () => _pickImage('logbook'),
                  Icons.description,
                ),
                const SizedBox(height: 16),
                _buildImageUpload(
                  'Passport Photo',
                  _passportPhoto,
                  () => _pickImage('passport'),
                  Icons.photo_camera,
                ),
                const SizedBox(height: 16),
                _buildImageUpload(
                  'ID Photo',
                  _idPhoto,
                  () => _pickImage('id'),
                  Icons.badge,
                ),
                const SizedBox(height: 32),

                // Next of Kin Section
                _buildSectionHeader('Next of Kin Details'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _kinNameController,
                  label: 'Next of Kin Name',
                  icon: Icons.person_outline,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Next of kin name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _kinPhoneController,
                  label: 'Next of Kin Phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Next of kin phone is required';
                    }
                    if (value!.length < 10) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _kinRelationshipController,
                  label: 'Relationship',
                  icon: Icons.family_restroom,
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
                const SizedBox(height: 32),

                // Guarantor Section
                _buildSectionHeader('Guarantor Details'),
                const SizedBox(height: 16),
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
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Guarantor phone is required';
                    }
                    if (value!.length < 10) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _guarantorRelationshipController,
                  label: 'Relationship',
                  icon: Icons.family_restroom,
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
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),

                // Back to Login
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
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
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      imageFile != null ? 'Photo selected' : 'Tap to upload',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: imageFile != null
                                ? Colors.green
                                : Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                imageFile != null ? Icons.check_circle : Icons.upload,
                color: imageFile != null
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
