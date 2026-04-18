const express = require('express');
const Message = require('../models/Message');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Send message/inquiry
router.post('/', protect, async (req, res) => {
  try {
    const { receiverId, propertyId, content, messageType } = req.body;
    const message = await Message.create({
      senderId: req.user._id,
      receiverId,
      propertyId,
      content,
      messageType: messageType || 'message'
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

    res.json({ success: true, conversations: Object.values(conversationMap) });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Get messages with a specific user
router.get('/thread/:userId', protect, async (req, res) => {
  try {
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

module.exports = router;
