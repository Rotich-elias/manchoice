import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/support_ticket_repository.dart';
import 'support_tickets_screen.dart';

class SupportScreen extends StatelessWidget {
  SupportScreen({super.key});

  final SupportTicketRepository _supportRepository = SupportTicketRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support & Help'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Card(
                elevation: 4,
                child: Container(
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 60,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'How can we help you?',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'re here to assist you with any questions',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Contact Methods
              Text(
                'Contact Us',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                context,
                icon: Icons.phone,
                title: 'Call Us',
                subtitle: '+254 721 237 811',
                color: Colors.green,
                onTap: () => _makePhoneCall('+254721237811'),
              ),
              const SizedBox(height: 12),
              _buildContactCard(
                context,
                icon: Icons.email,
                title: 'Email Us',
                subtitle: 'support@manschoice.co.ke',
                color: Colors.blue,
                onTap: () => _sendEmail('support@manschoice.co.ke'),
              ),
              const SizedBox(height: 12),
              _buildContactCard(
                context,
                icon: Icons.chat,
                title: 'WhatsApp',
                subtitle: '+254 721 237 811',
                color: Colors.green.shade700,
                onTap: () => _openWhatsApp('+254721237811'),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
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
                      leading: Icon(
                        Icons.confirmation_number_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('My Support Tickets'),
                      subtitle: const Text('View your submitted tickets'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Get.to(() => const SupportTicketsScreen()),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('FAQs'),
                      subtitle: const Text('Frequently Asked Questions'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showFAQs(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.bug_report_outlined),
                      title: const Text('Report a Problem'),
                      subtitle: const Text('Let us know about any issues'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showReportProblemDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.feedback_outlined),
                      title: const Text('Send Feedback'),
                      subtitle: const Text('Help us improve'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showFeedbackDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Business Hours
              Text(
                'Business Hours',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildBusinessHourRow(
                        'Monday - Friday',
                        '8:00 AM - 6:00 PM',
                      ),
                      const Divider(),
                      _buildBusinessHourRow('Saturday', '9:00 AM - 4:00 PM'),
                      const Divider(),
                      _buildBusinessHourRow('Sunday', 'Closed'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Location
              Text(
                'Visit Us',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Our Office'),
                  subtitle: const Text('Nairobi CBD, Kenya\nTom Mboya Street'),
                  trailing: const Icon(Icons.map_outlined),
                  onTap: () {
                    Get.snackbar(
                      'Location',
                      'Map integration will be implemented',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessHourRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(hours, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch phone app',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request&body=Hello,',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch email app',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open WhatsApp',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showFAQs(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildFAQItem(
                'How do I apply for a loan?',
                'Go to Dashboard > Apply for Spare Parts Loan and fill out the application form.',
              ),
              _buildFAQItem(
                'What are the interest rates?',
                'Our interest rate is 5% per month on the principal amount.',
              ),
              _buildFAQItem(
                'How long does loan approval take?',
                'Loan applications are typically processed within 24-48 hours.',
              ),
              _buildFAQItem(
                'How can I make a payment?',
                'You can make payments via M-Pesa or card through the Payments section.',
              ),
              _buildFAQItem(
                'What happens if I miss a payment?',
                'Late payments may attract penalties. Contact support for assistance.',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(answer, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showReportProblemDialog(BuildContext context) {
    final problemController = TextEditingController();
    final subjectController = TextEditingController();
    final RxString selectedPriority = 'medium'.obs;
    final RxBool isSubmitting = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Report a Problem'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Subject:'),
              const SizedBox(height: 8),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  hintText: 'Brief summary of the issue',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Please describe the issue you\'re experiencing:'),
              const SizedBox(height: 8),
              TextField(
                controller: problemController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe the problem...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Priority:'),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                value: selectedPriority.value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                ],
                onChanged: (value) {
                  if (value != null) selectedPriority.value = value;
                },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isSubmitting.value
                ? null
                : () async {
                    if (subjectController.text.isEmpty ||
                        problemController.text.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please fill in all fields',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    isSubmitting.value = true;

                    try {
                      final response = await _supportRepository.submitTicket(
                        type: 'bug',
                        subject: subjectController.text,
                        message: problemController.text,
                        priority: selectedPriority.value,
                      );

                      Get.back();
                      Get.snackbar(
                        'Report Submitted',
                        'Ticket ${response['data']['ticket_number']} created. We\'ll investigate the issue.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 4),
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to submit report: ${e.toString()}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    } finally {
                      isSubmitting.value = false;
                    }
                  },
            child: isSubmitting.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          )),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();
    final subjectController = TextEditingController();
    final RxInt rating = 5.obs;
    final RxBool isSubmitting = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Send Feedback'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Subject:'),
              const SizedBox(height: 8),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  hintText: 'What is your feedback about?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('How would you rate our service?'),
              const SizedBox(height: 8),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating.value ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      rating.value = index + 1;
                    },
                  );
                }),
              )),
              const SizedBox(height: 16),
              const Text('Your feedback:'),
              const SizedBox(height: 8),
              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Tell us what you think...',
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
          Obx(() => ElevatedButton(
            onPressed: isSubmitting.value
                ? null
                : () async {
                    if (subjectController.text.isEmpty ||
                        feedbackController.text.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please fill in all fields',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    isSubmitting.value = true;

                    try {
                      final message = '${feedbackController.text}\n\nRating: ${rating.value}/5 stars';
                      final response = await _supportRepository.submitTicket(
                        type: 'feedback',
                        subject: subjectController.text,
                        message: message,
                        priority: 'low',
                      );

                      Get.back();
                      Get.snackbar(
                        'Thank You!',
                        'Ticket ${response['data']['ticket_number']} created. Your feedback helps us improve!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 4),
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to submit feedback: ${e.toString()}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    } finally {
                      isSubmitting.value = false;
                    }
                  },
            child: isSubmitting.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          )),
        ],
      ),
    );
  }
}
