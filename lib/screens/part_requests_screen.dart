import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/part_request.dart';
import '../services/part_request_repository.dart';

class PartRequestsScreen extends StatefulWidget {
  const PartRequestsScreen({super.key});

  @override
  State<PartRequestsScreen> createState() => _PartRequestsScreenState();
}

class _PartRequestsScreenState extends State<PartRequestsScreen> {
  final PartRequestRepository _repository = PartRequestRepository();
  List<PartRequest> _requests = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, pending, in_progress, available, fulfilled, cancelled

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _repository.getMyRequests();
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to load requests: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  List<PartRequest> get filteredRequests {
    if (_filter == 'all') return _requests;
    return _requests.where((r) => r.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Part Requests'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', _requests.length),
                  _buildFilterChip('Pending', 'pending', _requests.where((r) => r.isPending).length),
                  _buildFilterChip('In Progress', 'in_progress', _requests.where((r) => r.isInProgress).length),
                  _buildFilterChip('Available', 'available', _requests.where((r) => r.isAvailable).length),
                  _buildFilterChip('Fulfilled', 'fulfilled', _requests.where((r) => r.isFulfilled).length),
                  _buildFilterChip('Cancelled', 'cancelled', _requests.where((r) => r.isCancelled).length),
                ],
              ),
            ),
          ),

          // Requests list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadRequests,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            return _buildRequestCard(filteredRequests[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _filter = value);
        },
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _filter == 'all'
                ? 'No part requests yet'
                : 'No ${_filter.replaceAll('_', ' ')} requests',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Request parts you need from the Products screen',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(PartRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showRequestDetails(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and urgency
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      request.partName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(request.status),
                ],
              ),
              const SizedBox(height: 8),

              // Motorcycle model
              if (request.motorcycleModel != null)
                Row(
                  children: [
                    Icon(Icons.motorcycle, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      '${request.motorcycleModel}${request.year != null ? ' (${request.year})' : ''}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),

              // Quantity and budget
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.numbers, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Qty: ${request.quantity}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  if (request.budget != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Budget: KSh ${request.budget!.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ],
              ),

              // Urgency and date
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildUrgencyBadge(request.urgency),
                  Text(
                    _formatDate(request.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),

              // Admin notes if available
              if (request.adminNotes != null && request.adminNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.admin_panel_settings, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.adminNotes!,
                          style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Actions
              if (request.isPending || request.isInProgress) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _cancelRequest(request),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Cancel Request'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
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
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'in_progress':
        color = Colors.blue;
        icon = Icons.sync;
        break;
      case 'available':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'fulfilled':
        color = Colors.purple;
        icon = Icons.done_all;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyBadge(String urgency) {
    Color color;
    switch (urgency) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${urgency.toUpperCase()} URGENCY',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
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

  void _showRequestDetails(PartRequest request) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            const Expanded(child: Text('Request Details')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Part Name', request.partName, Icons.settings),
              if (request.description != null)
                _buildDetailRow('Description', request.description!, Icons.description),
              if (request.motorcycleModel != null)
                _buildDetailRow('Motorcycle', request.motorcycleModel!, Icons.motorcycle),
              if (request.year != null)
                _buildDetailRow('Year', request.year!, Icons.calendar_today),
              _buildDetailRow('Quantity', request.quantity.toString(), Icons.numbers),
              if (request.budget != null)
                _buildDetailRow('Budget', 'KSh ${request.budget!.toStringAsFixed(0)}', Icons.attach_money),
              _buildDetailRow('Urgency', request.urgencyText, Icons.priority_high),
              _buildDetailRow('Status', request.statusText, Icons.flag),
              _buildDetailRow('Requested', _formatDate(request.createdAt), Icons.access_time),
              if (request.adminNotes != null && request.adminNotes!.isNotEmpty)
                _buildDetailRow('Admin Notes', request.adminNotes!, Icons.admin_panel_settings),
              if (request.imageUrl != null) ...[
                const Divider(height: 24),
                const Text('Attached Image:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    request.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image, size: 50)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (request.isPending || request.isInProgress)
            TextButton.icon(
              onPressed: () {
                Get.back();
                _cancelRequest(request);
              },
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Cancel Request', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRequest(PartRequest request) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Request?'),
        content: Text('Are you sure you want to cancel the request for "${request.partName}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      await _repository.cancelRequest(request.id);
      Get.back(); // Close loading
      Get.snackbar(
        'Success',
        'Request cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _loadRequests(); // Refresh list
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
