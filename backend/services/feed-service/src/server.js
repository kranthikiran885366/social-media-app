require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const feedRoutes = require('./routes/feedRoutes');

const app = express();
const PORT = process.env.PORT || 3004;

app.use(helmet());
app.use(cors());
app.use(express.json());

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_feed');

app.use('/api/feed', feedRoutes);

app.listen(PORT, () => {
  console.log(`Feed Service running on port ${PORT}`);
});

module.exports = app;