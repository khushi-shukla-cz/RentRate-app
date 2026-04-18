const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  receiverId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  propertyId: { type: mongoose.Schema.Types.ObjectId, ref: 'Property' },
  content: { type: String, required: true, trim: true },
  isRead: { type: Boolean, default: false },
  messageType: { type: String, enum: ['inquiry', 'message'], default: 'message' },
}, { timestamps: true });

module.exports = mongoose.model('Message', messageSchema);
