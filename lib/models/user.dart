class User {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final int checkInFreq;
  final bool verified;
  final bool? deceased;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final String error;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.checkInFreq,
    required this.verified,
    this.deceased,
    this.createdAt,
    this.lastLogin,
    required this.error,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      checkInFreq: json['checkInFreq'] ?? 0,
      verified: json['verified'] ?? false,
      deceased: json['deceased'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      error: json['error'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'checkInFreq': checkInFreq,
      'verified': verified,
      'deceased': deceased,
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'error': error,
    };
  }
}
