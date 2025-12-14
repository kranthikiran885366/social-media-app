const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const mongoose = require('mongoose');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: { origin: "*", methods: ["GET", "POST"] }
});

app.use(cors());
app.use(express.json());

// MongoDB Schemas
const LiveStreamSchema = new mongoose.Schema({
  hostId: String,
  title: String,
  status: { type: String, enum: ['waiting', 'live', 'ended'], default: 'waiting' },
  startTime: { type: Date, default: Date.now },
  endTime: Date,
  viewerCount: { type: Number, default: 0 },
  likeCount: { type: Number, default: 0 },
  guests: [String],
  settings: {
    commentsEnabled: { type: Boolean, default: true },
    guestsEnabled: { type: Boolean, default: true },
    shoppingEnabled: { type: Boolean, default: false }
  }
});

const LiveCommentSchema = new mongoose.Schema({
  streamId: String,
  userId: String,
  username: String,
  content: String,
  timestamp: { type: Date, default: Date.now },
  isPinned: { type: Boolean, default: false }
});

const LiveStream = mongoose.model('LiveStream', LiveStreamSchema);
const LiveComment = mongoose.model('LiveComment', LiveCommentSchema);

const activeStreams = new Map();

io.on('connection', (socket) => {
  // Start live stream
  socket.on('start_live', async (data) => {
    try {
      const stream = new LiveStream({
        hostId: data.hostId,
        title: data.title,
        settings: data.settings
      });
      await stream.save();

      stream.status = 'live';
      await stream.save();

      activeStreams.set(stream._id.toString(), {
        hostSocket: socket.id,
        viewers: new Set()
      });

      socket.join(`stream_${stream._id}`);
      socket.emit('live_started', { streamId: stream._id });

    } catch (error) {
      socket.emit('live_error', { error: error.message });
    }
  });

  // Join live stream
  socket.on('join_live', async (data) => {
    try {
      const stream = await LiveStream.findById(data.streamId);
      
      if (stream && stream.status === 'live') {
        socket.join(`stream_${data.streamId}`);
        
        const streamData = activeStreams.get(data.streamId);
        if (streamData) {
          streamData.viewers.add(socket.id);
          stream.viewerCount = streamData.viewers.size;
          await stream.save();
          
          io.to(`stream_${data.streamId}`).emit('viewer_joined', {
            viewerCount: stream.viewerCount
          });
        }
        
        socket.emit('joined_live', { stream });
      }
    } catch (error) {
      socket.emit('live_error', { error: error.message });
    }
  });

  // Send live comment
  socket.on('live_comment', async (data) => {
    try {
      const comment = new LiveComment({
        streamId: data.streamId,
        userId: data.userId,
        username: data.username,
        content: data.content
      });
      await comment.save();

      io.to(`stream_${data.streamId}`).emit('new_comment', comment);
    } catch (error) {
      socket.emit('comment_error', { error: error.message });
    }
  });

  // Send live like
  socket.on('live_like', async (data) => {
    try {
      const stream = await LiveStream.findById(data.streamId);
      if (stream) {
        stream.likeCount += 1;
        await stream.save();
        
        io.to(`stream_${data.streamId}`).emit('new_like', {
          likeCount: stream.likeCount
        });
      }
    } catch (error) {
      socket.emit('like_error', { error: error.message });
    }
  });

  // End live stream
  socket.on('end_live', async (data) => {
    try {
      const stream = await LiveStream.findById(data.streamId);
      if (stream) {
        stream.status = 'ended';
        stream.endTime = new Date();
        await stream.save();
        
        io.to(`stream_${data.streamId}`).emit('live_ended', {
          streamId: data.streamId
        });
        
        activeStreams.delete(data.streamId);
      }
    } catch (error) {
      socket.emit('end_error', { error: error.message });
    }
  });
});

// REST API Routes
app.get('/api/live/active', async (req, res) => {
  try {
    const streams = await LiveStream.find({ status: 'live' });
    res.json(streams);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/live/:streamId/comments', async (req, res) => {
  try {
    const comments = await LiveComment.find({ streamId: req.params.streamId })
      .sort({ timestamp: -1 })
      .limit(100);
    res.json(comments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3011;

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_live')
  .then(() => {
    server.listen(PORT, () => {
      console.log(`Live service running on port ${PORT}`);
    });
  })
  .catch(err => console.error('MongoDB connection error:', err));