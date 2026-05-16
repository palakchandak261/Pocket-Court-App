const mongoose = require('mongoose');

const lawSchema = new mongoose.Schema({
  category:  { type: String, required: true, trim: true },
  situation: { type: String, required: true, trim: true },
  act:       { type: String, required: true, trim: true },
  section:   { type: String, required: true, trim: true },
  fine:      { type: String, default: 'N/A' },
  article:   { type: String, default: 'N/A' },
}, { timestamps: true });

// Compound index for the most common query (category + situation lookup)
lawSchema.index({ category: 1, situation: 1 }, { unique: true });

// Text index for full-text search via $text operator
lawSchema.index({ situation: 'text', act: 'text', section: 'text', category: 'text' });

module.exports = mongoose.model('Law', lawSchema);
