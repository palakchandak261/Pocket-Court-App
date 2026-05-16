const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { getBookmarks, addBookmark, removeBookmark } = require('../controllers/bookmarkController');

router.get('/bookmarks', auth, getBookmarks);
router.post('/bookmarks', auth, addBookmark);
router.delete('/bookmarks', auth, removeBookmark);

module.exports = router;
