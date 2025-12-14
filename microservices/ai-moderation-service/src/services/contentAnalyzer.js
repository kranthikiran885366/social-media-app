const natural = require('natural');
const tf = require('@tensorflow/tfjs-node');

class ContentAnalyzer {
  constructor() {
    this.sentiment = new natural.SentimentAnalyzer('English', 
      natural.PorterStemmer, 'afinn');
    this.tokenizer = new natural.WordTokenizer();
    
    // Initialize quality keywords
    this.positiveKeywords = [
      'learn', 'inspire', 'create', 'achieve', 'grow', 'motivate',
      'educate', 'improve', 'develop', 'progress', 'success',
      'knowledge', 'skill', 'talent', 'innovation', 'creativity'
    ];
    
    this.negativeKeywords = [
      'hate', 'spam', 'fake', 'scam', 'clickbait', 'boring',
      'waste', 'stupid', 'useless', 'meaningless', 'trash'
    ];
    
    this.spamPatterns = [
      /follow\s+for\s+follow/i,
      /like\s+for\s+like/i,
      /check\s+my\s+bio/i,
      /dm\s+me/i,
      /free\s+money/i,
      /get\s+rich\s+quick/i
    ];
  }

  async analyzeContent(content, mediaUrls = [], contentType = 'post') {
    try {
      const analysis = {
        qualityScore: 0,
        isApproved: false,
        reasons: [],
        metrics: {
          textQuality: 0,
          sentiment: 0,
          educationalValue: 0,
          originalityScore: 0,
          spamScore: 0
        }
      };

      // Analyze text content
      if (content && content.trim().length > 0) {
        analysis.metrics.textQuality = this.analyzeTextQuality(content);
        analysis.metrics.sentiment = this.analyzeSentiment(content);
        analysis.metrics.educationalValue = this.analyzeEducationalValue(content);
        analysis.metrics.spamScore = this.analyzeSpamContent(content);
      }

      // Analyze media if present
      if (mediaUrls.length > 0) {
        analysis.metrics.originalityScore = await this.analyzeMediaOriginality(mediaUrls);
      }

      // Calculate overall quality score
      analysis.qualityScore = this.calculateQualityScore(analysis.metrics, content, mediaUrls);
      
      // Determine approval
      analysis.isApproved = analysis.qualityScore >= 6.0 && analysis.metrics.spamScore < 0.3;
      
      // Generate reasons for rejection
      if (!analysis.isApproved) {
        analysis.reasons = this.generateRejectionReasons(analysis.metrics, analysis.qualityScore);
      }

      return analysis;
    } catch (error) {
      console.error('Content analysis error:', error);
      throw new Error('Failed to analyze content');
    }
  }

  analyzeTextQuality(content) {
    let score = 5.0;
    
    // Length check
    if (content.length < 10) score -= 2.0;
    else if (content.length > 50) score += 1.0;
    else if (content.length > 100) score += 1.5;
    
    // Grammar and structure (simplified)
    const sentences = content.split(/[.!?]+/).filter(s => s.trim().length > 0);
    if (sentences.length > 1) score += 0.5;
    
    // Capitalization check
    const words = content.split(/\s+/);
    const capitalizedWords = words.filter(word => /^[A-Z]/.test(word));
    if (capitalizedWords.length / words.length > 0.1) score += 0.3;
    
    // Check for excessive punctuation or caps
    if (/[!]{3,}|[?]{3,}|[A-Z]{5,}/.test(content)) score -= 1.0;
    
    return Math.max(0, Math.min(10, score));
  }

  analyzeSentiment(content) {
    const tokens = this.tokenizer.tokenize(content.toLowerCase());
    const stemmedTokens = tokens.map(token => natural.PorterStemmer.stem(token));
    const sentimentScore = this.sentiment.getSentiment(stemmedTokens);
    
    // Convert to 0-10 scale (sentiment ranges from -5 to 5)
    return ((sentimentScore + 5) / 10) * 10;
  }

