import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../models/review_model.dart';

// ─── TRUST SCORE BADGE ────────────────────────────────────────────────────────
class TrustScoreBadge extends StatelessWidget {
  final double score;
  final double size;
  final bool showLabel;

  const TrustScoreBadge({super.key, required this.score, this.size = 48, this.showLabel = true});

  Color get _color {
    if (score >= 8) return AppColors.trustHigh;
    if (score >= 5) return AppColors.rating;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: _color, width: 2),
          ),
          child: Center(
            child: Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                color: _color,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.28,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          const Text('Trust Score', style: TextStyle(color: AppColors.textBody, fontSize: 10)),
        ],
      ],
    );
  }
}

// ─── STAR RATING DISPLAY ──────────────────────────────────────────────────────
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final bool showValue;

  const StarRatingDisplay({super.key, required this.rating, this.size = 16, this.showValue = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppColors.rating),
          itemCount: 5,
          itemSize: size,
          unratedColor: AppColors.border,
        ),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.85,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── USER AVATAR ──────────────────────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    if (user.avatar.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user.avatar),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withOpacity(0.15),
      child: Text(
        user.initials,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.65,
        ),
      ),
    );
  }
}

// ─── PROPERTY CARD ────────────────────────────────────────────────────────────
class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;
  final bool saved;
  final VoidCallback? onSaveToggle;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.saved = false,
    this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: property.thumbnail.isNotEmpty
                      ? Image.network(
                          property.thumbnail,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _capitalize(property.furnishing),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (onSaveToggle != null) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onSaveToggle,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
                            ),
                            child: Icon(
                              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: saved ? AppColors.primary : AppColors.textBody,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textBody),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          property.location.shortAddress,
                          style: const TextStyle(fontSize: 12, color: AppColors.textBody),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        property.formattedPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                      if (property.owner != null)
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, size: 12, color: AppColors.trustHigh),
                            const SizedBox(width: 3),
                            Text(
                              '${property.owner!.trustScore.toStringAsFixed(1)}/10',
                              style: const TextStyle(fontSize: 11, color: AppColors.trustHigh, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _chip(Icons.bed_rounded, '${property.bedrooms} BHK'),
                      const SizedBox(width: 6),
                      _chip(Icons.square_foot_rounded, '${property.area.toStringAsFixed(0)} sq.ft'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 160,
    color: AppColors.softBeige,
    child: const Center(child: Icon(Icons.home_rounded, size: 48, color: AppColors.border)),
  );

  Widget _chip(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: AppColors.textBody),
      const SizedBox(width: 3),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textBody)),
    ],
  );

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── REVIEW CARD ──────────────────────────────────────────────────────────────
class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (review.reviewer != null) UserAvatar(user: review.reviewer!, radius: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewer?.name ?? 'Anonymous',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.textBody),
                    ),
                  ],
                ),
              ),
              StarRatingDisplay(rating: review.averageRating, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _ratingChip('Behavior', review.ratings.behavior),
              _ratingChip('Communication', review.ratings.communication),
              _ratingChip('Cleanliness', review.ratings.cleanliness),
              _ratingChip('Payment', review.ratings.payment),
              _ratingChip('Maintenance', review.ratings.maintenance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingChip(String label, double value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.softBeige,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textBody)),
        const SizedBox(width: 4),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.rating),
        ),
      ],
    ),
  );

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── SECTION HEADER ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: const TextStyle(color: AppColors.primary, fontSize: 13)),
          ),
      ],
    );
  }
}

// ─── LOADING SHIMMER ──────────────────────────────────────────────────────────
class LoadingCard extends StatelessWidget {
  final double height;

  const LoadingCard({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// ─── EMPTY STATE ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.softBeige,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.textBody),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textBody)),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── PRIMARY BUTTON ───────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color ?? AppColors.primary),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                  Text(label),
                ],
              ),
      ),
    );
  }
}
