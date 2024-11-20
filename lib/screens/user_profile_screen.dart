import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/shared_pref_manager.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final SharedPrefManager _sharedPrefManager = SharedPrefManager();
  final ApiService _apiService = ApiService();
  User? _user;

  final Map<String, int> _checkInOptions = {
    '2 Minutes': 120,
    '1 Week': 604800,
    '1 Month': 2592000,
    '1 Year': 31536000,
  };

  String? _selectedFrequency;

  @override
  void initState() {
    super.initState();
    _user = _sharedPrefManager.getUser();
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      _selectedFrequency = _checkInOptions.keys.firstWhere(
            (key) => _checkInOptions[key] == _user!.checkInFreq,
        orElse: () => '2 Minutes',
      );
    }
  }



  void _logout() async {
    await _sharedPrefManager.clearUser();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _performDeleteAccount();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _performDeleteAccount() async {
    if (_user == null) return;

    Map<String, dynamic> request = {
      'userId': _user!.id,
    };

    try {
      final response = await _apiService.deleteUser(request);
      if (response.error == null || response.error!.isEmpty) {
        await _sharedPrefManager.clearUser();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        _showToast('Failed to delete account: ${response.error}');
      }
    } catch (e) {
      _showToast('Error: ${e.toString()}');
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  void _updateCheckInFreq(int newFreq) async {
    if (_user == null) return;

    try {
      final response = await _apiService.updateCheckInFreq(_user!.id, newFreq);

      if (response.error == null) {
        setState(() {
          _user = _user!.copyWith(checkInFreq: newFreq);
        });
        _sharedPrefManager.updateUser(_user!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-In Frequency updated successfully!')),
        );
      } else {
        throw Exception(response.error);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating frequency: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${_user!.firstName} ${_user!.lastName}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('User ID: ${_user!.id}'),
            const SizedBox(height: 8),
            Text('Username: ${_user!.username}'),
            const SizedBox(height: 8),
            Text('Email: ${_user!.email}'),
            const SizedBox(height: 8),
            Text(
              'Check-In Frequency: ${_selectedFrequency ?? '2 Minutes'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              items: _checkInOptions.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  int newFreq = _checkInOptions[value]!;
                  setState(() {
                    _selectedFrequency = value;
                  });
                  _updateCheckInFreq(newFreq);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Change Check-In Frequency',
                border: OutlineInputBorder(),
              ),
            ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _logout,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: const Text('Logout'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _deleteAccount,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete Account'),
        )],
        ),
      ),
    );
  }
}
