// lib/screens/message_screen.dart

import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/message_response.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/shared_pref_manager.dart';
import '../widgets/message_item.dart';
import 'user_profile_screen.dart';
import '../dialogs/add_message_dialog.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ApiService _apiService = ApiService();
  final SharedPrefManager _sharedPrefManager = SharedPrefManager();

  List<Message> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  void _fetchMessages() async {
    User? user = _sharedPrefManager.getUser();
    if (user == null) {
      // Navigate back to login if user is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserProfileScreen()),
      );
      return;
    }

    try {
      MessageResponse response = await _apiService.getUserMessages(user.id);
      setState(() {
        _messages = response.messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching messages: ${e.toString()}')),
      );
    }
  }

  void _showAddMessageDialog() async {
    bool result = await showDialog(
      context: context,
      builder: (context) => AddMessageDialog(),
    );

    if (result == true) {
      _fetchMessages();
    }
  }

  void _returnToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _returnToProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
          ? const Center(child: Text('No messages found'))
          : ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          return MessageItem(
            message: _messages[index],
            onDelete: _fetchMessages,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMessageDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
