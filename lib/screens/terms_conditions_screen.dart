import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.description,
                      size: 60,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'MAN\'S CHOICE ENTERPRISE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Requirements Section
              _buildSectionTitle('MEMBERSHIP REQUIREMENTS'),
              const SizedBox(height: 16),
              _buildRequirement(
                '1',
                'National Identity',
                'Be a holder of national identity card (must provide copy of the Original).',
                Icons.badge,
                Colors.blue,
              ),
              _buildRequirement(
                '2',
                'Legal Ownership',
                'Be the legal owner of the motorcycle (the names in the log book and the ID must be the same).',
                Icons.how_to_reg,
                Colors.green,
              ),
              _buildRequirement(
                '3',
                'Boda Boda Stage Member',
                'Be a member of boda boda stage and should be recognised by the stage chairperson.',
                Icons.groups,
                Colors.orange,
              ),
              _buildRequirement(
                '4',
                'Full-time Operator',
                'Should be a fully boda boda operator as your occupation.',
                Icons.work,
                Colors.purple,
              ),
              _buildRequirement(
                '5',
                'Registration Fee',
                'Provide a registration fee of Ksh 300/- (first customers must provide 10% deposit of the first product).',
                Icons.payments,
                Colors.teal,
              ),
              _buildRequirement(
                '6',
                'Guarantors',
                'Provide at least TWO guarantors:\n• One must be your work mate from your working stage\n• Another to be Next of Kin or optional',
                Icons.people,
                Colors.indigo,
              ),

              const SizedBox(height: 32),
              const Divider(thickness: 2),
              const SizedBox(height: 32),

              // Policy Section
              _buildSectionTitle('POLICY & REGULATIONS'),
              const SizedBox(height: 16),

              _buildPolicy(
                '1',
                'Minimum Payment Requirement',
                'One MUST make a payment NOT LESS THAN Ksh 200/- as per signed agreement.',
                Icons.money_off,
                Colors.red,
              ),
              _buildPolicy(
                '2',
                'Payment Timeline',
                'One must pay as per time given (duration) e.g., 3 weeks.\n\nFAILURE TO PAY: Leads to 1% interest daily effective from the last due date BUT NOT more than 2 weeks of penalty.',
                Icons.schedule,
                Colors.orange,
              ),
              _buildPolicy(
                '3',
                'Guarantor Liability',
                'Failure to make payment: The guarantor and the next of kin are liable to the debt (within two weeks timeline).',
                Icons.warning,
                Colors.deepOrange,
              ),
              _buildPolicy(
                '4',
                'Legal Action',
                'Failure by the owner, next of kin, AND guarantor: The stage chairperson will be contacted and the file forwarded to the legal team (company lawyer) for further action via the recovery team.',
                Icons.gavel,
                Colors.red.shade900,
              ),
              _buildPolicy(
                '5',
                'Security Requirement',
                'The motorcycle log book SHALL act as security for the loan.',
                Icons.security,
                Colors.blueGrey,
              ),

              const SizedBox(height: 32),

              // Important Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade300, width: 2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info, color: Colors.red.shade700, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IMPORTANT NOTICE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'By registering and using this service, you acknowledge that you have read, understood, and agree to comply with all the terms and conditions outlined above.\n\nFailure to comply may result in legal action and debt recovery proceedings.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade800,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Contact Information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contact_phone, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Contact Us',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildContactRow(Icons.phone, '+254 011 0846 828'),
                    const SizedBox(height: 8),
                    _buildContactRow(Icons.email, 'info@manschoice.co.ke'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Close Button
              if (Get.arguments != null && Get.arguments['showAcceptButton'] == true)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(result: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'I Accept Terms & Conditions',
                      style: TextStyle(
                        fontSize: 16,
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.article, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(
    String number,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicy(
    String number,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
