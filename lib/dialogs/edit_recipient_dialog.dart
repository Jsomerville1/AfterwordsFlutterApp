import 'package:flutter/material.dart';
import '../models/recipient.dart';
import '../models/edit_recipient_request.dart';
import '../services/api_service.dart';

class EditRecipientDialog extends StatefulWidget {
  final Recipient recipient;

  const EditRecipientDialog({super.key, required this.recipient});

  @override
  State<EditRecipientDialog> createState() => _EditRecipientDialogState();
}

class _EditRecipientDialogState extends State<EditRecipientDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.recipient.recipientName;
    _emailController.text = widget.recipient.recipientEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _editRecipient() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required.';
        _isLoading = false;
      });
      return;
    }

    try {
      EditRecipientRequest request = EditRecipientRequest(
        recipientId: widget.recipient.recipientId,
        messageId: widget.recipient.messageId, // Add this line
        recipientName: name,
        recipientEmail: email,
      );
      await _apiService.editRecipient(request);
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Recipient'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Recipient Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Recipient Name',
              ),
            ),
            const SizedBox(height: 8),
            // Recipient Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Recipient Email',
              ),
            ),
            const SizedBox(height: 16),
            // Error Message
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _editRecipient,
          child: _isLoading
              ? const SizedBox(
                  height: 16.0,
                  width: 16.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
