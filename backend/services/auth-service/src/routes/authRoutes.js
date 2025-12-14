const express = require('express');
const authController = require('../controllers/authController');
const { authMiddleware } = require('../middleware/auth');
const { rateLimitMiddleware } = require('../middleware/rateLimit');

const router = express.Router();

// Public routes
router.post('/register', rateLimitMiddleware.register, authController.register);
router.post('/login', rateLimitMiddleware.login, authController.login);
router.post('/refresh', authController.refreshToken);
router.post('/forgot-password', rateLimitMiddleware.forgotPassword, authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);
router.post('/verify-email', authController.verifyEmail);
router.post('/verify-phone', authController.verifyPhone);

// Social login
router.post('/google', authController.googleLogin);
router.post('/apple', authController.appleLogin);
router.post('/facebook', authController.facebookLogin);

// Protected routes
router.use(authMiddleware);

// Profile management
router.get('/profile', authController.getProfile);
router.put('/profile', authController.updateProfile);
router.put('/password', authController.changePassword);
router.delete('/account', authController.deleteAccount);

// Two-factor authentication
router.post('/2fa/setup', authController.setupTwoFactor);
router.post('/2fa/verify', authController.verifyTwoFactor);
router.delete('/2fa', authController.disableTwoFactor);

// Device management
router.get('/devices', authController.getDevices);
router.delete('/devices/:deviceId', authController.removeDevice);
router.post('/logout-all', authController.logoutAllDevices);

// Privacy settings
router.get('/privacy', authController.getPrivacySettings);
router.put('/privacy', authController.updatePrivacySettings);

// Notification settings
router.get('/notifications/settings', authController.getNotificationSettings);
router.put('/notifications/settings', authController.updateNotificationSettings);

// Security
router.get('/security/alerts', authController.getSecurityAlerts);
router.get('/login-history', authController.getLoginHistory);

module.exports = router;