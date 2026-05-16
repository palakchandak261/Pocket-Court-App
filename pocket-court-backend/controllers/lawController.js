const Law = require('../models/Law');

// ── Get single law by category + situation ────────────────────────────────────
const getLawByCategoryAndSituation = async (req, res) => {
  try {
    const { category, situation } = req.query;
    if (!category || !situation)
      return res.status(400).json({ success: false, message: 'category and situation query params are required' });

    const law = await Law.findOne({ category, situation });
    if (!law)
      return res.status(404).json({ success: false, message: 'Law not found' });

    res.json({ success: true, data: law });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ── Get all laws with pagination + optional search ────────────────────────────
// GET /api/laws?page=1&limit=20&q=drunk&category=Traffic Rules
const getAllLaws = async (req, res) => {
  try {
    const page     = Math.max(1, parseInt(req.query.page)  || 1);
    const limit    = Math.min(100, parseInt(req.query.limit) || 50);
    const skip     = (page - 1) * limit;
    const search   = req.query.q?.trim();
    const category = req.query.category?.trim();

    // Build filter
    const filter = {};
    if (category) filter.category = category;
    if (search) {
      const regex = new RegExp(search, 'i');
      filter.$or = [
        { situation: regex },
        { act: regex },
        { section: regex },
        { category: regex },
      ];
    }

    const [laws, total] = await Promise.all([
      Law.find(filter).skip(skip).limit(limit).lean(),
      Law.countDocuments(filter),
    ]);

    res.json({
      success: true,
      data: laws,
      pagination: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
        hasNext: page * limit < total,
        hasPrev: page > 1,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { getLawByCategoryAndSituation, getAllLaws };
