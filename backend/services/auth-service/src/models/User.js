const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const deviceSchema = new mongoose.Schema({
  deviceId: { type: String, required: true },
  deviceName: String,
  deviceType: String,
  browser: String,
  os: String,
  ipAddress: String,
  location: {
    country: String,
    city: String,
    coordinates: [Number]
  },
  lastActive: { type: Date, default: Date.now },
  isTrusted: { type: Boolean, default: false },
  pushToken: String
});

const loginAttemptSchema = new mongoose.Schema({
  ipAddress: String,
  userAgent: String,
  success: Boolean,
  timestamp: { type: Date, default: Date.now },
  location: {
    country: String,
    city: String
  },
  reason: String
});

const twoFactorSchema = new mongoose.Schema({
  secret: String,
  backupCodes: [String],
  isEnabled: { type: Boolean, default: false },
  lastUsed: Date,
  method: { type: String, enum: ['app', 'sms', 'email'], default: 'app' }
});

const privacySettingsSchema = new mongoose.Schema({
  profileVisibility: { type: String, enum: ['public', 'private', 'friends'], default: 'public' },
  showOnlineStatus: { type: Boolean, default: true },
  allowMessageRequests: { type: Boolean, default: true },
  showActivityStatus: { type: Boolean, default: true },
  allowTagging: { type: String, enum: ['everyone', 'friends', 'none'], default: 'everyone' },
  allowStoryResharing: { type: Boolean, default: true },
  showInSuggestions: { type: Boolean, default: true },
  dataDownloadRequests: [{ requestedAt: Date, status: String, downloadUrl: String }]
});

const userSchema = new mongoose.Schema({
  // Basic Info
  username: { type: String, required: true, unique: true, trim: true, minlength: 3, maxlength: 30 },
  email: { type: String, required: true, unique: true, lowercase: true },
  phone: { type: String, sparse: true },
  password: { type: String, required: true, minlength: 8 },
  
  // Profile
  fullName: { type: String, required: true, trim: true },
  bio: { type: String, maxlength: 150 },
  website: String,
  profilePicture: String,
  coverPhoto: String,
  dateOfBirth: Date,
  gender: { type: String, enum: ['male', 'female', 'other', 'prefer_not_to_say'] },
  
  // Account Status
  isVerified: { type: Boolean, default: false },
  isActive: { type: Boolean, default: true },
  isBanned: { type: Boolean, default: false },
  banReason: String,
  banExpiresAt: Date,
  
  // Verification
  emailVerified: { type: Boolean, default: false },
  phoneVerified: { type: Boolean, default: false },
  emailVerificationToken: String,
  phoneVerificationCode: String,
  verificationCodeExpires: Date,
  
  // Password Reset
  passwordResetToken: String,
  passwordResetExpires: Date,
  
  // Security
  twoFactor: twoFactorSchema,
  devices: [deviceSchema],
  loginAttempts: [loginAttemptSchema],
  lastLogin: Date,
  lastPasswordChange: { type: Date, default: Date.now },
  securityQuestions: [{
    question: String,
    answer: String
  }],
  
  // Privacy & Settings
  privacySettings: privacySettingsSchema,
  notificationSettings: {
    push: { type: Boolean, default: true },
    email: { type: Boolean, default: true },
    sms: { type: Boolean, default: false },
    likes: { type: Boolean, default: true },
    comments: { type: Boolean, default: true },
    follows: { type: Boolean, default: true },
    mentions: { type: Boolean, default: true },
    directMessages: { type: Boolean, default: true },
    liveVideos: { type: Boolean, default: true },
    reminders: { type: Boolean, default: true }
  },
  
  // Social Stats
  followersCount: { type: Number, default: 0 },
  followingCount: { type: Number, default: 0 },
  postsCount: { type: Number, default: 0 },
  
  // Business Account
  accountType: { type: String, enum: ['personal', 'business', 'creator'], default: 'personal' },
  businessInfo: {
    category: String,
    contactEmail: String,
    phoneNumber: String,
    address: String,
    website: String
  },
  
  // Creator Features
  creatorInfo: {
    isMonetized: { type: Boolean, default: false },
    totalEarnings: { type: Number, default: 0 },
    subscribersCount: { type: Number, default: 0 },
    averageViews: { type: Number, default: 0 }
  },
  
  // Time Management
  timeLimit: {
    dailyLimit: { type: Number, default: 0 }, // minutes, 0 = no limit
    breakReminders: { type: Boolean, default: false },
    sleepMode: {
      enabled: { type: Boolean, default: false },
      startTime: String, // "22:00"
      endTime: String    // "07:00"
    },
    weeklyReport: { type: Boolean, default: true }
  },
  
  // Blocked Users & Content
  blockedUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  mutedUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  restrictedUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  
  // Location
  location: {
    country: String,
    city: String,
    timezone: String,
    coordinates: [Number]
  },
  
  // Preferences
  language: { type: String, default: 'en' },
  theme: { type: String, enum: ['light', 'dark', 'auto'], default: 'auto' },
  
  // Analytics Consent
  analyticsConsent: { type: Boolean, default: false },
  marketingConsent: { type: Boolean, default: false },
  
  // Subscription
  subscription: {
    plan: { type: String, enum: ['free', 'premium', 'pro'], default: 'free' },
    expiresAt: Date,
    autoRenew: { type: Boolean, default: false }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes
userSchema.index({ username: 1 });
userSchema.index({ email: 1 });
userSchema.index({ phone: 1 });
userSchema.index({ 'devices.deviceId': 1 });
userSchema.index({ createdAt: -1 });
userSchema.index({ lastLogin: -1 });

// Virtual for profile completion
userSchema.virtual('profileCompletion').get(function() {
  let completion = 0;
  const fields = ['fullName', 'bio', 'profilePicture', 'dateOfBirth'];
  fields.forEach(field => {
    if (this[field]) completion += 25;
  });
  return completion;
});

// Pre-save middleware
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    this.lastPasswordChange = new Date();
    next();
  } catch (error) {
    next(error);
  }
});

// Methods
userSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

userSchema.methods.generatePasswordResetToken = function() {
  const crypto = require('crypto');
  const resetToken = crypto.randomBytes(32).toString('hex');
  this.passwordResetToken = crypto.createHash('sha256').update(resetToken).digest('hex');
  this.passwordResetExpires = Date.now() + 10 * 60 * 1000; // 10 minutes
  return resetToken;
};

userSchema.methods.addDevice = function(deviceInfo) {
  const existingDevice = this.devices.find(d => d.deviceId === deviceInfo.deviceId);
  if (existingDevice) {
    existingDevice.lastActive = new Date();
    existingDevice.ipAddress = deviceInfo.ipAddress;
    existingDevice.location = deviceInfo.location;
  } else {
    this.devices.push(deviceInfo);
  }
};

userSchema.methods.addLoginAttempt = function(attemptInfo) {
  this.loginAttempts.push(attemptInfo);
  // Keep only last 50 attempts
  if (this.loginAttempts.length > 50) {
    this.loginAttempts = this.loginAttempts.slice(-50);
  }
};

userSchema.methods.toSafeObject = function() {
  const userObject = this.toObject();
  delete userObject.password;
  delete userObject.twoFactor.secret;
  delete userObject.twoFactor.backupCodes;
  delete userObject.passwordResetToken;
  delete userObject.emailVerificationToken;
  delete userObject.phoneVerificationCode;
  return userObject;
};

module.exports = mongoose.model('User', userSchema);