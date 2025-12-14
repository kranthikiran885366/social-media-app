const express = require('express');
const multer = require('multer');
const postController = require('../controllers/postController');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 50 * 1024 * 1024, files: 10 }
});

router.use(authMiddleware);

// Posts
router.get('/posts', postController.getFeedPosts);
router.get('/posts/explore', postController.getExplorePosts);
router.post('/posts', upload.array('media', 10), postController.createPost);
router.post('/posts/:id/like', postController.toggleLike);
router.post('/posts/:id/comments', postController.addComment);
router.post('/posts/:id/save', postController.toggleSave);
router.post('/posts/:id/share', postController.sharePost);
router.delete('/posts/:id', postController.deletePost);

module.exports = router;