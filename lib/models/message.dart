// lib/models/message.dart

import 'recipient.dart';

class Message {
  final int messageId;
  final int userId;
  String content;
  final bool isSent;
  final DateTime? createdAt;
  final DateTime? sendAt;
  List<Recipient> recipients;

  Message({
    required this.messageId,
    required this.userId,
    required this.content,
    required this.isSent,
    this.createdAt,
    this.sendAt,
    required this.recipients,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'],
      userId: json['userId'],
      content: json['content'],
      isSent: json['isSent'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      sendAt: json['sendAt'] != null ? DateTime.parse(json['sendAt']) : null,
      recipients: (json['recipients'] as List<dynamic>?)
          ?.map((e) => Recipient.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'userId': userId,
      'content': content,
      'isSent': isSent,
      'createdAt': createdAt?.toIso8601String(),
      'sendAt': sendAt?.toIso8601String(),
      'recipients': recipients.map((e) => e.toJson()).toList(),
    };
  }
}
