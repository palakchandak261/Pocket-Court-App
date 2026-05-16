const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  category: { type: String, required: true, unique: true },
  situations: [{ type: String }]
});

module.exports = mongoose.model('Category', categorySchema);
