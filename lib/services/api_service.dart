// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../network/generic_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/verification_request.dart';
import '../models/verification_response.dart';
import '../models/message_response.dart';
import '../models/add_message_request.dart';
import '../models/edit_message_request.dart';
import '../models/add_recipient_request.dart';
import '../models/edit_recipient_request.dart';

class ApiService {
  static const String baseUrl = 'http://161.35.116.218:5000';



  // Delete User
  Future<GenericResponse> deleteUser(Map<String, dynamic> request) async {
    final url = Uri.parse('$baseUrl/api/deleteUsers');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );

    if (response.statusCode == 200) {
      return GenericResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to delete user');
    }
  }

  // Register User
  Future<RegisterResponse> registerUser(RegisterRequest request) async {
    final url = Uri.parse('$baseUrl/api/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return RegisterResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Registration failed. Please try again.');
    }
  }

  // Verify User
  Future<VerificationResponse> verifyUser(VerificationRequest request) async {
    final url = Uri.parse('$baseUrl/api/verify');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return VerificationResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Verification failed. Please try again.');
    }
  }

  // Login User
  Future<User?> loginUser(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Username': username, 'Password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['error'] == '') {
        // Successful login
        return User.fromJson(data);
      } else {
        // Login failed with error message
        throw Exception(data['error']);
      }
    } else {
      throw Exception('Failed to log in');
    }
  }


  // Fetch User Messages
  Future<MessageResponse> getUserMessages(int userId) async {
    final url = Uri.parse('$baseUrl/api/getUserMessages');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      return MessageResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch messages');
    }
  }



  // Add Message
  Future<void> addMessage(AddMessageRequest request) async {
    final url = Uri.parse('$baseUrl/api/addmessage');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add message');
    }
  }

  // Edit Message
  Future<void> editMessage(EditMessageRequest request) async {
    final url = Uri.parse('$baseUrl/api/editmessage');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit message');
    }
  }

  // Delete Message
  Future<void> deleteMessage(int messageId, int userId) async {
    final url = Uri.parse('$baseUrl/api/deletemessage');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'messageId': messageId, 'userId': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message');
    }
  }

  // Add Recipient
  Future<void> addRecipient(AddRecipientRequest request) async {
    final url = Uri.parse('$baseUrl/api/addRecipient');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add recipient');
    }
  }

  // Edit Recipient
  Future<void> editRecipient(EditRecipientRequest request) async {
    final url = Uri.parse('$baseUrl/api/editRecipient');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit recipient');
    }
  }

  // Delete Recipient
  Future<void> deleteRecipient(int recipientId) async {
    final url = Uri.parse('$baseUrl/api/deleteRecipient');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'recipientId': recipientId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete recipient');
    }
  }

  // Check In User
  Future<CheckInResponse> checkInUser(int userId) async {
    print("ApiService.checkInUser() called with UserId: $userId");

    final url = Uri.parse('$baseUrl/api/checkIn');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'UserId': userId}),
      );

      print("Check-In API Response Status: ${response.statusCode}");
      print("Check-In API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return CheckInResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to check in. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in ApiService.checkInUser(): $e");
      rethrow;
    }
  }



// Add other API methods as needed
}

// Define a CheckInResponse model
class CheckInResponse {
  final String message;
  final dynamic result; // Adjust type based on your server response
  final String? error;

  CheckInResponse({
    required this.message,
    this.result,
    this.error,
  });

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      message: json['message'],
      result: json['result'],
      error: json['error'],
    );
  }
}

// Define a DeleteUserResponse model
class DeleteUserResponse {
  final String? error;
  final String? message;

  DeleteUserResponse({
    this.error,
    this.message,
  });

  factory DeleteUserResponse.fromJson(Map<String, dynamic> json) {
    return DeleteUserResponse(
      error: json['error'],
      message: json['message'],
    );
  }
}