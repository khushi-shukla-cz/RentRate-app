import 'user_model.dart';

class RatingCategories {
  final double behavior;
  final double communication;
  final double cleanliness;
  final double payment;
  final double maintenance;

  RatingCategories({
    this.behavior = 5,
    this.communication = 5,
    this.cleanliness = 5,
    this.payment = 5,
    this.maintenance = 5,
  });

  factory RatingCategories.fromJson(Map<String, dynamic> json) => RatingCategories(
    behavior: (json['behavior'] ?? 5).toDouble(),
    communication: (json['communication'] ?? 5).toDouble(),
    cleanliness: (json['cleanliness'] ?? 5).toDouble(),
    payment: (json['payment'] ?? 5).toDouble(),
    maintenance: (json['maintenance'] ?? 5).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'behavior': behavior,
    'communication': communication,
    'cleanliness': cleanliness,
    'payment': payment,
    'maintenance': maintenance,
  };

  double get average => (behavior + communication + cleanliness + payment + maintenance) / 5;
}

class ReviewModel {
  final String id;
  final UserModel? reviewer;
  final String reviewedUserId;
  final String? propertyId;
  final RatingCategories ratings;
  final double averageRating;
  final String comment;
  final String reviewType;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    this.reviewer,
    required this.reviewedUserId,
    this.propertyId,
    required this.ratings,
    required this.averageRating,
    required this.comment,
    required this.reviewType,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['_id'] ?? json['id'] ?? '',
    reviewer: json['reviewerId'] is Map ? UserModel.fromJson(json['reviewerId']) : null,
    reviewedUserId: json['reviewedUserId'] is String
        ? json['reviewedUserId']
        : (json['reviewedUserId']?['_id'] ?? ''),
    propertyId: json['propertyId'] is String
        ? json['propertyId']
        : json['propertyId']?['_id'],
    ratings: RatingCategories.fromJson(json['ratings'] ?? {}),
    averageRating: (json['averageRating'] ?? 0).toDouble(),
    comment: json['comment'] ?? '',
    reviewType: json['reviewType'] ?? '',
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
  );
}

class MessageModel {
  final String id;
  final UserModel? sender;
  final String receiverId;
  final String? propertyId;
  final String content;
  final bool isRead;
  final String messageType;
  final DateTime? createdAt;

  MessageModel({
    required this.id,
    this.sender,
    required this.receiverId,
    this.propertyId,
    required this.content,
    this.isRead = false,
    this.messageType = 'message',
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['_id'] ?? json['id'] ?? '',
    sender: json['senderId'] is Map ? UserModel.fromJson(json['senderId']) : null,
    receiverId: json['receiverId'] is String
        ? json['receiverId']
        : (json['receiverId']?['_id'] ?? ''),
    propertyId: json['propertyId'] is String
        ? json['propertyId']
        : json['propertyId']?['_id'],
    content: json['content'] ?? '',
    isRead: json['isRead'] ?? false,
    messageType: json['messageType'] ?? 'message',
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
  );
}

class ConversationModel {
  final UserModel partner;
  final MessageModel lastMessage;
  final int unread;

  ConversationModel({
    required this.partner,
    required this.lastMessage,
    this.unread = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) => ConversationModel(
    partner: UserModel.fromJson(json['partner'] ?? {}),
    lastMessage: MessageModel.fromJson(json['lastMessage'] ?? {}),
    unread: json['unread'] ?? 0,
  );
}
