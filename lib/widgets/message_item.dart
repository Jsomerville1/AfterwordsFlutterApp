// lib/widgets/message_item.dart

import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../dialogs/edit_message_dialog.dart';
import '../dialogs/add_recipient_dialog.dart';
import 'recipient_item.dart';

class MessageItem extends StatefulWidget {
  final Message message;
  final VoidCallback onDelete;

  const MessageItem({
    super.key,
    required this.message,
    required this.onDelete,
  });

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  final ApiService _apiService = ApiService();
  bool _isRecipientsVisible = false;

  void _toggleRecipientsVisibility() {
    setState(() {
      _isRecipientsVisible = !_isRecipientsVisible;
    });
  }

  void _editMessage() async {
    bool result = await showDialog(
      context: context,
      builder: (context) => EditMessageDialog(message: widget.message),
    );

    if (result == true) {
      setState(() {}); // Refresh the message content
    }
  }

  void _deleteMessage() async {
    try {
      await _apiService.deleteMessage(widget.message.messageId, widget.message.userId);
      widget.onDelete();
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message: ${e.toString()}')),
      );
    }
  }

  void _addRecipient() async {
    bool result = await showDialog(
      context: context,
      builder: (context) => AddRecipientDialog(message: widget.message),
    );

    if (result == true) {
      setState(() {}); // Refresh the recipients list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(widget.message.content),
        subtitle: Text('Created at: ${widget.message.createdAt}'),
        children: [
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _editMessage,
                child: const Text('Edit'),
              ),
              TextButton(
                onPressed: _deleteMessage,
                child: const Text('Delete'),
              ),
              TextButton(
                onPressed: _addRecipient,
                child: const Text('Add Recipient'),
              ),
            ],
          ),
          if (_isRecipientsVisible)
            Column(
              children: widget.message.recipients
                  .map((recipient) => RecipientItem(recipient: recipient))
                  .toList(),
            ),
          TextButton(
            onPressed: _toggleRecipientsVisibility,
            child: Text(_isRecipientsVisible ? 'Hide Recipients' : 'Show Recipients'),
          ),
        ],
      ),
    );
  }
}
