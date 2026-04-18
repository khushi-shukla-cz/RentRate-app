const mongoose = require('mongoose');

const propertySchema = new mongoose.Schema({
  ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true, trim: true },
  description: { type: String, required: true },
  price: { type: Number, required: true },
  location: {
    address: { type: String, required: true },
    city: { type: String, required: true },
    state: { type: String, required: true },
    pincode: { type: String }
  },
  images: [{ type: String }],
  propertyType: { type: String, enum: ['apartment', 'house', 'villa', 'studio', 'commercial'], default: 'apartment' },
  furnishing: { type: String, enum: ['furnished', 'semi-furnished', 'unfurnished'], default: 'unfurnished' },
  bedrooms: { type: Number, default: 1 },
  bathrooms: { type: Number, default: 1 },
  area: { type: Number }, // sq ft
  amenities: [{ type: String }],
  isAvailable: { type: Boolean, default: true },
  deposit: { type: Number, default: 0 },
  views: { type: Number, default: 0 },
}, { timestamps: true });

module.exports = mongoose.model('Property', propertySchema);
