const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const speakeasy = require('speakeasy');
const QRCode = require('qrcode');

const app = express();
app.use(express.json());

const SecurityEventSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  eventType: { type: String, enum: ['login', 'failed_login', 'password_change', '2fa_setup', 'suspicious_activity'], required: true },
  severity: { type: String, enum: ['low', 'medium', 'high', 'critical'], default: 'medium' },
  details: {
    ipAddress: String,
    userAgent: String,
    location: String,
    deviceId: String,
    timestamp: { type: Date, default: Date.now }
  },
  resolved: { type: Boolean, default: false },
  actions: [String]
});

const DeviceSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  deviceId: { type: String, required: true },
  deviceName: String,
  deviceType: String,
  lastLogin: { type: Date, default: Date.now },
  location: String,
  ipAddress: String,
  isActive: { type: Boolean, default: true },
  isTrusted: { type: Boolean, default: false }
});

const TwoFactorSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  secret: { type: String, required: true },
  backupCodes: [String],
  isEnabled: { type: Boolean, default: false },
  lastUsed: Date
});

const SecurityEvent = mongoose.model('SecurityEvent', SecurityEventSchema);
const Device = mongoose.model('Device', DeviceSchema);
const TwoFactor = mongoose.model('TwoFactor', TwoFactorSchema);

class SecurityService {
  static async setup2FA(userId) {
    const secret = speakeasy.generateSecret({
      name: 'Smart Social Platform',
      account: userId,
      length: 32
    });

    const backupCodes = Array.from({ length: 10 }, () => 
      Math.random().toString(36).substring(2, 8).toUpperCase()
    );

    const twoFactor = new TwoFactor({
      userId,
      secret: secret.base32,
      backupCodes: backupCodes.map(code => bcrypt.hashSync(code, 10))
    });

    await twoFactor.save();

    const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url);

    return {
      secret: secret.base32,
      qrCode: qrCodeUrl,
      backupCodes
    };
  }

  static async verify2FA(userId, token) {
    const twoFactor = await TwoFactor.findOne({ userId });
    if (!twoFactor) throw new Error('2FA not setup');

    const verified = speakeasy.totp.verify({
      secret: twoFactor.secret,
      encoding: 'base32',
      token,
      window: 2
    });

    if (verified) {
      twoFactor.lastUsed = new Date();
      await twoFactor.save();
    }

    return verified;
  }

  static async trackSecurityEvent(userId, eventType, details) {
    const event = new SecurityEvent({
      userId,
      eventType,
      severity: this.calculateSeverity(eventType, details),
      details
    });

    await event.save();

    if (event.severity === 'high' || event.severity === 'critical') {
      await this.triggerSecurityAlert(userId, event);
    }

    return event;
  }

  static async registerDevice(userId, deviceInfo) {
    const device = new Device({
      userId,
      deviceId: deviceInfo.deviceId,
      deviceName: deviceInfo.name,
      deviceType: deviceInfo.type,
      location: deviceInfo.location,
      ipAddress: deviceInfo.ipAddress
    });

    await device.save();
    return device;
  }

  static async getSecurityDashboard(userId) {
    const [events, devices, twoFactor] = await Promise.all([
      SecurityEvent.find({ userId }).sort({ 'details.timestamp': -1 }).limit(10),
      Device.find({ userId, isActive: true }),
      TwoFactor.findOne({ userId })
    ]);

    return {
      recentEvents: events,
      activeDevices: devices,
      twoFactorEnabled: twoFactor?.isEnabled || false,
      securityScore: await this.calculateSecurityScore(userId)
    };
  }

  static async calculateSecurityScore(userId) {
    const [twoFactor, recentEvents, deviceCount] = await Promise.all([
      TwoFactor.findOne({ userId }),
      SecurityEvent.countDocuments({ 
        userId, 
        'details.timestamp': { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }
      }),
      Device.countDocuments({ userId, isActive: true })
    ]);

    let score = 50; // Base score
    
    if (twoFactor?.isEnabled) score += 30;
    if (recentEvents === 0) score += 20;
    if (deviceCount <= 3) score += 10;
    
    return Math.min(100, score);
  }

  static calculateSeverity(eventType, details) {
    const severityMap = {
      'login': 'low',
      'failed_login': 'medium',
      'password_change': 'medium',
      '2fa_setup': 'low',
      'suspicious_activity': 'high'
    };

    return severityMap[eventType] || 'medium';
  }

  static async triggerSecurityAlert(userId, event) {
    // Send notification to user about security event
    console.log(`Security alert for user ${userId}:`, event);
  }
}

app.post('/api/security/2fa/setup', async (req, res) => {
  try {
    const result = await SecurityService.setup2FA(req.body.userId);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/security/2fa/verify', async (req, res) => {
  try {
    const { userId, token } = req.body;
    const verified = await SecurityService.verify2FA(userId, token);
    res.json({ verified });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/security/events', async (req, res) => {
  try {
    const { userId, eventType, details } = req.body;
    const event = await SecurityService.trackSecurityEvent(userId, eventType, details);
    res.json(event);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/security/dashboard/:userId', async (req, res) => {
  try {
    const dashboard = await SecurityService.getSecurityDashboard(req.params.userId);
    res.json(dashboard);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3017;
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_security')
  .then(() => app.listen(PORT, () => console.log(`Security service running on port ${PORT}`)));