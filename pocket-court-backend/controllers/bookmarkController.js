const User = require('../models/User');

const getBookmarks = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    res.json({ success: true, data: user.bookmarks });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

const addBookmark = async (req, res) => {
  try {
    const { lawId, category, situation, act, section, fine, article } = req.body;
    const user = await User.findById(req.user.id);

    const exists = user.bookmarks.some(b => b.situation === situation && b.category === category);
    if (exists) return res.json({ success: true, message: 'Already bookmarked' });

    user.bookmarks.push({ lawId, category, situation, act, section, fine, article });
    await user.save();
    res.json({ success: true, data: user.bookmarks });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

const removeBookmark = async (req, res) => {
  try {
    const { category, situation } = req.body;
    const user = await User.findById(req.user.id);
    user.bookmarks = user.bookmarks.filter(
      b => !(b.category === category && b.situation === situation)
    );
    await user.save();
    res.json({ success: true, data: user.bookmarks });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
};

module.exports = { getBookmarks, addBookmark, removeBookmark };
