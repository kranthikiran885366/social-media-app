const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// MongoDB Schemas
const CreatorInsightsSchema = new mongoose.Schema({
  userId: String,
  followers: {
    total: Number,
    gained: Number,
    lost: Number,
    growthRate: Number
  },
  engagement: {
    rate: Number,
    totalLikes: Number,
    totalComments: Number,
    totalShares: Number,
    bestPostingTimes: Object
  },
  demographics: {
    ageGroups: Object,
    locations: Object,
    genders: Object
  },
  monetization: {
    totalEarnings: Number,
    monthlyEarnings: Number,
    subscribers: Number
  },
  lastUpdated: { type: Date, default: Date.now }
});

const ContentDraftSchema = new mongoose.Schema({
  userId: String,
  type: String,
  content: String,
  mediaUrls: [String],
  scheduledTime: Date,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

const CreatorInsights = mongoose.model('CreatorInsights', CreatorInsightsSchema);
const ContentDraft = mongoose.model('ContentDraft', ContentDraftSchema);

// Routes
app.get('/api/creator/insights/:userId', async (req, res) => {
  try {
    const insights = await CreatorInsights.findOne({ userId: req.params.userId });
    res.json(insights || {});
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/creator/drafts/:userId', async (req, res) => {
  try {
    const drafts = await ContentDraft.find({ 
      userId: req.params.userId,
      scheduledTime: null
    });
    res.json(drafts);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/creator/drafts', async (req, res) => {
  try {
    const draft = new ContentDraft(req.body);
    await draft.save();
    res.json(draft);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/creator/drafts/:id', async (req, res) => {
  try {
    const draft = await ContentDraft.findByIdAndUpdate(
      req.params.id,
      { ...req.body, updatedAt: new Date() },
      { new: true }
    );
    res.json(draft);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/creator/drafts/:id', async (req, res) => {
  try {
    await ContentDraft.findByIdAndDelete(req.params.id);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3012;

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_creator')
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Creator service running on port ${PORT}`);
    });
  })
  .catch(err => console.error('MongoDB connection error:', err));