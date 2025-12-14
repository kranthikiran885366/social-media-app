const express = require('express');
const feedController = require('../controllers/feedController');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

router.get('/home', feedController.getHomeFeed);
router.get('/explore', feedController.getExploreFeed);
router.get('/reels', feedController.getReelsFeed);
router.get('/trending', feedController.getTrendingSearches);
router.put('/preferences', feedController.updateFeedPreferences);
router.post('/hide/:postId', feedController.hidePost);
router.post('/report', feedController.reportFeedIssue);

module.exports = router;