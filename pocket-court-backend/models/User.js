const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name:      { type: String, required: true, trim: true },
  email:     { type: String, required: true, unique: true, lowercase: true },
  password:  { type: String, required: true },
  phone:     { type: String, default: '' },
  city:      { type: String, default: '' },
  bookmarks: [
    {
      lawId:     String,
      category:  String,
      situation: String,
      act:       String,
      section:   String,
      fine:      String,
      article:   String,
    }
  ]
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
