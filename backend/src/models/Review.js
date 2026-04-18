const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  reviewerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  reviewedUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  propertyId: { type: mongoose.Schema.Types.ObjectId, ref: 'Property' },
  ratings: {
    behavior: { type: Number, min: 1, max: 5, default: 5 },
    communication: { type: Number, min: 1, max: 5, default: 5 },
    cleanliness: { type: Number, min: 1, max: 5, default: 5 },
    payment: { type: Number, min: 1, max: 5, default: 5 },
    maintenance: { type: Number, min: 1, max: 5, default: 5 },
  },
  averageRating: { type: Number, min: 1, max: 5 },
  comment: { type: String, required: true, trim: true },
  reviewType: { type: String, enum: ['tenant-to-owner', 'owner-to-tenant'], required: true },
}, { timestamps: true });

// Auto-calculate average before save
reviewSchema.pre('save', function (next) {
  const { behavior, communication, cleanliness, payment, maintenance } = this.ratings;
  this.averageRating = (behavior + communication + cleanliness + payment + maintenance) / 5;
  this.averageRating = Math.round(this.averageRating * 10) / 10;
  next();
});

// After save, update user trust score
reviewSchema.post('save', async function () {
  const User = mongoose.model('User');
  const user = await User.findById(this.reviewedUserId);
  if (user) await user.recalculateTrustScore();
});

module.exports = mongoose.model('Review', reviewSchema);
