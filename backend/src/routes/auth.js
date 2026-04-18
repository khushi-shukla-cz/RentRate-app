const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { protect } = require('../middleware/auth');

const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET || 'rentrate_dev_secret_change_me';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

const signToken = (id) => jwt.sign({ id }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

const DEMO_USERS = {
  'rajesh@demo.com': { name: 'Rajesh Kumar', phone: '9876543210', role: 'owner' },
  'priya@demo.com': { name: 'Priya Sharma', phone: '9876543211', role: 'owner' },
  'amit@demo.com': { name: 'Amit Patel', phone: '9876543212', role: 'tenant' },
  'sneha@demo.com': { name: 'Sneha Iyer', phone: '9876543213', role: 'tenant' }
};

const ensureDemoUser = async (email, password) => {
  const demo = DEMO_USERS[email];
  if (!demo || password !== 'password123') return null;
  return User.create({
    name: demo.name,
    email,
    phone: demo.phone,
    password,
    role: demo.role
  });
};

// Register
router.post('/register', async (req, res) => {
  try {
    const { name, email, phone, password, role } = req.body;
    const normalizedEmail = (email || '').toLowerCase().trim();
    if (!name || !email || !phone || !password || !role) {
      return res.status(400).json({ success: false, message: 'All fields are required' });
    }
    const existingUser = await User.findOne({ email: normalizedEmail });
    if (existingUser) {
      return res.status(400).json({ success: false, message: 'Email already registered' });
    }
    const user = await User.create({ name, email: normalizedEmail, phone, password, role });
    const token = signToken(user._id);
    res.status(201).json({
      success: true,
      message: 'Registration successful',
      token,
      user: { id: user._id, name: user.name, email: user.email, role: user.role, trustScore: user.trustScore }
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const normalizedEmail = (email || '').toLowerCase().trim();
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password required' });
    }

    let user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      user = await ensureDemoUser(normalizedEmail, password);
    }

    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    let isValidPassword = false;
    try {
      isValidPassword = await user.comparePassword(password);
    } catch (_) {
      // Handle legacy plain-text records by allowing one-time login + rehash.
      if (user.password === password) {
        user.password = password;
        await user.save();
        isValidPassword = true;
      }
    }

    if (!isValidPassword) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    const token = signToken(user._id);
    res.json({
      success: true,
      message: 'Login successful',
      token,
      user: { id: user._id, name: user.name, email: user.email, role: user.role, trustScore: user.trustScore, avatar: user.avatar }
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Get current user
router.get('/me', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-password');
    res.json({ success: true, user });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
