const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// ── Helpers ───────────────────────────────────────────────────────────────────
const signToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });

const _safe = (u) => ({
  id: u._id,
  name: u.name,
  email: u.email,
  phone: u.phone,
  city: u.city,
  createdAt: u.createdAt,
});

// Simple validators (no extra library needed)
const isValidEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
const isValidName  = (name)  => name && name.trim().length >= 2 && name.trim().length <= 60;
const isStrongPass = (pass)  => pass && pass.length >= 6;

// ── Register ──────────────────────────────────────────────────────────────────
const register = async (req, res) => {
  try {
    const { name, email, password, phone, city } = req.body;

    // Input validation
    if (!name || !email || !password)
      return res.status(400).json({ success: false, message: 'Name, email and password are required' });
    if (!isValidName(name))
      return res.status(400).json({ success: false, message: 'Name must be 2–60 characters' });
    if (!isValidEmail(email))
      return res.status(400).json({ success: false, message: 'Enter a valid email address' });
    if (!isStrongPass(password))
      return res.status(400).json({ success: false, message: 'Password must be at least 6 characters' });

    // Duplicate check
    if (await User.findOne({ email: email.toLowerCase() }))
      return res.status(409).json({ success: false, message: 'Email already registered' });

    const hashed = await bcrypt.hash(password, 12); // 12 rounds for better security
    const user = await User.create({
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password: hashed,
      phone: phone?.trim() || '',
      city: city?.trim() || '',
    });

    res.status(201).json({
      success: true,
      message: 'Account created successfully',
      data: { token: signToken(user._id), user: _safe(user) },
    });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

// ── Login ─────────────────────────────────────────────────────────────────────
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password)
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    if (!isValidEmail(email))
      return res.status(400).json({ success: false, message: 'Enter a valid email address' });

    const user = await User.findOne({ email: email.toLowerCase() });

    // Constant-time comparison to prevent timing attacks
    const passwordMatch = user ? await bcrypt.compare(password, user.password) : false;
    if (!user || !passwordMatch)
      return res.status(401).json({ success: false, message: 'Invalid email or password' });

    res.json({
      success: true,
      message: 'Login successful',
      data: { token: signToken(user._id), user: _safe(user) },
    });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

// ── Update Profile ────────────────────────────────────────────────────────────
const updateProfile = async (req, res) => {
  try {
    const { name, phone, city } = req.body;

    if (!name || !isValidName(name))
      return res.status(400).json({ success: false, message: 'Name must be 2–60 characters' });

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { name: name.trim(), phone: phone?.trim() || '', city: city?.trim() || '' },
      { new: true, runValidators: true }
    );

    if (!user)
      return res.status(404).json({ success: false, message: 'User not found' });

    res.json({ success: true, message: 'Profile updated', data: _safe(user) });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

// ── Get Me ────────────────────────────────────────────────────────────────────
const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user)
      return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: _safe(user) });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

// ── Change Password ───────────────────────────────────────────────────────────
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword)
      return res.status(400).json({ success: false, message: 'Both current and new password are required' });
    if (!isStrongPass(newPassword))
      return res.status(400).json({ success: false, message: 'New password must be at least 6 characters' });

    const user = await User.findById(req.user.id);
    const match = await bcrypt.compare(currentPassword, user.password);
    if (!match)
      return res.status(401).json({ success: false, message: 'Current password is incorrect' });

    user.password = await bcrypt.hash(newPassword, 12);
    await user.save();

    res.json({ success: true, message: 'Password changed successfully' });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

module.exports = { register, login, updateProfile, getMe, changePassword };
