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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Adds padding around the content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Title
              Text(
                'Afterwords',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8), // Spacing between title and quote

              // Quote
              Text(
                '"Prepare your important thoughts, ready to reach others when the time comes."',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32), // Spacing between quote and button

              // Check-In Button
              SizedBox(
                width: double.infinity, // Makes the button stretch horizontally
                height: 60, // Fixed height for consistency
                child: ElevatedButton(
                  onPressed: _isCheckingIn ? null : _checkInUser,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.purple[200], // Button text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    elevation: 5, // Shadow elevation
                  ),
                  child: _isCheckingIn
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : const Text(
                    'Check In',
                    style: TextStyle(
                      fontSize: 20, // Larger text size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24), // Spacing between button and info box

              // Information Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0), // Padding inside the box
                decoration: BoxDecoration(
                  color: Colors.white10, // Background color of the box
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3), // Light grey shadow
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 3), // Changes position of shadow
                    ),
                  ],
                ),
                child: Text(
                  "Login to the app regularly, or use the 'Check In' button to prevent messages from being sent",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Optional: Additional content can go here
              // For example, displaying user information or other widgets
            ],
          ),
        ),
      ),
    );
  }
}
