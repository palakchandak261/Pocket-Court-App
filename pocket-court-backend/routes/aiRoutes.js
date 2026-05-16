const express = require('express');
const router = express.Router();
const { chat } = require('../controllers/aiController');

// POST /api/ai/chat  — no auth required (public endpoint)
router.post('/ai/chat', chat);

module.exports = router;
