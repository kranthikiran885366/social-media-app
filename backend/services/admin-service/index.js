const express = require('express');
const mongoose = require('mongoose');

const app = express();
app.use(express.json());

const AdminActionSchema = new mongoose.Schema({
  adminId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  action: { type: String, required: true },
  targetType: { type: String, enum: ['user', 'post', 'comment', 'report'], required: true },
  targetId: { type: mongoose.Schema.Types.ObjectId, required: true },
  reason: String,
  details: Object,
  timestamp: { type: Date, default: Date.now }
});

const ReportSchema = new mongoose.Schema({
  reporterId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  targetType: { type: String, enum: ['user', 'post', 'comment', 'story'], required: true },
  targetId: { type: mongoose.Schema.Types.ObjectId, required: true },
  reason: { type: String, required: true },
  description: String,
  status: { type: String, enum: ['pending', 'reviewed', 'resolved', 'dismissed'], default: 'pending' },
  priority: { type: String, enum: ['low', 'medium', 'high', 'urgent'], default: 'medium' },
  assignedTo: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  resolution: String,
  createdAt: { type: Date, default: Date.now },
  resolvedAt: Date
});

const SystemMetricsSchema = new mongoose.Schema({
  date: { type: Date, required: true },
  metrics: {
    activeUsers: Number,
    newUsers: Number,
    totalPosts: Number,
    totalComments: Number,
    reportCount: Number,
    moderationActions: Number,
    serverUptime: Number,
    errorRate: Number
  }
});

const AdminAction = mongoose.model('AdminAction', AdminActionSchema);
const Report = mongoose.model('Report', ReportSchema);
const SystemMetrics = mongoose.model('SystemMetrics', SystemMetricsSchema);

class AdminService {
  static async getDashboard() {
    const [userStats, contentStats, reportStats, systemHealth] = await Promise.all([
      this.getUserStats(),
      this.getContentStats(),
      this.getReportStats(),
      this.getSystemHealth()
    ]);

    return {
      users: userStats,
      content: contentStats,
      reports: reportStats,
      system: systemHealth
    };
  }

  static async getUserStats() {
    const today = new Date();
    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
    const lastWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);

    return {
      total: await this.getUserCount(),
      newToday: await this.getUserCount({ createdAt: { $gte: yesterday } }),
      newThisWeek: await this.getUserCount({ createdAt: { $gte: lastWeek } }),
      active: await this.getActiveUserCount()
    };
  }

  static async getContentStats() {
    return {
      totalPosts: await this.getPostCount(),
      totalComments: await this.getCommentCount(),
      postsToday: await this.getPostCount({ createdAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) } }),
      flaggedContent: await this.getFlaggedContentCount()
    };
  }

  static async getReportStats() {
    const reports = await Report.aggregate([
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);

    return {
      pending: reports.find(r => r._id === 'pending')?.count || 0,
      reviewed: reports.find(r => r._id === 'reviewed')?.count || 0,
      resolved: reports.find(r => r._id === 'resolved')?.count || 0,
      total: reports.reduce((sum, r) => sum + r.count, 0)
    };
  }

  static async moderateContent(adminId, contentId, action, reason) {
    const adminAction = new AdminAction({
      adminId,
      action,
      targetType: 'post',
      targetId: contentId,
      reason,
      details: { moderationType: 'content' }
    });

    await adminAction.save();

    // Apply moderation action
    switch (action) {
      case 'approve':
        await this.approveContent(contentId);
        break;
      case 'reject':
        await this.rejectContent(contentId);
        break;
      case 'flag':
        await this.flagContent(contentId);
        break;
    }

    return adminAction;
  }

  static async handleReport(reportId, adminId, resolution) {
    const report = await Report.findByIdAndUpdate(reportId, {
      status: 'resolved',
      assignedTo: adminId,
      resolution,
      resolvedAt: new Date()
    }, { new: true });

    const adminAction = new AdminAction({
      adminId,
      action: 'resolve_report',
      targetType: 'report',
      targetId: reportId,
      details: { resolution }
    });

    await adminAction.save();
    return report;
  }

  static async banUser(adminId, userId, reason, duration) {
    const adminAction = new AdminAction({
      adminId,
      action: 'ban_user',
      targetType: 'user',
      targetId: userId,
      reason,
      details: { duration }
    });

    await adminAction.save();

    // Implement user ban logic
    await this.setBanStatus(userId, true, duration);

    return adminAction;
  }

  static async getSystemHealth() {
    return {
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      cpu: process.cpuUsage(),
      activeConnections: await this.getActiveConnections(),
      errorRate: await this.getErrorRate()
    };
  }

  static async getAnalytics(timeRange = '7d') {
    const days = parseInt(timeRange.replace('d', ''));
    const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    const metrics = await SystemMetrics.find({
      date: { $gte: startDate }
    }).sort({ date: 1 });

    return {
      userGrowth: metrics.map(m => ({ date: m.date, users: m.metrics.newUsers })),
      contentGrowth: metrics.map(m => ({ date: m.date, posts: m.metrics.totalPosts })),
      moderationActivity: metrics.map(m => ({ date: m.date, actions: m.metrics.moderationActions }))
    };
  }

  // Helper methods
  static async getUserCount(filter = {}) {
    // Mock implementation - replace with actual User model query
    return Math.floor(Math.random() * 10000);
  }

  static async getPostCount(filter = {}) {
    // Mock implementation
    return Math.floor(Math.random() * 50000);
  }

  static async getCommentCount(filter = {}) {
    // Mock implementation
    return Math.floor(Math.random() * 100000);
  }

  static async getActiveUserCount() {
    // Mock implementation
    return Math.floor(Math.random() * 5000);
  }

  static async getFlaggedContentCount() {
    // Mock implementation
    return Math.floor(Math.random() * 100);
  }

  static async approveContent(contentId) {
    console.log(`Approving content: ${contentId}`);
  }

  static async rejectContent(contentId) {
    console.log(`Rejecting content: ${contentId}`);
  }

  static async flagContent(contentId) {
    console.log(`Flagging content: ${contentId}`);
  }

  static async setBanStatus(userId, banned, duration) {
    console.log(`Setting ban status for user ${userId}: ${banned} for ${duration}`);
  }

  static async getActiveConnections() {
    return Math.floor(Math.random() * 1000);
  }

  static async getErrorRate() {
    return Math.random() * 0.05; // 0-5% error rate
  }
}

app.get('/api/admin/dashboard', async (req, res) => {
  try {
    const dashboard = await AdminService.getDashboard();
    res.json(dashboard);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/admin/moderate', async (req, res) => {
  try {
    const { adminId, contentId, action, reason } = req.body;
    const result = await AdminService.moderateContent(adminId, contentId, action, reason);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/admin/reports/:reportId/resolve', async (req, res) => {
  try {
    const { adminId, resolution } = req.body;
    const report = await AdminService.handleReport(req.params.reportId, adminId, resolution);
    res.json(report);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/admin/users/:userId/ban', async (req, res) => {
  try {
    const { adminId, reason, duration } = req.body;
    const result = await AdminService.banUser(adminId, req.params.userId, reason, duration);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/admin/analytics', async (req, res) => {
  try {
    const { timeRange } = req.query;
    const analytics = await AdminService.getAnalytics(timeRange);
    res.json(analytics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3018;
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_admin')
  .then(() => app.listen(PORT, () => console.log(`Admin service running on port ${PORT}`)));