const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  phone: { type: String, required: true },
  password: { type: String, required: true, minlength: 6 },
  role: { type: String, enum: ['tenant', 'owner'], required: true },
  avatar: { type: String, default: '' },
  bio: { type: String, default: '' },
  trustScore: { type: Number, default: 0, min: 0, max: 10 },
  averageRating: { type: Number, default: 0, min: 0, max: 5 },
  totalReviews: { type: Number, default: 0 },
  isVerified: { type: Boolean, default: false },
  savedProperties: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Property' }],
  createdAt: { type: Date, default: Date.now }
}, { timestamps: true });

// Hash password before save
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// Compare password
userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Recalculate trust score
userSchema.methods.recalculateTrustScore = async function () {
  const Review = mongoose.model('Review');
  const reviews = await Review.find({ reviewedUserId: this._id });
  if (reviews.length === 0) {
    this.trustScore = 0;
    this.averageRating = 0;
    this.totalReviews = 0;
  } else {
    const totalAvg = reviews.reduce((sum, r) => sum + r.averageRating, 0);
    const avgRating = totalAvg / reviews.length;
    this.averageRating = Math.round(avgRating * 10) / 10;
    this.trustScore = Math.round(avgRating * 2 * 10) / 10; // out of 10
    this.totalReviews = reviews.length;
  }
  return this.save();
};

module.exports = mongoose.model('User', userSchema);
