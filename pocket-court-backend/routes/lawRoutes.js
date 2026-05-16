const express = require('express');
const router = express.Router();
const { getLawByCategoryAndSituation, getAllLaws } = require('../controllers/lawController');

router.get('/law', getLawByCategoryAndSituation);
router.get('/laws', getAllLaws);

module.exports = router;
