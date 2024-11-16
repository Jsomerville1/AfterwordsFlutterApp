// lib/dialogs/add_recipient_dialog.dart

import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../models/add_recipient_request.dart';
import '../services/api_service.dart';
import '../utils/shared_pref_manager.dart';

class AddRecipientDialog extends StatefulWidget {
  final Message message;

  const AddRecipientDialog({super.key, required this.message});

  @override
  _AddRecipientDialogState createState() => _AddRecipientDialogState();
}

class _AddRecipientDialogState extends State<AddRecipientDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  final SharedPrefManager _sharedPrefManager = SharedPrefManager();
  bool _isLoading = false;

  void _addRecipient() async {
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

    User? user = _sharedPrefManager.getUser();
    if (user == null) {
      Navigator.pop(context, false);
      return;
    }

    AddRecipientRequest request = AddRecipientRequest(
      username: user.username,
      recipientName: name,
      recipientEmail: email,
      messageId: widget.message.messageId,
    );

    try {
      await _apiService.addRecipient(request);
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding recipient: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Recipient'),
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
          onPressed: _isLoading ? null : _addRecipient,
          child: _isLoading ? const CircularProgressIndicator() : const Text('Add'),
        ),
      ],
    );
  }
}
