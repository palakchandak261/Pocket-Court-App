const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { register, login, updateProfile, getMe, changePassword } = require('../controllers/authController');

router.post('/register', register);
router.post('/login', login);
router.get('/me', auth, getMe);
router.put('/profile', auth, updateProfile);
router.put('/change-password', auth, changePassword);

module.exports = router;
