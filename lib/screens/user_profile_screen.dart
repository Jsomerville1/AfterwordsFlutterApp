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
  bool _isCheckingIn = false;

  @override
  void initState() {
    super.initState();
    _user = _sharedPrefManager.getUser();
    if (_user == null) {
      // User not logged in, navigate to LoginScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
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

  void _checkInUser() async {
    if (_user == null) return;

    setState(() {
      _isCheckingIn = true;
    });

    try {
      final response = await _apiService.checkInUser(_user!.id);

      if (response.error == null || response.error!.isEmpty) {
        // Update the user data locally
        setState(() {
          _user = User(
            id: _user!.id,
            firstName: _user!.firstName,
            lastName: _user!.lastName,
            username: _user!.username,
            email: _user!.email,
            checkInFreq: _user!.checkInFreq + 1,
            verified: _user!.verified,
            deceased: _user!.deceased,
            createdAt: _user!.createdAt,
            lastLogin: DateTime.now(),
            error: '',
          );
        });

        await _sharedPrefManager.updateUser(_user!);

        _showToast('You checked in successfully!');
      } else {
        _showToast('Check In failed: ${response.error}');
      }
    } catch (e) {
      _showToast('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isCheckingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      // Show a loading indicator while redirecting
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Information
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
            Text('Check-In Frequency: ${_user!.checkInFreq}'),
            const SizedBox(height: 8),
            Text('Verified: ${_user!.verified ? 'Yes' : 'No'}'),
            const SizedBox(height: 8),
            Text('Deceased: ${_user!.deceased == true ? 'Yes' : 'No'}'),
            const SizedBox(height: 8),
            Text('Account Created At: ${_user!.createdAt}'),
            const SizedBox(height: 8),
            Text('Last Login: ${_user!.lastLogin}'),
            const SizedBox(height: 16),
            // Buttons
            ElevatedButton(
              onPressed: _isCheckingIn ? null : _checkInUser,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: _isCheckingIn
                  ? const SizedBox(
                height: 16.0,
                width: 16.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.0,
                ),
              )
                  : const Text('Check In'),
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
            ),
          ],
        ),
      ),
    );
  }
}
