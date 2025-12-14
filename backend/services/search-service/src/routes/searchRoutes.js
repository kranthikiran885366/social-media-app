const express = require('express');
const searchController = require('../controllers/searchController');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

router.get('/', searchController.universalSearch);
router.get('/suggestions', searchController.getSearchSuggestions);
router.get('/trending', searchController.getTrendingSearches);
router.post('/save', searchController.saveSearch);
router.delete('/history', searchController.clearSearchHistory);

module.exports = router;