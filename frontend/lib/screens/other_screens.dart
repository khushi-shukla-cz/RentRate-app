import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

// ─── REVIEW SUBMISSION SCREEN ─────────────────────────────────────────────────
class SubmitReviewScreen extends StatefulWidget {
  final String reviewedUserId;
  final String reviewedUserName;
  final String? propertyId;
  final String reviewType;

  const SubmitReviewScreen({
    super.key,
    required this.reviewedUserId,
    required this.reviewedUserName,
    this.propertyId,
    required this.reviewType,
  });

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  double _behavior = 4;
  double _communication = 4;
  double _cleanliness = 4;
  double _payment = 4;
  double _maintenance = 4;
  final _commentCtrl = TextEditingController();

  double get _average => (_behavior + _communication + _cleanliness + _payment + _maintenance) / 5;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_commentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment'), backgroundColor: AppColors.warning),
      );
      return;
    }
    final rp = context.read<ReviewProvider>();
    final ok = await rp.submitReview(
      reviewedUserId: widget.reviewedUserId,
      propertyId: widget.propertyId,
      ratings: {
        'behavior': _behavior,
        'communication': _communication,
        'cleanliness': _cleanliness,
        'payment': _payment,
        'maintenance': _maintenance,
      },
      comment: _commentCtrl.text.trim(),
      reviewType: widget.reviewType,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!'), backgroundColor: AppColors.trustHigh),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(rp.error ?? 'Failed to submit'), backgroundColor: AppColors.warning),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rp = context.watch<ReviewProvider>();
    return Scaffold(
      appBar: AppBar(title: Text('Review ${widget.reviewedUserName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Average preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Overall Rating', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          _average.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                        ),
                        Text('out of 5.0', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                      ],
                    ),
                  ),
                  RatingBarIndicator(
                    rating: _average,
                    itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: Colors.white),
                    itemCount: 5,
                    itemSize: 28,
                    unratedColor: Colors.white30,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Rate by Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 16),
            _ratingRow('Behavior', Icons.mood_rounded, _behavior, (v) => setState(() => _behavior = v)),
            _ratingRow('Communication', Icons.chat_rounded, _communication, (v) => setState(() => _communication = v)),
            _ratingRow('Cleanliness', Icons.cleaning_services_rounded, _cleanliness, (v) => setState(() => _cleanliness = v)),
            _ratingRow('Payment', Icons.payment_rounded, _payment, (v) => setState(() => _payment = v)),
            _ratingRow('Maintenance', Icons.build_rounded, _maintenance, (v) => setState(() => _maintenance = v)),
            const SizedBox(height: 24),
            const Text('Write a Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _commentCtrl,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Share your experience in detail...',
                labelText: 'Your review',
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Submit Review',
              onPressed: _submit,
              isLoading: rp.isLoading,
              icon: Icons.rate_review_rounded,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _ratingRow(String label, IconData icon, double value, ValueChanged<double> onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: RatingBar.builder(
            initialRating: value,
            minRating: 1,
            itemCount: 5,
            itemSize: 26,
            itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppColors.rating),
            unratedColor: AppColors.border,
            onRatingUpdate: onChanged,
          ),
        ),
        const SizedBox(width: 6),
        Text(value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.rating, fontSize: 13)),
      ],
    ),
  );
}

// ─── MESSAGE THREAD SCREEN ────────────────────────────────────────────────────
class MessageThreadScreen extends StatefulWidget {
  final String partnerId;
  final String partnerName;
  final String? propertyId;