  analyzeEducationalValue(content) {
    let score = 5.0;
    const lowerContent = content.toLowerCase();
    
    // Check for positive keywords
    this.positiveKeywords.forEach(keyword => {
      if (lowerContent.includes(keyword)) {
        score += 0.4;
      }
    });
    
    // Check for negative keywords
    this.negativeKeywords.forEach(keyword => {
      if (lowerContent.includes(keyword)) {
        score -= 0.5;
      }
    });
    
    // Check for questions (educational engagement)
    if (/\?/.test(content)) score += 0.3;
    
    // Check for numbers/statistics (often educational)
    if (/\d+%|\d+\s*(percent|million|billion|thousand)/.test(content)) score += 0.5;
    
    return Math.max(0, Math.min(10, score));
  }

  analyzeSpamContent(content) {
    let spamScore = 0;
    
    // Check spam patterns
    this.spamPatterns.forEach(pattern => {
      if (pattern.test(content)) {
        spamScore += 0.3;
      }
    });
    
    // Check for excessive emojis
    const emojiCount = (content.match(/[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]/gu) || []).length;
    if (emojiCount > content.length * 0.1) spamScore += 0.2;
    
    // Check for repeated characters
    if (/(.)\1{4,}/.test(content)) spamScore += 0.2;
    
    // Check for excessive hashtags
    const hashtagCount = (content.match(/#\w+/g) || []).length;
    if (hashtagCount > 5) spamScore += 0.1 * (hashtagCount - 5);
    
    return Math.min(1, spamScore);
  }

  async analyzeMediaOriginality(mediaUrls) {
    // Simplified originality check
    // In production, this would use image similarity detection
    let score = 8.0;
    
    // Check if multiple media files (often indicates effort)
    if (mediaUrls.length > 1) score += 0.5;
    
    // Simulate reverse image search results
    // In production, integrate with Google Vision API or similar
    const isOriginal = Math.random() > 0.3; // 70% chance of being original
    if (!isOriginal) score -= 2.0;
    
    return Math.max(0, Math.min(10, score));
  }

  calculateQualityScore(metrics, content, mediaUrls) {
    const weights = {
      textQuality: 0.25,
      sentiment: 0.15,
      educationalValue: 0.30,
      originalityScore: 0.20,
      spamPenalty: -0.10
    };
    
    let score = 0;
    score += metrics.textQuality * weights.textQuality;
    score += metrics.sentiment * weights.sentiment;
    score += metrics.educationalValue * weights.educationalValue;
    score += (metrics.originalityScore || 7.0) * weights.originalityScore;
    score += metrics.spamScore * weights.spamPenalty * 10; // Convert to penalty
    
    // Bonus for media content
    if (mediaUrls.length > 0) score += 0.5;
    
    // Bonus for longer, thoughtful content
    if (content.length > 200) score += 0.3;
    
    return Math.max(0, Math.min(10, score));
  }

  generateRejectionReasons(metrics, qualityScore) {
    const reasons = [];
    
    if (qualityScore < 4.0) {
      reasons.push('Content quality is below acceptable standards');
    }
    
    if (metrics.spamScore > 0.5) {
      reasons.push('Content appears to be spam or promotional');
    }
    
    if (metrics.textQuality < 3.0) {
      reasons.push('Text quality needs improvement');
    }
    
    if (metrics.educationalValue < 4.0) {
      reasons.push('Content lacks educational or inspirational value');
    }
    
    if (metrics.sentiment < 3.0) {
      reasons.push('Content has negative sentiment');
    }
    
    return reasons;
  }

  async moderateRealTime(content, mediaUrls, userId) {
    const analysis = await this.analyzeContent(content, mediaUrls);
    
    // Log moderation result
    console.log(`Moderation result for user ${userId}:`, {
      score: analysis.qualityScore,
      approved: analysis.isApproved,
      reasons: analysis.reasons
    });
    
    return analysis;
  }
}

module.exports = ContentAnalyzer;