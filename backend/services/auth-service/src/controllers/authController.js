const jwt = require('jsonwebtoken');
const speakeasy = require('speakeasy');
const QRCode = require('qrcode');
const crypto = require('crypto');
const geoip = require('geoip-lite');
const DeviceDetector = require('device-detector-js');
const User = require('../models/User');
const { sendEmail, sendSMS } = require('../utils/notifications');
const { validateInput } = require('../utils/validation');
const logger = require('../utils/logger');

class AuthController {
  // Register new user
  async register(req, res) {
    try {
      const { error, value } = validateInput.register(req.body);
      if (error) {
        return res.status(400).json({
          success: false,
          message: 'Validation error',
          errors: error.details.map(detail => detail.message)
        });
      }

      const { username, email, password, fullName, phone, dateOfBirth } = value;

      // Check if user exists
      const existingUser = await User.findOne({
        $or: [{ email }, { username }, ...(phone ? [{ phone }] : [])]
      });

      if (existingUser) {
        return res.status(409).json({
          success: false,
          message: 'User already exists with this email, username, or phone'
        });
      }

      // Get device and location info
      const deviceInfo = this.getDeviceInfo(req);
      const locationInfo = this.getLocationInfo(req.ip);

      // Create user
      const user = new User({
        username,
        email,
        password,
        fullName,
        phone,
        dateOfBirth,
        location: locationInfo,
        emailVerificationToken: crypto.randomBytes(32).toString('hex')
      });

      // Add initial device
      user.addDevice({
        deviceId: deviceInfo.deviceId,
        deviceName: deviceInfo.deviceName,
        deviceType: deviceInfo.deviceType,
        browser: deviceInfo.browser,
        os: deviceInfo.os,
        ipAddress: req.ip,
        location: locationInfo,
        isTrusted: true
      });

      await user.save();

      // Send verification email
      await this.sendVerificationEmail(user);

      // Generate tokens
      const tokens = this.generateTokens(user._id);

      logger.info(`New user registered: ${user.username}`, {
        userId: user._id,
        email: user.email,
        ip: req.ip
      });

      res.status(201).json({
        success: true,
        message: 'User registered successfully. Please verify your email.',
        data: {
          user: user.toSafeObject(),
          tokens
        }
      });
    } catch (error) {
      logger.error('Registration error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Login user
  async login(req, res) {
    try {
      const { error, value } = validateInput.login(req.body);
      if (error) {
        return res.status(400).json({
          success: false,
          message: 'Validation error',
          errors: error.details.map(detail => detail.message)
        });
      }

      const { identifier, password, twoFactorCode, deviceId } = value;
      const deviceInfo = this.getDeviceInfo(req);
      const locationInfo = this.getLocationInfo(req.ip);

      // Find user by email, username, or phone
      const user = await User.findOne({
        $or: [
          { email: identifier },
          { username: identifier },
          { phone: identifier }
        ]
      });

      const loginAttempt = {
        ipAddress: req.ip,
        userAgent: req.get('User-Agent'),
        success: false,
        location: locationInfo
      };

      if (!user) {
        loginAttempt.reason = 'User not found';
        return res.status(401).json({
          success: false,
          message: 'Invalid credentials'
        });
      }

      // Check if account is banned
      if (user.isBanned && (!user.banExpiresAt || user.banExpiresAt > new Date())) {
        loginAttempt.reason = 'Account banned';
        user.addLoginAttempt(loginAttempt);
        await user.save();
        
        return res.status(403).json({
          success: false,
          message: 'Account is banned',
          banReason: user.banReason,
          banExpiresAt: user.banExpiresAt
        });
      }

      // Check password
      const isPasswordValid = await user.comparePassword(password);
      if (!isPasswordValid) {
        loginAttempt.reason = 'Invalid password';
        user.addLoginAttempt(loginAttempt);
        await user.save();
        
        return res.status(401).json({
          success: false,
          message: 'Invalid credentials'
        });
      }

      // Check if device is trusted
      const existingDevice = user.devices.find(d => d.deviceId === deviceInfo.deviceId);
      const isNewDevice = !existingDevice;
      const isSuspiciousLogin = this.isSuspiciousLogin(user, req.ip, locationInfo);

      // Two-factor authentication check
      if (user.twoFactor.isEnabled && (isNewDevice || isSuspiciousLogin)) {
        if (!twoFactorCode) {
          return res.status(200).json({
            success: false,
            requiresTwoFactor: true,
            message: 'Two-factor authentication required',
            method: user.twoFactor.method
          });
        }

        const isValidTwoFactor = this.verifyTwoFactorCode(user, twoFactorCode);
        if (!isValidTwoFactor) {
          loginAttempt.reason = 'Invalid 2FA code';
          user.addLoginAttempt(loginAttempt);
          await user.save();
          
          return res.status(401).json({
            success: false,
            message: 'Invalid two-factor authentication code'
          });
        }

        user.twoFactor.lastUsed = new Date();
      }

      // Update user login info
      user.lastLogin = new Date();
      user.addDevice({
        deviceId: deviceInfo.deviceId,
        deviceName: deviceInfo.deviceName,
        deviceType: deviceInfo.deviceType,
        browser: deviceInfo.browser,
        os: deviceInfo.os,
        ipAddress: req.ip,
        location: locationInfo,
        isTrusted: !isNewDevice
      });

      loginAttempt.success = true;
      user.addLoginAttempt(loginAttempt);
      await user.save();

      // Send login alert for new device
      if (isNewDevice) {
        await this.sendLoginAlert(user, deviceInfo, locationInfo);
      }

      // Generate tokens
      const tokens = this.generateTokens(user._id);

      logger.info(`User logged in: ${user.username}`, {
        userId: user._id,
        ip: req.ip,
        newDevice: isNewDevice
      });

      res.json({
        success: true,
        message: 'Login successful',
        data: {
          user: user.toSafeObject(),
          tokens,
          isNewDevice
        }
      });
    } catch (error) {
      logger.error('Login error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Setup Two-Factor Authentication
  async setupTwoFactor(req, res) {
    try {
      const userId = req.user.id;
      const { method = 'app' } = req.body;

      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      if (user.twoFactor.isEnabled) {
        return res.status(400).json({
          success: false,
          message: 'Two-factor authentication is already enabled'
        });
      }

      let setupData = {};

      if (method === 'app') {
        // Generate secret for authenticator app
        const secret = speakeasy.generateSecret({
          name: `Smart Social (${user.username})`,
          issuer: 'Smart Social Platform'
        });

        // Generate QR code
        const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url);

        // Generate backup codes
        const backupCodes = Array.from({ length: 10 }, () => 
          crypto.randomBytes(4).toString('hex').toUpperCase()
        );

        user.twoFactor.secret = secret.base32;
        user.twoFactor.backupCodes = backupCodes;
        user.twoFactor.method = 'app';

        setupData = {
          secret: secret.base32,
          qrCode: qrCodeUrl,
          backupCodes,
          manualEntryKey: secret.base32
        };
      } else if (method === 'sms' && user.phone) {
        user.twoFactor.method = 'sms';
        setupData = {
          phoneNumber: user.phone.replace(/(\d{3})(\d{3})(\d{4})/, '***-***-$3')
        };
      } else if (method === 'email') {
        user.twoFactor.method = 'email';
        setupData = {
          email: user.email.replace(/(.{2})(.*)(@.*)/, '$1***$3')
        };
      }

      await user.save();

      res.json({
        success: true,
        message: 'Two-factor authentication setup initiated',
        data: setupData
      });
    } catch (error) {
      logger.error('2FA setup error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Verify and enable Two-Factor Authentication
  async verifyTwoFactor(req, res) {
    try {
      const userId = req.user.id;
      const { code } = req.body;

      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      const isValid = this.verifyTwoFactorCode(user, code);
      if (!isValid) {
        return res.status(400).json({
          success: false,
          message: 'Invalid verification code'
        });
      }

      user.twoFactor.isEnabled = true;
      user.twoFactor.lastUsed = new Date();
      await user.save();

      logger.info(`2FA enabled for user: ${user.username}`, {
        userId: user._id,
        method: user.twoFactor.method
      });

      res.json({
        success: true,
        message: 'Two-factor authentication enabled successfully',
        data: {
          backupCodes: user.twoFactor.backupCodes
        }
      });
    } catch (error) {
      logger.error('2FA verification error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Disable Two-Factor Authentication
  async disableTwoFactor(req, res) {
    try {
      const userId = req.user.id;
      const { password, code } = req.body;

      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      // Verify password
      const isPasswordValid = await user.comparePassword(password);
      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: 'Invalid password'
        });
      }

      // Verify 2FA code
      const isValidTwoFactor = this.verifyTwoFactorCode(user, code);
      if (!isValidTwoFactor) {
        return res.status(400).json({
          success: false,
          message: 'Invalid two-factor authentication code'
        });
      }

      user.twoFactor.isEnabled = false;
      user.twoFactor.secret = undefined;
      user.twoFactor.backupCodes = [];
      await user.save();

      logger.info(`2FA disabled for user: ${user.username}`, {
        userId: user._id
      });

      res.json({
        success: true,
        message: 'Two-factor authentication disabled successfully'
      });
    } catch (error) {
      logger.error('2FA disable error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get user devices
  async getDevices(req, res) {
    try {
      const userId = req.user.id;
      const user = await User.findById(userId).select('devices');

      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      const devices = user.devices.map(device => ({
        id: device._id,
        deviceName: device.deviceName,
        deviceType: device.deviceType,
        browser: device.browser,
        os: device.os,
        location: device.location,
        lastActive: device.lastActive,
        isTrusted: device.isTrusted,
        isCurrent: device.deviceId === this.getDeviceInfo(req).deviceId
      }));

      res.json({
        success: true,
        data: { devices }
      });
    } catch (error) {
      logger.error('Get devices error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Remove device
  async removeDevice(req, res) {
    try {
      const userId = req.user.id;
      const { deviceId } = req.params;

      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      const deviceIndex = user.devices.findIndex(d => d._id.toString() === deviceId);
      if (deviceIndex === -1) {
        return res.status(404).json({
          success: false,
          message: 'Device not found'
        });
      }

      user.devices.splice(deviceIndex, 1);
      await user.save();

      logger.info(`Device removed for user: ${user.username}`, {
        userId: user._id,
        deviceId
      });

      res.json({
        success: true,
        message: 'Device removed successfully'
      });
    } catch (error) {
      logger.error('Remove device error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Logout from all devices
  async logoutAllDevices(req, res) {
    try {
      const userId = req.user.id;
      const user = await User.findById(userId);

      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      user.devices = [];
      await user.save();

      logger.info(`User logged out from all devices: ${user.username}`, {
        userId: user._id
      });

      res.json({
        success: true,
        message: 'Logged out from all devices successfully'
      });
    } catch (error) {
      logger.error('Logout all devices error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Helper methods
  generateTokens(userId) {
    const accessToken = jwt.sign(
      { userId },
      process.env.JWT_SECRET,
      { expiresIn: '15m' }
    );

    const refreshToken = jwt.sign(
      { userId },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );

    return { accessToken, refreshToken };
  }

  getDeviceInfo(req) {
    const userAgent = req.get('User-Agent') || '';
    const detector = new DeviceDetector();
    const device = detector.parse(userAgent);

    return {
      deviceId: crypto.createHash('md5').update(userAgent + req.ip).digest('hex'),
      deviceName: device.device?.model || 'Unknown Device',
      deviceType: device.device?.type || 'desktop',
      browser: device.client?.name || 'Unknown Browser',
      os: device.os?.name || 'Unknown OS'
    };
  }

  getLocationInfo(ip) {
    const geo = geoip.lookup(ip);
    return geo ? {
      country: geo.country,
      city: geo.city,
      coordinates: [geo.ll[1], geo.ll[0]] // [longitude, latitude]
    } : null;
  }

  isSuspiciousLogin(user, ip, location) {
    const recentLogins = user.loginAttempts
      .filter(attempt => attempt.success && attempt.timestamp > new Date(Date.now() - 24 * 60 * 60 * 1000))
      .slice(-5);

    if (recentLogins.length === 0) return false;

    const differentCountries = recentLogins.some(login => 
      login.location?.country && location?.country && 
      login.location.country !== location.country
    );

    const differentIPs = recentLogins.some(login => login.ipAddress !== ip);

    return differentCountries || (differentIPs && recentLogins.length < 3);
  }

  verifyTwoFactorCode(user, code) {
    if (!user.twoFactor.secret) return false;

    // Check if it's a backup code
    if (user.twoFactor.backupCodes.includes(code.toUpperCase())) {
      const index = user.twoFactor.backupCodes.indexOf(code.toUpperCase());
      user.twoFactor.backupCodes.splice(index, 1);
      return true;
    }

    // Verify TOTP code
    return speakeasy.totp.verify({
      secret: user.twoFactor.secret,
      encoding: 'base32',
      token: code,
      window: 2
    });
  }

  async sendVerificationEmail(user) {
    const verificationUrl = `${process.env.FRONTEND_URL}/verify-email?token=${user.emailVerificationToken}`;
    
    await sendEmail({
      to: user.email,
      subject: 'Verify Your Email - Smart Social Platform',
      template: 'email-verification',
      data: {
        name: user.fullName,
        verificationUrl
      }
    });
  }

  async sendLoginAlert(user, deviceInfo, locationInfo) {
    const message = `New login detected on your Smart Social account from ${deviceInfo.deviceName} in ${locationInfo?.city || 'Unknown location'}`;
    
    if (user.notificationSettings.email) {
      await sendEmail({
        to: user.email,
        subject: 'New Login Alert - Smart Social Platform',
        template: 'login-alert',
        data: {
          name: user.fullName,
          device: deviceInfo.deviceName,
          location: locationInfo?.city || 'Unknown location',
          time: new Date().toLocaleString()
        }
      });
    }

    if (user.notificationSettings.sms && user.phone) {
      await sendSMS(user.phone, message);
    }
  }

  // Refresh token
  async refreshToken(req, res) {
    try {
      const { refreshToken } = req.body;
      
      if (!refreshToken) {
        return res.status(401).json({
          success: false,
          message: 'Refresh token required'
        });
      }

      const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
      const user = await User.findById(decoded.userId);

      if (!user || !user.isActive) {
        return res.status(401).json({
          success: false,
          message: 'Invalid refresh token'
        });
      }

      const tokens = this.generateTokens(user._id);
      
      res.json({
        success: true,
        data: { tokens }
      });
    } catch (error) {
      logger.error('Refresh token error:', error);
      res.status(401).json({
        success: false,
        message: 'Invalid refresh token'
      });
    }
  }

  // Get profile
  async getProfile(req, res) {
    try {
      const user = await User.findById(req.user.id)
        .select('-password -twoFactor.secret -twoFactor.backupCodes');

      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      res.json({
        success: true,
        data: { user: user.toSafeObject() }
      });
    } catch (error) {
      logger.error('Get profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Update profile
  async updateProfile(req, res) {
    try {
      const userId = req.user.id;
      const updates = req.body;
      
      delete updates.password;
      delete updates.email;
      delete updates.twoFactor;
      
      const user = await User.findByIdAndUpdate(
        userId,
        updates,
        { new: true, runValidators: true }
      ).select('-password -twoFactor.secret -twoFactor.backupCodes');

      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      res.json({
        success: true,
        message: 'Profile updated successfully',
        data: { user: user.toSafeObject() }
      });
    } catch (error) {
      logger.error('Update profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Change password
  async changePassword(req, res) {
    try {
      const userId = req.user.id;
      const { currentPassword, newPassword } = req.body;

      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      const isCurrentPasswordValid = await user.comparePassword(currentPassword);
      if (!isCurrentPasswordValid) {
        return res.status(400).json({
          success: false,
          message: 'Current password is incorrect'
        });
      }

      user.password = newPassword;
      await user.save();

      res.json({
        success: true,
        message: 'Password changed successfully'
      });
    } catch (error) {
      logger.error('Change password error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Forgot password
  async forgotPassword(req, res) {
    try {
      const { email } = req.body;
      const user = await User.findOne({ email });

      if (!user) {
        return res.json({
          success: true,
          message: 'If an account exists, a reset link has been sent'
        });
      }

      const resetToken = user.generatePasswordResetToken();
      await user.save();

      const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;
      
      await sendEmail({
        to: user.email,
        template: 'password-reset',
        data: {
          name: user.fullName,
          resetUrl
        }
      });

      res.json({
        success: true,
        message: 'If an account exists, a reset link has been sent'
      });
    } catch (error) {
      logger.error('Forgot password error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Reset password
  async resetPassword(req, res) {
    try {
      const { token, password } = req.body;
      const crypto = require('crypto');
      const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

      const user = await User.findOne({
        passwordResetToken: hashedToken,
        passwordResetExpires: { $gt: Date.now() }
      });

      if (!user) {
        return res.status(400).json({
          success: false,
          message: 'Invalid or expired reset token'
        });
      }

      user.password = password;
      user.passwordResetToken = undefined;
      user.passwordResetExpires = undefined;
      await user.save();

      res.json({
        success: true,
        message: 'Password reset successfully'
      });
    } catch (error) {
      logger.error('Reset password error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Verify email
  async verifyEmail(req, res) {
    try {
      const { token } = req.body;
      const user = await User.findOne({ emailVerificationToken: token });

      if (!user) {
        return res.status(400).json({
          success: false,
          message: 'Invalid verification token'
        });
      }

      user.emailVerified = true;
      user.emailVerificationToken = undefined;
      await user.save();

      res.json({
        success: true,
        message: 'Email verified successfully'
      });
    } catch (error) {
      logger.error('Email verification error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Google OAuth
  async googleAuth(req, res) {
    try {
      const { idToken } = req.body;
      
      res.json({
        success: true,
        message: 'Google authentication not implemented yet'
      });
    } catch (error) {
      logger.error('Google auth error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Apple OAuth
  async appleAuth(req, res) {
    try {
      const { identityToken } = req.body;
      
      res.json({
        success: true,
        message: 'Apple authentication not implemented yet'
      });
    } catch (error) {
      logger.error('Apple auth error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Logout
  async logout(req, res) {
    try {
      const userId = req.user.id;
      const deviceInfo = this.getDeviceInfo(req);

      const user = await User.findById(userId);
      if (user) {
        user.devices = user.devices.filter(d => d.deviceId !== deviceInfo.deviceId);
        await user.save();
      }

      res.json({
        success: true,
        message: 'Logged out successfully'
      });
    } catch (error) {
      logger.error('Logout error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}

module.exports = new AuthController();