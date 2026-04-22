const express = require('express');
const mongoose = require('mongoose');
const Message = require('../models/Message');
const User = require('../models/User');
const Property = require('../models/Property');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Send message/inquiry
router.post('/', protect, async (req, res) => {
  try {
    const { receiverId, propertyId, content, messageType } = req.body;

    if (!receiverId || !mongoose.Types.ObjectId.isValid(receiverId)) {
      return res.status(400).json({ success: false, message: 'Valid receiverId is required' });
    }

    if (receiverId.toString() === req.user._id.toString()) {
      return res.status(400).json({ success: false, message: 'Cannot message yourself' });
    }

    const receiver = await User.findById(receiverId).select('_id');
    if (!receiver) {
      return res.status(404).json({ success: false, message: 'Receiver not found' });
    }

    if (propertyId) {
      if (!mongoose.Types.ObjectId.isValid(propertyId)) {
        return res.status(400).json({ success: false, message: 'Invalid propertyId' });
      }
      const property = await Property.findById(propertyId).select('_id');
      if (!property) {
        return res.status(404).json({ success: false, message: 'Property not found' });
      }
    }

    const trimmedContent = (content || '').trim();
    if (!trimmedContent) {
      return res.status(400).json({ success: false, message: 'Message content is required' });
    }
    if (trimmedContent.length > 1000) {
      return res.status(400).json({ success: false, message: 'Message content must be 1000 characters or fewer' });
    }

    const normalizedType = messageType === 'inquiry' ? 'inquiry' : 'message';

    const message = await Message.create({
      senderId: req.user._id,
      receiverId,
      propertyId,
      content: trimmedContent,
      messageType: normalizedType
    });
    await message.populate('senderId', 'name avatar role');
    await message.populate('receiverId', 'name avatar role');
    res.status(201).json({ success: true, message: 'Message sent', data: message });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Get conversations (unique users I have talked to)
router.get('/conversations', protect, async (req, res) => {
  try {
    const userId = req.user._id;
    const search = (req.query.q || '').toString().trim().toLowerCase();

    const messages = await Message.find({
      $or: [{ senderId: userId }, { receiverId: userId }]
    })
      .populate('senderId', 'name avatar role trustScore')
      .populate('receiverId', 'name avatar role trustScore')
      .populate('propertyId', 'title')
      .sort({ createdAt: -1 });

    // Group by conversation partner
    const conversationMap = {};
    messages.forEach(msg => {
      const partnerId = msg.senderId._id.toString() === userId.toString()
        ? msg.receiverId._id.toString()
        : msg.senderId._id.toString();
      if (!conversationMap[partnerId]) {
        conversationMap[partnerId] = {
          partner: msg.senderId._id.toString() === userId.toString() ? msg.receiverId : msg.senderId,
          lastMessage: msg,
          unread: 0
        };
      }
      if (!msg.isRead && msg.receiverId._id.toString() === userId.toString()) {
        conversationMap[partnerId].unread++;
      }
    });

    let conversations = Object.values(conversationMap);
    if (search) {
      conversations = conversations.filter((c) =>
        (c.partner?.name || '').toLowerCase().includes(search)
      );
    }

    res.json({ success: true, conversations });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Get total unread count for current user
router.get('/unread/count', protect, async (req, res) => {
  try {
    const unread = await Message.countDocuments({
      receiverId: req.user._id,
      isRead: false
    });
    res.json({ success: true, unread });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Get messages with a specific user
router.get('/thread/:userId', protect, async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.userId)) {
      return res.status(400).json({ success: false, message: 'Invalid userId' });
    }

    const messages = await Message.find({
      $or: [
        { senderId: req.user._id, receiverId: req.params.userId },
        { senderId: req.params.userId, receiverId: req.user._id }
      ]
    })
      .populate('senderId', 'name avatar')
      .populate('propertyId', 'title images')
      .sort({ createdAt: 1 });

    // Mark messages as read
    await Message.updateMany(
      { senderId: req.params.userId, receiverId: req.user._id, isRead: false },
      { isRead: true }
    );

    res.json({ success: true, messages });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Mark a thread as read
router.put('/thread/:userId/read', protect, async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.userId)) {
      return res.status(400).json({ success: false, message: 'Invalid userId' });
    }

    const result = await Message.updateMany(
      { senderId: req.params.userId, receiverId: req.user._id, isRead: false },
      { isRead: true }
    );

    res.json({ success: true, updated: result.modifiedCount || 0 });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
