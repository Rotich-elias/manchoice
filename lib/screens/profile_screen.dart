import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual user data from authentication/database
    const String userName = 'John Doe';
    const String userPhone = '+254 712 345 678';
    const String userEmail = 'john.doe@example.com';
    const String nationalId = '12345678';
    const String workStation = 'Nairobi CBD';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.snackbar(
                'Edit Profile',
                'Edit profile functionality will be implemented',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userPhone,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),

              // Personal Information Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      context,
                      icon: Icons.email,
                      title: 'Email',
                      value: userEmail,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      icon: Icons.badge,
                      title: 'National ID',
                      value: nationalId,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      icon: Icons.work,
                      title: 'Work Station',
                      value: workStation,
                    ),
                    const SizedBox(height: 24),

                    // Motorcycle Information
                    Text(
                      'Motorcycle Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.motorcycle),
                        title: const Text('My Motorcycle'),
                        subtitle: const Text('View motorcycle details'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Get.snackbar(
                            'Motorcycle Details',
                            'Feature will be implemented',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Account Settings
                    Text(
                      'Account Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.lock_outline),
                            title: const Text('Change Password'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              _showChangePasswordDialog(context);
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.notifications_outlined),
                            title: const Text('Notification Settings'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Get.snackbar(
                                'Notifications',
                                'Notification settings will be implemented',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.security_outlined),
                            title: const Text('Privacy & Security'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Get.snackbar(
                                'Privacy & Security',
                                'Privacy settings will be implemented',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Danger Zone
                    Text(
                      'Danger Zone',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.delete_outline, color: Colors.red),
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.red),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showDeleteAccountDialog(context);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Password Changed',
                'Password change functionality will be implemented',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('This action cannot be undone. All your data will be permanently deleted.'),
            SizedBox(height: 8),
            Text(
              '• Active loans will be settled',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '• Payment history will be lost',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '• Account cannot be recovered',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Account Deletion',
                'Account deletion requires verification - feature will be implemented',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
