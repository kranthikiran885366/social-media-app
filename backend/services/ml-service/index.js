const express = require('express');
const tf = require('@tensorflow/tfjs-node');
const mongoose = require('mongoose');

const app = express();
app.use(express.json());

const MLModelSchema = new mongoose.Schema({
  name: { type: String, required: true },
  version: { type: String, required: true },
  type: { type: String, enum: ['recommendation', 'moderation', 'ranking', 'prediction'], required: true },
  accuracy: Number,
  trainingData: {
    samples: Number,
    features: Number,
    lastTrained: Date
  },
  parameters: Object,
  isActive: { type: Boolean, default: false }
});

const PredictionSchema = new mongoose.Schema({
  modelName: String,
  inputData: Object,
  prediction: Object,
  confidence: Number,
  timestamp: { type: Date, default: Date.now }
});

const MLModel = mongoose.model('MLModel', MLModelSchema);
const Prediction = mongoose.model('Prediction', PredictionSchema);

class MLService {
  constructor() {
    this.models = new Map();
    this.loadModels();
  }

  async loadModels() {
    // Load recommendation model
    this.models.set('recommendation', await this.createRecommendationModel());
    
    // Load content ranking model
    this.models.set('ranking', await this.createRankingModel());
    
    // Load engagement prediction model
    this.models.set('engagement', await this.createEngagementModel());
    
    console.log('ML models loaded successfully');
  }

  async createRecommendationModel() {
    const model = tf.sequential({
      layers: [
        tf.layers.dense({ inputShape: [50], units: 128, activation: 'relu' }),
        tf.layers.dropout({ rate: 0.2 }),
        tf.layers.dense({ units: 64, activation: 'relu' }),
        tf.layers.dropout({ rate: 0.2 }),
        tf.layers.dense({ units: 32, activation: 'relu' }),
        tf.layers.dense({ units: 1, activation: 'sigmoid' })
      ]
    });

    model.compile({
      optimizer: 'adam',
      loss: 'binaryCrossentropy',
      metrics: ['accuracy']
    });

    return model;
  }

  async createRankingModel() {
    const model = tf.sequential({
      layers: [
        tf.layers.dense({ inputShape: [20], units: 64, activation: 'relu' }),
        tf.layers.dense({ units: 32, activation: 'relu' }),
        tf.layers.dense({ units: 16, activation: 'relu' }),
        tf.layers.dense({ units: 1, activation: 'linear' })
      ]
    });

    model.compile({
      optimizer: 'adam',
      loss: 'meanSquaredError',
      metrics: ['mae']
    });

    return model;
  }

  async createEngagementModel() {
    const model = tf.sequential({
      layers: [
        tf.layers.dense({ inputShape: [30], units: 100, activation: 'relu' }),
        tf.layers.dropout({ rate: 0.3 }),
        tf.layers.dense({ units: 50, activation: 'relu' }),
        tf.layers.dense({ units: 25, activation: 'relu' }),
        tf.layers.dense({ units: 1, activation: 'sigmoid' })
      ]
    });

    model.compile({
      optimizer: 'adam',
      loss: 'binaryCrossentropy',
      metrics: ['accuracy']
    });

    return model;
  }

  async predictRecommendation(userFeatures, contentFeatures) {
    const model = this.models.get('recommendation');
    if (!model) throw new Error('Recommendation model not loaded');

    const input = tf.tensor2d([userFeatures.concat(contentFeatures)]);
    const prediction = await model.predict(input);
    const score = await prediction.data();
    
    input.dispose();
    prediction.dispose();

    return {
      score: score[0],
      confidence: Math.min(0.95, score[0] + 0.1)
    };
  }

  async rankContent(contentList, userContext) {
    const model = this.models.get('ranking');
    if (!model) throw new Error('Ranking model not loaded');

    const rankedContent = [];

    for (const content of contentList) {
      const features = this.extractRankingFeatures(content, userContext);
      const input = tf.tensor2d([features]);
      const prediction = await model.predict(input);
      const score = await prediction.data();

      rankedContent.push({
        ...content,
        mlScore: score[0]
      });

      input.dispose();
      prediction.dispose();
    }

    return rankedContent.sort((a, b) => b.mlScore - a.mlScore);
  }

