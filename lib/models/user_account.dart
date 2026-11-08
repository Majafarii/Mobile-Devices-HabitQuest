/// A registered HabitQuest account.
///
/// The password itself is never stored; only a salted hash of it.
class UserAccount {
  const UserAccount({
    required this.username,
    required this.displayName,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });

  /// Unique, lowercase identifier used to sign in and to key saved data.
  final String username;
  final String displayName;
  final String email;
  final String passwordHash;
  final String salt;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'username': username,
    'displayName': displayName,
    'email': email,
    'passwordHash': passwordHash,
    'salt': salt,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      username: json['username'] as String,
      displayName: json['displayName'] as String? ?? json['username'] as String,
      email: json['email'] as String? ?? '',
      passwordHash: json['passwordHash'] as String,
      salt: json['salt'] as String,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
