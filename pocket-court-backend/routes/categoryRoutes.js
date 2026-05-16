const express = require('express');
const router = express.Router();
const { getAllCategories, getSituationsByCategory } = require('../controllers/categoryController');

router.get('/categories', getAllCategories);
router.get('/situations/:category', getSituationsByCategory);

module.exports = router;
