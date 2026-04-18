const express = require('express');
const Property = require('../models/Property');
const User = require('../models/User');
const { protect } = require('../middleware/auth');

const router = express.Router();

// ── SPECIFIC ROUTES MUST COME BEFORE /:id wildcard ──────────────────────────

// Get owner's properties  (GET /owner/my)
router.get('/owner/my', protect, async (req, res) => {
  try {
    const properties = await Property.find({ ownerId: req.user._id }).sort({ createdAt: -1 });
    res.json({ success: true, properties });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Get saved properties  (GET /saved/list)
router.get('/saved/list', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).populate({
      path: 'savedProperties',
      populate: { path: 'ownerId', select: 'name avatar trustScore averageRating' }
    });
    res.json({ success: true, properties: user.savedProperties });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Get all properties with filters  (GET /)
router.get('/', async (req, res) => {
  try {
    const { city, minPrice, maxPrice, furnishing, propertyType, page = 1, limit = 10 } = req.query;
    const filter = { isAvailable: true };
    if (city) filter['location.city'] = { $regex: city, $options: 'i' };
    if (furnishing) filter.furnishing = furnishing;
    if (propertyType) filter.propertyType = propertyType;
    if (minPrice || maxPrice) {
      filter.price = {};
      if (minPrice) filter.price.$gte = Number(minPrice);
      if (maxPrice) filter.price.$lte = Number(maxPrice);
    }
    const skip = (Number(page) - 1) * Number(limit);
    const total = await Property.countDocuments(filter);
    const properties = await Property.find(filter)
      .populate('ownerId', 'name avatar trustScore averageRating totalReviews')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit));
    res.json({ success: true, total, page: Number(page), properties });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Create property  (POST /)
router.post('/', protect, async (req, res) => {
  try {
    if (req.user.role !== 'owner') {
      return res.status(403).json({ success: false, message: 'Only owners can list properties' });
    }
    const property = await Property.create({ ...req.body, ownerId: req.user._id });
    res.status(201).json({ success: true, message: 'Property created', property });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── WILDCARD ROUTES (:id) COME AFTER SPECIFIC ROUTES ────────────────────────

// Get single property  (GET /:id)
router.get('/:id', async (req, res) => {
  try {
    const property = await Property.findByIdAndUpdate(
      req.params.id,
      { $inc: { views: 1 } },
      { new: true }
    ).populate('ownerId', 'name avatar trustScore averageRating totalReviews email phone');
    if (!property) return res.status(404).json({ success: false, message: 'Property not found' });
    res.json({ success: true, property });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Update property  (PUT /:id)
router.put('/:id', protect, async (req, res) => {
  try {
    const property = await Property.findOne({ _id: req.params.id, ownerId: req.user._id });
    if (!property) return res.status(404).json({ success: false, message: 'Property not found or unauthorized' });
    Object.assign(property, req.body);
    await property.save();
    res.json({ success: true, message: 'Property updated', property });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Delete property  (DELETE /:id)
router.delete('/:id', protect, async (req, res) => {
  try {
    const property = await Property.findOneAndDelete({ _id: req.params.id, ownerId: req.user._id });
    if (!property) return res.status(404).json({ success: false, message: 'Property not found or unauthorized' });
    res.json({ success: true, message: 'Property deleted' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Save/unsave property  (POST /:id/save)
router.post('/:id/save', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    const propId = req.params.id;
    const idx = user.savedProperties.findIndex(id => id.toString() === propId);
    if (idx === -1) {
      user.savedProperties.push(propId);
    } else {
      user.savedProperties.splice(idx, 1);
    }
    await user.save();
    res.json({ success: true, saved: idx === -1, savedProperties: user.savedProperties });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
