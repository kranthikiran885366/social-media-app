const express = require('express');
const mongoose = require('mongoose');
const { OpenAI } = require('openai');
const vision = require('@google-cloud/vision');
const tf = require('@tensorflow/tfjs-node');

const app = express();
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const visionClient = new vision.ImageAnnotatorClient();

app.use(express.json());

const ModerationResultSchema = new mongoose.Schema({
  contentId: { type: mongoose.Schema.Types.ObjectId, required: true },
  contentType: { type: String, enum: ['post', 'comment', 'story', 'reel'], required: true },
  scores: {
    qualityScore: { type: Number, min: 0, max: 10 },
    toxicityScore: { type: Number, min: 0, max: 1 },
    spamScore: { type: Number, min: 0, max: 1 },
    educationalValue: { type: Number, min: 0, max: 10 },
    engagementPrediction: { type: Number, min: 0, max: 1 }
  },
  flags: {
    isSpam: Boolean,
    isHateSpeech: Boolean,
    isViolent: Boolean,
    isAdult: Boolean,
    isMisinformation: Boolean
  },
  decision: { type: String, enum: ['approved', 'rejected', 'review'], required: true },
  confidence: { type: Number, min: 0, max: 1 },
  processingTime: Number
}, { timestamps: true });

const ModerationResult = mongoose.model('ModerationResult', ModerationResultSchema);

class AIModerationService {
  static async moderateContent(contentData) {
    const startTime = Date.now();
    
    const [textAnalysis, imageAnalysis, videoAnalysis] = await Promise.all([
      this.analyzeText(contentData.text),
      this.analyzeImages(contentData.images),
      this.analyzeVideo(contentData.video)
    ]);

    const qualityScore = this.calculateQualityScore(textAnalysis, imageAnalysis, videoAnalysis);
    const decision = this.makeDecision(qualityScore, textAnalysis, imageAnalysis);
    
    const result = new ModerationResult({
      contentId: contentData.contentId,
      contentType: contentData.type,
      scores: {
        qualityScore,
        toxicityScore: textAnalysis.toxicity,
        spamScore: textAnalysis.spam,
        educationalValue: textAnalysis.educational,
        engagementPrediction: await this.predictEngagement(contentData)
      },
      flags: {
        isSpam: textAnalysis.spam > 0.7,
        isHateSpeech: textAnalysis.toxicity > 0.8,
        isViolent: imageAnalysis.violence > 0.7,
        isAdult: imageAnalysis.adult > 0.8,
        isMisinformation: textAnalysis.misinformation > 0.6
      },
      decision,
      confidence: Math.min(textAnalysis.confidence, imageAnalysis.confidence),
      processingTime: Date.now() - startTime
    });

    await result.save();
    return result;
  }

  static async analyzeText(text) {
    if (!text) return { toxicity: 0, spam: 0, educational: 5, confidence: 1 };

    const [toxicityResult, spamResult, educationalResult] = await Promise.all([
      this.detectToxicity(text),
      this.detectSpam(text),
      this.assessEducationalValue(text)
    ]);

    return {
      toxicity: toxicityResult.score,
      spam: spamResult.score,
      educational: educationalResult.score,
      misinformation: await this.detectMisinformation(text),
      confidence: (toxicityResult.confidence + spamResult.confidence + educationalResult.confidence) / 3
    };
  }

  static async analyzeImages(images) {
    if (!images || images.length === 0) return { adult: 0, violence: 0, confidence: 1 };

    const results = await Promise.all(images.map(async (image) => {
      const [safeSearch] = await visionClient.safeSearchDetection(image);
      const annotations = safeSearch.safeSearchAnnotation;
      
      return {
        adult: this.convertLikelihoodToScore(annotations.adult),
        violence: this.convertLikelihoodToScore(annotations.violence),
        racy: this.convertLikelihoodToScore(annotations.racy)
      };
    }));

    return {
      adult: Math.max(...results.map(r => r.adult)),
      violence: Math.max(...results.map(r => r.violence)),
      confidence: 0.9
    };
  }

  static calculateQualityScore(textAnalysis, imageAnalysis, videoAnalysis) {
    const weights = {
      textQuality: 0.25,
      sentiment: 0.15,
      educational: 0.30,
      originality: 0.20,
      spamPenalty: -0.10
    };

    let score = 5; // Base score
    score += textAnalysis.educational * weights.educational;
    score += (1 - textAnalysis.toxicity) * weights.sentiment * 5;
    score -= textAnalysis.spam * weights.spamPenalty * 10;
    
    return Math.max(0, Math.min(10, score));
  }

  static makeDecision(qualityScore, textAnalysis, imageAnalysis) {
    if (qualityScore < 3 || textAnalysis.toxicity > 0.8 || imageAnalysis.adult > 0.8) {
      return 'rejected';
    }
    if (qualityScore >= 6 && textAnalysis.toxicity < 0.3) {
      return 'approved';
    }
    return 'review';
  }

  static async detectToxicity(text) {
    try {
      const response = await openai.moderations.create({ input: text });
      const result = response.results[0];
      return {
        score: Math.max(...Object.values(result.category_scores)),
        confidence: 0.95
      };
    } catch (error) {
      return { score: 0, confidence: 0.5 };
    }
  }

  static async detectSpam(text) {
    const spamIndicators = [
      /\b(buy now|click here|limited time|act now)\b/gi,
      /\b(free|win|prize|lottery)\b/gi,
      /(http|www)\./gi,
      /(.)\1{4,}/g // Repeated characters
    ];

    let spamScore = 0;
    spamIndicators.forEach(pattern => {
      if (pattern.test(text)) spamScore += 0.2;
    });

    return { score: Math.min(1, spamScore), confidence: 0.8 };
  }

  static async assessEducationalValue(text) {
    const educationalKeywords = [
      'learn', 'education', 'tutorial', 'how to', 'guide', 'tips',
      'science', 'history', 'technology', 'research', 'study'
    ];

    let score = 3; // Base educational score
    educationalKeywords.forEach(keyword => {
      if (text.toLowerCase().includes(keyword)) score += 0.5;
    });

    return { score: Math.min(10, score), confidence: 0.7 };
  }

  static convertLikelihoodToScore(likelihood) {
    const mapping = {
      'VERY_UNLIKELY': 0.1,
      'UNLIKELY': 0.3,
      'POSSIBLE': 0.5,
      'LIKELY': 0.7,
      'VERY_LIKELY': 0.9
    };
    return mapping[likelihood] || 0;
  }
}

app.post('/api/moderate', async (req, res) => {
  try {
    const result = await AIModerationService.moderateContent(req.body);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3005;
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_moderation')
  .then(() => app.listen(PORT, () => console.log(`AI Moderation service running on port ${PORT}`)));