  async predictEngagement(contentData, userData) {
    const model = this.models.get('engagement');
    if (!model) throw new Error('Engagement model not loaded');

    const features = this.extractEngagementFeatures(contentData, userData);
    const input = tf.tensor2d([features]);
    const prediction = await model.predict(input);
    const probability = await prediction.data();

    input.dispose();
    prediction.dispose();

    return {
      engagementProbability: probability[0],
      expectedLikes: Math.floor(probability[0] * 1000),
      expectedComments: Math.floor(probability[0] * 100),
      expectedShares: Math.floor(probability[0] * 50)
    };
  }

  extractRankingFeatures(content, userContext) {
    return [
      content.likes || 0,
      content.comments || 0,
      content.shares || 0,
      content.views || 0,
      this.calculateRecency(content.createdAt),
      this.calculateRelevance(content, userContext),
      content.authorFollowers || 0,
      userContext.followsAuthor ? 1 : 0,
      this.calculateContentQuality(content),
      userContext.engagementHistory || 0,
      // Add more features as needed
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0 // Padding to reach 20 features
    ];
  }

  extractEngagementFeatures(contentData, userData) {
    return [
      contentData.textLength || 0,
      contentData.hasImage ? 1 : 0,
      contentData.hasVideo ? 1 : 0,
      contentData.hashtagCount || 0,
      contentData.mentionCount || 0,
      userData.followerCount || 0,
      userData.followingCount || 0,
      userData.avgEngagement || 0,
      this.getTimeOfDay(),
      this.getDayOfWeek(),
      // Add more features
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 // Padding to 30
    ];
  }

  calculateRecency(createdAt) {
    const now = new Date();
    const created = new Date(createdAt);
    const hoursDiff = (now - created) / (1000 * 60 * 60);
    return Math.max(0, 1 - (hoursDiff / 24)); // Normalize to 0-1
  }

  calculateRelevance(content, userContext) {
    // Simple relevance calculation based on user interests
    const userInterests = userContext.interests || [];
    const contentTags = content.tags || [];
    const overlap = userInterests.filter(interest => contentTags.includes(interest));
    return overlap.length / Math.max(userInterests.length, 1);
  }

  calculateContentQuality(content) {
    // Simple quality score based on engagement ratio
    const totalEngagement = (content.likes || 0) + (content.comments || 0) + (content.shares || 0);
    const views = content.views || 1;
    return Math.min(1, totalEngagement / views);
  }

  getTimeOfDay() {
    return new Date().getHours() / 24;
  }

  getDayOfWeek() {
    return new Date().getDay() / 7;
  }

  async trainModel(modelName, trainingData) {
    const model = this.models.get(modelName);
    if (!model) throw new Error(`Model ${modelName} not found`);

    const { inputs, outputs } = trainingData;
    const xs = tf.tensor2d(inputs);
    const ys = tf.tensor2d(outputs);

    const history = await model.fit(xs, ys, {
      epochs: 50,
      batchSize: 32,
      validationSplit: 0.2,
      callbacks: {
        onEpochEnd: (epoch, logs) => {
          console.log(`Epoch ${epoch}: loss = ${logs.loss}, accuracy = ${logs.acc}`);
        }
      }
    });

    xs.dispose();
    ys.dispose();

    return {
      finalLoss: history.history.loss[history.history.loss.length - 1],
      finalAccuracy: history.history.acc[history.history.acc.length - 1]
    };
  }
}

const mlService = new MLService();

app.post('/api/ml/recommend', async (req, res) => {
  try {
    const { userFeatures, contentFeatures } = req.body;
    const prediction = await mlService.predictRecommendation(userFeatures, contentFeatures);
    res.json(prediction);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/ml/rank', async (req, res) => {
  try {
    const { contentList, userContext } = req.body;
    const rankedContent = await mlService.rankContent(contentList, userContext);
    res.json(rankedContent);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/ml/predict-engagement', async (req, res) => {
  try {
    const { contentData, userData } = req.body;
    const prediction = await mlService.predictEngagement(contentData, userData);
    res.json(prediction);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/ml/train/:modelName', async (req, res) => {
  try {
    const { modelName } = req.params;
    const { trainingData } = req.body;
    const result = await mlService.trainModel(modelName, trainingData);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3019;
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_ml')
  .then(() => app.listen(PORT, () => console.log(`ML service running on port ${PORT}`)));