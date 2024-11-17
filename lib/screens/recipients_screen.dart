import 'package:flutter/material.dart';
import '../models/recipient.dart';
import '../models/recipient_response.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/shared_pref_manager.dart';
import '../dialogs/edit_recipient_dialog.dart'; // Only import edit dialog

class RecipientsScreen extends StatefulWidget {
  const RecipientsScreen({super.key});

  @override
  State<RecipientsScreen> createState() => _RecipientsScreenState();
}

class _RecipientsScreenState extends State<RecipientsScreen> {
  final ApiService _apiService = ApiService();
  final SharedPrefManager _sharedPrefManager = SharedPrefManager();

  List<Recipient> _recipients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipients();
  }

  void _fetchRecipients() async {
    User? user = _sharedPrefManager.getUser();
    if (user == null) {
      // Handle user not logged in
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      RecipientResponse response =
      await _apiService.getUserRecipients(user.id);
      setState(() {
        _recipients = response.recipients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recipients: ${e.toString()}')),
      );
    }
  }

  void _showEditRecipientDialog(Recipient recipient) async {
    bool? result = await showDialog(
      context: context,
      builder: (context) => EditRecipientDialog(recipient: recipient),
    );

    if (result == true) {
      _fetchRecipients();
    }
  }

  void _deleteRecipient(int recipientId) async {
    try {
      await _apiService.deleteRecipient(recipientId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipient deleted successfully')),
      );
      _fetchRecipients();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting recipient: ${e.toString()}')),
      );
    }
  }

  void _confirmDeleteRecipient(int recipientId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipient'),
        content: const Text('Are you sure you want to delete this recipient?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _deleteRecipient(recipientId);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipients'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipients.isEmpty
          ? const Center(child: Text('No recipients found'))
          : ListView.builder(
        itemCount: _recipients.length,
        itemBuilder: (context, index) {
          final recipient = _recipients[index];
          return ListTile(
            title: Text(recipient.recipientName),
            subtitle: Text(recipient.recipientEmail),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditRecipientDialog(recipient);
                } else if (value == 'delete') {
                  _confirmDeleteRecipient(recipient.recipientId);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          );
        },
      ),
      // Removed the FloatingActionButton for adding recipients
    );
  }
}
