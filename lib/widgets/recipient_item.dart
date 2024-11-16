// lib/widgets/recipient_item.dart

import 'package:flutter/material.dart';
import '../models/recipient.dart';
import '../services/api_service.dart';
import '../dialogs/edit_recipient_dialog.dart';

class RecipientItem extends StatefulWidget {
  final Recipient recipient;

  const RecipientItem({
    super.key,
    required this.recipient,
  });

  @override
  State<RecipientItem> createState() => _RecipientItemState();
}

class _RecipientItemState extends State<RecipientItem> {
  final ApiService _apiService = ApiService();

  void _editRecipient() async {
    bool result = await showDialog(
      context: context,
      builder: (context) => EditRecipientDialog(recipient: widget.recipient),
    );

    if (result == true) {
      setState(() {}); // Refresh the recipient details
    }
  }

  void _deleteRecipient() async {
    try {
      await _apiService.deleteRecipient(widget.recipient.recipientId);
      setState(() {
        // Remove the recipient from the list
      });
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting recipient: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.recipient.recipientName),
      subtitle: Text(widget.recipient.recipientEmail),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editRecipient,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteRecipient,
          ),
        ],
      ),
    );
  }
}
