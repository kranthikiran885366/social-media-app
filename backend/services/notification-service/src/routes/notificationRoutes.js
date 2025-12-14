const express = require('express');
const notificationController = require('../controllers/notificationController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

// Notification endpoints
router.get('/', notificationController.getNotifications);
router.get('/unread-count', notificationController.getUnreadCount);
router.post('/mark-read', notificationController.markAsRead);
router.post('/mark-all-read', notificationController.markAllAsRead);
router.delete('/:notificationId', notificationController.deleteNotification);
router.delete('/', notificationController.clearAllNotifications);

// Notification settings
router.get('/settings', notificationController.getNotificationSettings);
router.put('/settings', notificationController.updateNotificationSettings);

// Push notification endpoints
router.post('/register-device', notificationController.registerDevice);
router.post('/unregister-device', notificationController.unregisterDevice);

// Test notifications (development only)
if (process.env.NODE_ENV === 'development') {
  router.post('/test', notificationController.sendTestNotification);
}

module.exports = router;