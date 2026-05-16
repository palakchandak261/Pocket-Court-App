const Category = require('../models/Category');

const getAllCategories = async (req, res) => {
  try {
    const categories = await Category.find({}, 'category situations');
    res.json({ success: true, data: categories });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

const getSituationsByCategory = async (req, res) => {
  try {
    const { category } = req.params;
    const found = await Category.findOne({ category });
    if (!found) {
      return res.status(404).json({ success: false, message: 'Category not found' });
    }
    res.json({ success: true, data: found.situations });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { getAllCategories, getSituationsByCategory };
