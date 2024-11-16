// lib/models/add_recipient_request.dart

class AddRecipientRequest {
  final String username;
  final String recipientName;
  final String recipientEmail;
  final int messageId;

  AddRecipientRequest({
    required this.username,
    required this.recipientName,
    required this.recipientEmail,
    required this.messageId,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'recipientName': recipientName,
      'recipientEmail': recipientEmail,
      'messageId': messageId,
    };
  }
}
