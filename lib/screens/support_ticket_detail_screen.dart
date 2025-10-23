import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/support_ticket.dart';
import '../services/support_ticket_repository.dart';

class SupportTicketDetailScreen extends StatefulWidget {
  final int ticketId;

  const SupportTicketDetailScreen({
    super.key,
    required this.ticketId,
  });

  @override
  State<SupportTicketDetailScreen> createState() =>
      _SupportTicketDetailScreenState();
}

class _SupportTicketDetailScreenState extends State<SupportTicketDetailScreen> {
  final SupportTicketRepository _repository = SupportTicketRepository();
  final RxBool isLoading = true.obs;
  final Rx<SupportTicket?> ticket = Rx<SupportTicket?>(null);

  @override
  void initState() {
    super.initState();
    _loadTicketDetails();
  }

  Future<void> _loadTicketDetails() async {
    try {
      isLoading.value = true;
      final loadedTicket = await _repository.getTicketById(widget.ticketId);
      ticket.value = loadedTicket;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load ticket: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentTicket = ticket.value;
        if (currentTicket == null) {
          return const Center(child: Text('Ticket not found'));
        }

        return RefreshIndicator(
          onRefresh: _loadTicketDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentTicket.ticketNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            _buildStatusBadge(currentTicket.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoChip(
                              currentTicket.typeLabel,
                              _getTypeColor(currentTicket.type),
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              currentTicket.priority.toUpperCase(),
                              _getPriorityColor(currentTicket.priority),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Created',
                          _formatDateTime(currentTicket.createdAt),
                        ),
                        if (currentTicket.resolvedAt != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.check_circle_outline,
                            'Resolved',
                            _formatDateTime(currentTicket.resolvedAt!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Your ticket section
                Text(
                  'Your Ticket',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTicket.subject,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentTicket.message,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Contact information
                if (currentTicket.contactEmail != null ||
                    currentTicket.contactPhone != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (currentTicket.contactEmail != null)
                            _buildInfoRow(
                              Icons.email,
                              'Email',
                              currentTicket.contactEmail!,
                            ),
                          if (currentTicket.contactEmail != null &&
                              currentTicket.contactPhone != null)
                            const SizedBox(height: 8),
                          if (currentTicket.contactPhone != null)
                            _buildInfoRow(
                              Icons.phone,
                              'Phone',
                              currentTicket.contactPhone!,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Admin response section
                if (currentTicket.hasResponse) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Admin Response',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: const Icon(
                                  Icons.support_agent,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Support Team',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Man\'s Choice Enterprise',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentTicket.adminResponse!,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Waiting for admin response...',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'open':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'in_progress':
        color = Colors.blue;
        icon = Icons.timelapse;
        break;
      case 'resolved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'closed':
        color = Colors.grey;
        icon = Icons.close;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'bug':
        return Colors.red;
      case 'feature_request':
        return Colors.purple;
      case 'help':
        return Colors.blue;
      case 'complaint':
        return Colors.orange;
      case 'feedback':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red.shade700;
      case 'high':
        return Colors.orange.shade700;
      case 'medium':
        return Colors.blue.shade700;
      case 'low':
        return Colors.grey.shade700;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
