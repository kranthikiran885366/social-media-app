require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const contentRoutes = require('./routes/contentRoutes');

const app = express();
const PORT = process.env.PORT || 3003;

app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '50mb' }));

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_content');

app.use('/api/content', contentRoutes);

app.listen(PORT, () => {
  console.log(`Content Service running on port ${PORT}`);
});

module.exports = app;