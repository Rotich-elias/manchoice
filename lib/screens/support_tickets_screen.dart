import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/support_ticket.dart';
import '../services/support_ticket_repository.dart';
import 'support_ticket_detail_screen.dart';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  final SupportTicketRepository _repository = SupportTicketRepository();
  final RxBool isLoading = true.obs;
  final RxList<SupportTicket> tickets = <SupportTicket>[].obs;
  final RxString selectedFilter = 'all'.obs;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets({String? status}) async {
    try {
      isLoading.value = true;
      final loadedTickets = await _repository.getUserTickets(status: status);
      tickets.value = loadedTickets;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tickets: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _filterTickets(String filter) {
    selectedFilter.value = filter;
    if (filter == 'all') {
      _loadTickets();
    } else {
      _loadTickets(status: filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Support Tickets'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Open', 'open'),
                  const SizedBox(width: 8),
                  _buildFilterChip('In Progress', 'in_progress'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Resolved', 'resolved'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Closed', 'closed'),
                ],
              ),
            )),
          ),

          // Tickets list
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (tickets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tickets found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a ticket to get started',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _loadTickets(
                  status: selectedFilter.value == 'all' ? null : selectedFilter.value,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return _buildTicketCard(ticket);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _filterTickets(value);
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Get.to(() => SupportTicketDetailScreen(ticketId: ticket.id));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Ticket number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ticket.ticketNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  _buildStatusBadge(ticket.status),
                ],
              ),
              const SizedBox(height: 12),

              // Subject
              Text(
                ticket.subject,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              // Message preview
              Text(
                ticket.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Footer: Type, priority, and date
              Row(
                children: [
                  _buildInfoChip(
                    ticket.typeLabel,
                    _getTypeColor(ticket.type),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    ticket.priority.toUpperCase(),
                    _getPriorityColor(ticket.priority),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(ticket.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              // Show response indicator if available
              if (ticket.hasResponse) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Admin has responded',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'open':
        color = Colors.orange;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'resolved':
        color = Colors.green;
        break;
      case 'closed':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
