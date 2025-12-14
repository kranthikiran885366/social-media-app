const express = require('express');
const mongoose = require('mongoose');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

const app = express();
app.use(express.json());

const TransactionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, enum: ['subscription', 'tip', 'promotion', 'purchase'], required: true },
  amount: { type: Number, required: true },
  currency: { type: String, default: 'USD' },
  status: { type: String, enum: ['pending', 'completed', 'failed', 'refunded'], default: 'pending' },
  paymentMethod: String,
  stripePaymentIntentId: String,
  metadata: Object,
  createdAt: { type: Date, default: Date.now }
});

const SubscriptionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  creatorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  plan: { type: String, required: true },
  amount: { type: Number, required: true },
  status: { type: String, enum: ['active', 'cancelled', 'expired'], default: 'active' },
  stripeSubscriptionId: String,
  currentPeriodStart: Date,
  currentPeriodEnd: Date,
  createdAt: { type: Date, default: Date.now }
});

const Transaction = mongoose.model('Transaction', TransactionSchema);
const Subscription = mongoose.model('Subscription', SubscriptionSchema);

class PaymentService {
  static async createSubscription(userId, creatorId, planId) {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: 999, // $9.99
      currency: 'usd',
      metadata: { userId, creatorId, type: 'subscription' }
    });

    const subscription = new Subscription({
      userId,
      creatorId,
      plan: planId,
      amount: 9.99,
      currentPeriodStart: new Date(),
      currentPeriodEnd: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    });

    await subscription.save();
    return { subscription, clientSecret: paymentIntent.client_secret };
  }

  static async processTip(fromUserId, toUserId, amount) {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100,
      currency: 'usd',
      metadata: { fromUserId, toUserId, type: 'tip' }
    });

    const transaction = new Transaction({
      userId: fromUserId,
      type: 'tip',
      amount,
      metadata: { toUserId }
    });

    await transaction.save();
    return { transaction, clientSecret: paymentIntent.client_secret };
  }

  static async getEarnings(creatorId) {
    const earnings = await Transaction.aggregate([
      { $match: { 'metadata.toUserId': mongoose.Types.ObjectId(creatorId) } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);

    return earnings[0]?.total || 0;
  }
}

app.post('/api/payments/subscription', async (req, res) => {
  try {
    const result = await PaymentService.createSubscription(req.body.userId, req.body.creatorId, req.body.planId);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/payments/tip', async (req, res) => {
  try {
    const result = await PaymentService.processTip(req.body.fromUserId, req.body.toUserId, req.body.amount);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/payments/earnings/:creatorId', async (req, res) => {
  try {
    const earnings = await PaymentService.getEarnings(req.params.creatorId);
    res.json({ earnings });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3016;
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_payments')
  .then(() => app.listen(PORT, () => console.log(`Payment service running on port ${PORT}`)));