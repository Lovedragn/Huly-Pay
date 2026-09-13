class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? authProvider;
  final bool active;

  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.avatarUrl,
    this.authProvider,
    this.active = true,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      authProvider: json['authProvider'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'authProvider': authProvider,
      'active': active,
    };
  }

  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) return fullName!.trim();
    final parts = [firstName, lastName].where((p) => p != null && p.trim().isNotEmpty).join(' ');
    if (parts.isNotEmpty) return parts;
    if (email.isNotEmpty) return email.split('@').first;
    return 'User';
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? avatarUrl,
    String? authProvider,
    bool? active,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authProvider: authProvider ?? this.authProvider,
      active: active ?? this.active,
    );
  }
}
