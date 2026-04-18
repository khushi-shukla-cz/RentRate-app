const express = require('express');
const Review = require('../models/Review');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Get reviews for a user
router.get('/user/:userId', async (req, res) => {
  try {
    const reviews = await Review.find({ reviewedUserId: req.params.userId })
      .populate('reviewerId', 'name avatar role')
      .populate('propertyId', 'title location')
      .sort({ createdAt: -1 });
    res.json({ success: true, reviews });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Submit a review
router.post('/', protect, async (req, res) => {
  try {
    const { reviewedUserId, propertyId, ratings, comment, reviewType } = req.body;
    // Prevent self-review
    if (req.user._id.toString() === reviewedUserId) {
      return res.status(400).json({ success: false, message: 'Cannot review yourself' });
    }
    // Prevent duplicate review for same interaction
    const existing = await Review.findOne({
      reviewerId: req.user._id,
      reviewedUserId,
      propertyId: propertyId || null
    });
    if (existing) {
      return res.status(400).json({ success: false, message: 'You have already reviewed this user for this property' });
    }
    const review = await Review.create({
      reviewerId: req.user._id,
      reviewedUserId,
      propertyId,
      ratings,
      comment,
      reviewType
    });
    await review.populate('reviewerId', 'name avatar role');
    res.status(201).json({ success: true, message: 'Review submitted successfully', review });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Get reviews written by a user
router.get('/by/:userId', async (req, res) => {
  try {
    const reviews = await Review.find({ reviewerId: req.params.userId })
      .populate('reviewedUserId', 'name avatar role')
      .populate('propertyId', 'title location')
      .sort({ createdAt: -1 });
    res.json({ success: true, reviews });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
