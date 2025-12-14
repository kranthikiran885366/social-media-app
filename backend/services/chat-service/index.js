const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

app.use(cors());
app.use(express.json());

// MongoDB Models
const MessageSchema = new mongoose.Schema({
  chatId: String,
  senderId: String,
  type: { type: String, enum: ['text', 'image', 'video', 'voice', 'gif', 'sticker'] },
  content: String,
  metadata: Object,
  replyToId: String,
  timestamp: { type: Date, default: Date.now },
  status: { type: String, enum: ['sent', 'delivered', 'read'], default: 'sent' },
  isDisappearing: { type: Boolean, default: false },
  disappearAfter: Number,
  reactions: [{ userId: String, emoji: String, timestamp: Date }],
  isForwarded: { type: Boolean, default: false },
  isEdited: { type: Boolean, default: false }
});

const ChatSchema = new mongoose.Schema({
  type: { type: String, enum: ['direct', 'group'] },
  participants: [String],
  name: String,
  avatar: String,
  lastMessage: Object,
  lastActivity: Date,
  lastSeen: Object,
  unreadCount: Object,
  isPinned: Object,
  isMuted: Object,
  isVanishMode: { type: Boolean, default: false },
  theme: String,
  createdAt: { type: Date, default: Date.now }
});

const Message = mongoose.model('Message', MessageSchema);
const Chat = mongoose.model('Chat', ChatSchema);

// Socket Authentication
io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret');
    socket.userId = decoded.userId;
    next();
  } catch (err) {
    next(new Error('Authentication error'));
  }
});

// Socket Connection
io.on('connection', (socket) => {
  console.log(`User ${socket.userId} connected`);
  
  socket.join(`user_${socket.userId}`);

  // Join chat rooms
  socket.on('join_chat', (chatId) => {
    socket.join(chatId);
    console.log(`User ${socket.userId} joined chat ${chatId}`);
  });

  // Send message
  socket.on('send_message', async (data) => {
    try {
      const message = new Message({
        chatId: data.chatId,
        senderId: socket.userId,
        type: data.type,
        content: data.content,
        metadata: data.metadata,
        replyToId: data.replyToId,
        isDisappearing: data.isDisappearing,
        disappearAfter: data.disappearAfter
      });

      await message.save();

      // Update chat
      await Chat.findByIdAndUpdate(data.chatId, {
        lastMessage: message,
        lastActivity: new Date(),
        [`unreadCount.${socket.userId}`]: 0
      });

      // Emit to chat participants
      io.to(data.chatId).emit('new_message', message);

      // Send delivery confirmation
      socket.emit('message_sent', { messageId: message._id, status: 'delivered' });

    } catch (error) {
      socket.emit('message_error', { error: error.message });
    }
  });

  // Typing indicator
  socket.on('typing_start', (data) => {
    socket.to(data.chatId).emit('user_typing', {
      userId: socket.userId,
      chatId: data.chatId
    });
  });

  socket.on('typing_stop', (data) => {
    socket.to(data.chatId).emit('user_stop_typing', {
      userId: socket.userId,
      chatId: data.chatId
    });
  });

  // Message reactions
  socket.on('add_reaction', async (data) => {
    try {
      const message = await Message.findById(data.messageId);
      if (message) {
        const existingReaction = message.reactions.find(r => r.userId === socket.userId);
        if (existingReaction) {
          existingReaction.emoji = data.emoji;
        } else {
          message.reactions.push({
            userId: socket.userId,
            emoji: data.emoji,
            timestamp: new Date()
          });
        }
        await message.save();
        io.to(message.chatId).emit('reaction_added', {
          messageId: data.messageId,
          userId: socket.userId,
          emoji: data.emoji
        });
      }
    } catch (error) {
      socket.emit('reaction_error', { error: error.message });
    }
  });

  // Mark messages as read
  socket.on('mark_read', async (data) => {
    try {
      await Message.updateMany(
        { chatId: data.chatId, senderId: { $ne: socket.userId } },
        { status: 'read' }
      );

      await Chat.findByIdAndUpdate(data.chatId, {
        [`unreadCount.${socket.userId}`]: 0,
        [`lastSeen.${socket.userId}`]: new Date()
      });

      socket.to(data.chatId).emit('messages_read', {
        chatId: data.chatId,
        userId: socket.userId
      });
    } catch (error) {
      console.error('Mark read error:', error);
    }
  });

  // Voice/Video calls
  socket.on('start_call', (data) => {
    socket.to(data.chatId).emit('incoming_call', {
      callId: data.callId,
      callerId: socket.userId,
      isVideo: data.isVideo,
      chatId: data.chatId
    });
  });

  socket.on('answer_call', (data) => {
    socket.to(data.chatId).emit('call_answered', {
      callId: data.callId,
      answeredBy: socket.userId
    });
  });

  socket.on('end_call', (data) => {
    socket.to(data.chatId).emit('call_ended', {
      callId: data.callId,
      endedBy: socket.userId
    });
  });

  // Disconnect
  socket.on('disconnect', () => {
    console.log(`User ${socket.userId} disconnected`);
  });
});

// REST API Routes
app.get('/api/chats', async (req, res) => {
  try {
    const userId = req.headers.userid;
    const chats = await Chat.find({
      participants: userId
    }).sort({ lastActivity: -1 });
    res.json(chats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/chats/:chatId/messages', async (req, res) => {
  try {
    const { chatId } = req.params;
    const { page = 1, limit = 50 } = req.query;
    
    const messages = await Message.find({ chatId })
      .sort({ timestamp: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    res.json(messages.reverse());
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/chats', async (req, res) => {
  try {
    const { participants, type, name } = req.body;
    
    const chat = new Chat({
      type,
      participants,
      name,
      unreadCount: {},
      lastSeen: {},
      isPinned: {},
      isMuted: {}
    });
    
    await chat.save();
    res.json(chat);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/messages/:messageId', async (req, res) => {
  try {
    const { messageId } = req.params;
    const userId = req.headers.userid;
    
    const message = await Message.findById(messageId);
    if (message && message.senderId === userId) {
      await Message.findByIdAndDelete(messageId);
      
      io.to(message.chatId).emit('message_deleted', {
        messageId,
        chatId: message.chatId
      });
      
      res.json({ success: true });
    } else {
      res.status(403).json({ error: 'Unauthorized' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/messages/:messageId', async (req, res) => {
  try {
    const { messageId } = req.params;
    const { content } = req.body;
    const userId = req.headers.userid;
    
    const message = await Message.findById(messageId);
    if (message && message.senderId === userId) {
      message.content = content;
      message.isEdited = true;
      await message.save();
      
      io.to(message.chatId).emit('message_edited', {
        messageId,
        content,
        chatId: message.chatId
      });
      
      res.json(message);
    } else {
      res.status(403).json({ error: 'Unauthorized' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3010;

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/smart_social_chat')
  .then(() => {
    server.listen(PORT, () => {
      console.log(`Chat service running on port ${PORT}`);
    });
  })
  .catch(err => console.error('MongoDB connection error:', err));