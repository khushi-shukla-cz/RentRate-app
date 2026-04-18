class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final double trustScore;
  final double averageRating;
  final int totalReviews;
  final String avatar;
  final String bio;
  final bool isVerified;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.trustScore = 0,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.avatar = '',
    this.bio = '',
    this.isVerified = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'tenant',
      trustScore: (json['trustScore'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      avatar: json['avatar'] ?? '',
      bio: json['bio'] ?? '',
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'trustScore': trustScore,
    'averageRating': averageRating,
    'totalReviews': totalReviews,
    'avatar': avatar,
    'bio': bio,
    'isVerified': isVerified,
  };

  bool get isOwner => role == 'owner';
  bool get isTenant => role == 'tenant';

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
