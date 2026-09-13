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
}
