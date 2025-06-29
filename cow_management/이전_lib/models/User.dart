class User {
  final String? id;
  final String username;    // 사용자 이름/실명 (기존 username)
  final String userId;      // 로그인용 아이디 (기존 email)
  final String email;       // 이메일
  final String? farmNickname; // 목장 별명 (기존 farmName)
  final String? farmId;
  final String? createdAt;
  final bool isActive;

  User({
    this.id,
    required this.username,
    required this.userId,
    required this.email,
    this.farmNickname,
    this.farmId,
    this.createdAt,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      username: json['username'] ?? '',      // 사용자 이름/실명
      userId: json['user_id'] ?? '',          // 로그인용 아이디
      email: json['email'] ?? '',             // 이메일
      farmNickname: json['farm_nickname'],    // 목장 별명
      farmId: json['farm_id']?.toString(),
      createdAt: json['created_at'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,        // 사용자 이름/실명
      'user_id': userId,           // 로그인용 아이디
      'email': email,              // 이메일
      'farm_nickname': farmNickname, // 목장 별명
      'farm_id': farmId,
      'created_at': createdAt,
      'is_active': isActive,
    };
  }

  // 기존 코드와의 호환성을 위한 getter (필요시)
  String get farmName => farmNickname ?? '';
}