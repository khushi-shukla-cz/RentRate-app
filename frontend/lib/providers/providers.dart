import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../services/services.dart';

class ReviewProvider extends ChangeNotifier {
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;
  bool _submitted = false;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get submitted => _submitted;

  Future<void> fetchUserReviews(String userId) async {
    _isLoading = true;
    _reviews = [];
    notifyListeners();
    final res = await ReviewService.getUserReviews(userId);
    _isLoading = false;
    if (res['success'] == true) {
      _reviews = (res['reviews'] as List).map((e) => ReviewModel.fromJson(e)).toList();
    } else {
      _error = res['message'];
    }
    notifyListeners();
  }

  Future<bool> submitReview({
    required String reviewedUserId,
    String? propertyId,
    required Map<String, double> ratings,
    required String comment,
    required String reviewType,
  }) async {
    _isLoading = true;
    _error = null;
    _submitted = false;
    notifyListeners();
    final res = await ReviewService.submitReview(
      reviewedUserId: reviewedUserId,
      propertyId: propertyId,
      ratings: ratings,
      comment: comment,
      reviewType: reviewType,
    );
    _isLoading = false;
    if (res['success'] == true) {
      _submitted = true;
      notifyListeners();
      return true;
    }
    _error = res['message'] ?? 'Failed to submit review';
    notifyListeners();
    return false;
  }

  void reset() {
    _submitted = false;
    _error = null;
    notifyListeners();
  }
}

// ─── MESSAGE PROVIDER ─────────────────────────────────────────────────────────
class MessageProvider extends ChangeNotifier {
  List<ConversationModel> _conversations = [];
  List<MessageModel> _thread = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get thread => _thread;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> fetchConversations({String? query}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final res = await MessageService.getConversations(query: query);
    _isLoading = false;
    if (res['success'] == true) {
      _conversations = (res['conversations'] as List)
          .map((e) => ConversationModel.fromJson(e))
          .toList();
      _unreadCount = _conversations.fold(0, (sum, c) => sum + c.unread);
    } else {
      _error = res['message'];
    }
    notifyListeners();
  }

  String _currentPartnerId = '';

  Future<void> fetchThread(String userId, {bool silent = false}) async {
    _currentPartnerId = userId;
    if (!silent) {
      _isLoading = true;
      _thread = [];
    }
    _error = null;
    notifyListeners();
    final res = await MessageService.getThread(userId);
    if (!silent) {
      _isLoading = false;
    }
    if (res['success'] == true) {
      _thread = (res['messages'] as List).map((e) => MessageModel.fromJson(e)).toList();
      await MessageService.markThreadRead(userId);
      await refreshUnreadCount();
    } else {
      _error = res['message'];
    }
    notifyListeners();
  }

  Future<void> refreshUnreadCount() async {
    final res = await MessageService.getUnreadCount();
    if (res['success'] == true) {
      _unreadCount = res['unread'] ?? 0;
      notifyListeners();
    }
  }

  Future<bool> sendMessage({
    required String receiverId,
    required String content,
    String? propertyId,
    String messageType = 'message',
  }) async {
    _error = null;
    final res = await MessageService.sendMessage(
      receiverId: receiverId,
      content: content,
      propertyId: propertyId,
      messageType: messageType,
    );
    if (res['success'] == true) {
      if (res['data'] != null) {
        final msg = MessageModel.fromJson(res['data'] as Map<String, dynamic>);
        _thread.add(msg);
      } else {
        // Refresh full thread as fallback
        await fetchThread(receiverId);
      }
      await fetchConversations();
      notifyListeners();
      return true;
    }
    _error = res['message'] ?? 'Failed to send message';
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
