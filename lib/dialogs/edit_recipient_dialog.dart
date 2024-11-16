// lib/dialogs/edit_recipient_dialog.dart

import 'package:flutter/material.dart';
import '../models/recipient.dart';
import '../models/edit_recipient_request.dart';
import '../services/api_service.dart';

class EditRecipientDialog extends StatefulWidget {
  final Recipient recipient;

  const EditRecipientDialog({super.key, required this.recipient});

  @override
  _EditRecipientDialogState createState() => _EditRecipientDialogState();
}

class _EditRecipientDialogState extends State<EditRecipientDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.recipient.recipientName;
    _emailController.text = widget.recipient.recipientEmail;
  }

  void _editRecipient() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    EditRecipientRequest request = EditRecipientRequest(
      recipientId: widget.recipient.recipientId,
      messageId: widget.recipient.messageId,
      recipientName: name,
      recipientEmail: email,
    );

    try {
      await _apiService.editRecipient(request);
      widget.recipient.recipientName = name;
      widget.recipient.recipientEmail = email;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error editing recipient: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Recipient'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Recipient Name'),
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(hintText: 'Recipient Email'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _editRecipient,
          child: _isLoading ? const CircularProgressIndicator() : const Text('Save'),
        ),
      ],
    );
  }
}