  const MessageThreadScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
    this.propertyId,
  });

  @override
  State<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends State<MessageThreadScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _pollTimer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().fetchThread(widget.partnerId);
      context.read<MessageProvider>().fetchConversations();
      _startPolling();
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      context.read<MessageProvider>().fetchThread(widget.partnerId, silent: true);
    });
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send() async {
    if (_isSending || _ctrl.text.trim().isEmpty) return;
    final text = _ctrl.text.trim();
    setState(() => _isSending = true);
    final ok = await context.read<MessageProvider>().sendMessage(
      receiverId: widget.partnerId,
      content: text,
      propertyId: widget.propertyId,
    );
    if (!mounted) return;
    setState(() => _isSending = false);
    if (ok) {
      _ctrl.clear();
    } else {
      final error = context.read<MessageProvider>().error ?? 'Failed to send message';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.warning),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MessageProvider>();
    final me = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.partnerName, style: const TextStyle(fontSize: 16)),
            const Text('Online', style: TextStyle(fontSize: 11, color: AppColors.trustHigh)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review_rounded),
            tooltip: 'Write Review',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubmitReviewScreen(
                  reviewedUserId: widget.partnerId,
                  reviewedUserName: widget.partnerName,
                  propertyId: widget.propertyId,
                  reviewType: me?.isOwner == true ? 'owner-to-tenant' : 'tenant-to-owner',
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: mp.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => context.read<MessageProvider>().fetchThread(widget.partnerId),
                    child: mp.thread.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              EmptyState(
                                icon: Icons.chat_bubble_outline_rounded,
                                title: 'No messages yet',
                                subtitle: 'Start the conversation!',
                              ),
                            ],
                          )
                        : ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.all(16),
                            itemCount: mp.thread.length,
                            itemBuilder: (_, i) {
                              final msg = mp.thread[i];
                              final isMine = msg.sender?.id == me?.id;
                              return _bubble(msg.content, isMine, msg.createdAt, msg.isRead, msg.messageType);
                            },
                          ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isSending ? null : _send,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isSending ? AppColors.textBody : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(String text, bool isMine, DateTime? time, bool isRead, String type) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMine ? AppColors.primary : AppColors.cardBackground,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMine ? 16 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 16),
              ),
              border: isMine ? null : Border.all(color: AppColors.border),
            ),
            child: Text(
              type == 'inquiry' ? 'Inquiry: $text' : text,
              style: TextStyle(
                color: isMine ? Colors.white : AppColors.textDark,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          if (time != null) ...[
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textBody),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 12,
                    color: isRead ? AppColors.trustHigh : AppColors.textBody,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

// ─── ABOUT SCREEN ─────────────────────────────────────────────────────────────
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About RentRate')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.home_rounded, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text('RentRate', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  const Text('Trust-Driven Rental Platform', style: TextStyle(color: AppColors.textBody)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _card(
              icon: Icons.warning_amber_rounded,
              color: AppColors.warning,
              title: 'The Problem',
              content: 'Finding trustworthy tenants or reliable landlords is a major challenge in India\'s rental market. Bad experiences — delayed rent, property damage, poor communication, sudden evictions — are common but invisible to others.',
            ),
            const SizedBox(height: 16),
            _card(
              icon: Icons.verified_user_rounded,
              color: AppColors.trustHigh,
              title: 'Our Solution',
              content: 'RentRate builds trust through transparency. Every tenant and owner builds a verified trust score based on real reviews from real interactions. Before you rent, you can see exactly who you\'re dealing with.',
            ),
            const SizedBox(height: 16),
            _card(
              icon: Icons.star_rounded,
              color: AppColors.rating,
              title: 'How Trust Scores Work',
              content: 'After every rental interaction, both parties can rate each other across 5 dimensions: Behavior, Communication, Cleanliness, Payment, and Maintenance. These ratings form a Trust Score out of 10 — your rental reputation.',
            ),
            const SizedBox(height: 24),
            const Text('Our Values', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 12),
            ...['Transparency', 'Trust', 'Fairness', 'Accountability'].map((v) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.trustHigh, size: 18),
                  const SizedBox(width: 10),
                  Text(v, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _card({required IconData icon, required Color color, required String title, required String content}) =>
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
          ],
        ),
      );
}

// ─── CONTACT SCREEN ───────────────────────────────────────────────────────────
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.trustHigh.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle_rounded, size: 56, color: AppColors.trustHigh),
                    ),
                    const SizedBox(height: 20),
                    const Text('Message Sent!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text("We'll get back to you within 24 hours.", textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textBody)),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Get in Touch', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  const Text('We love feedback and questions!', style: TextStyle(color: AppColors.textBody)),
                  const SizedBox(height: 24),
                  TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Your Name', prefixIcon: Icon(Icons.person_outline))),
                  const SizedBox(height: 14),
                  TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined))),
                  const SizedBox(height: 14),
                  TextField(controller: _msgCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Your Message')),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Send Message',
                    icon: Icons.send_rounded,
                    onPressed: () => setState(() => _sent = true),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  _contactItem(Icons.email_outlined, 'support@rentrate.in'),
                  _contactItem(Icons.phone_outlined, '+91 98765 43210'),
                  _contactItem(Icons.location_on_outlined, 'Pune, Maharashtra, India'),
                ],
              ),
      ),
    );
  }

  Widget _contactItem(IconData icon, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ],
    ),
  );
}
