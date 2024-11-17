import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/shared_pref_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SharedPrefManager _sharedPrefManager = SharedPrefManager();
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isCheckingIn = false;

  @override
  void initState() {
    super.initState();
    _user = _sharedPrefManager.getUser();
    if (_user == null) {
      // Handle user not logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  void _checkInUser() async {
    if (_user == null) return;

    setState(() {
      _isCheckingIn = true;
    });

    try {
      // Call the API to update lastLogin
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check In successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check In failed: ${response.error}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isCheckingIn = false;
      });
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
      body: Column(
        children: [
          // Check In Button
          GestureDetector(
            onTap: _isCheckingIn ? null : _checkInUser,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.2, // 1/5 of the view
              color: Colors.grey[800],
              alignment: Alignment.center,
              child: _isCheckingIn
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text(
                'Check In',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          // Additional content can go here
        ],
      ),
    );
  }
}
