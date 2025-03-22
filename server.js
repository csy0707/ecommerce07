// Import required packages
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const User = require('./models/User');
const mongoose = require('mongoose'); // Import Mongoose
const connectDB = require('./config/db'); // Import MongoDB connection function
const logger = require('./utils/logger'); // Import centralized logger.js
const morgan = require('morgan');
const { authMiddleware, logout } = require('./middleware/authMiddleware'); // Import Auth Middleware
const productRoutes = require('./routes/productRoutes');
const cartRoutes = require('./routes/cartRoutes');

// Initialize Express server
const app = express();
const PORT = process.env.PORT || 5000;

// Log HTTP requests
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));

// Middleware setup
app.use(express.json()); // Allow JSON request parsing
app.use(cors()); // Allow cross-origin requests

// Test API
app.get('/', (req, res) => {
    res.send('🎉 Express Server is running！');
});

// Start server
logger.info('🚀 Server is starting...');
app.listen(PORT, () => {
    logger.info(`🚀 Server run on http://localhost:${PORT}`);
});

// Connect to MongoDB
connectDB(); // Connect to MongoDB

const jwt = require('jsonwebtoken');

// User Registration API
app.post('/api/users/register', async (req, res) => {
    try {
        const { username, email, password } = req.body;

        // Check if user already exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            logger.warn(`User already exists: ${email}`);
            return res.status(400).json({ message: 'User already exists' });
        }

        // Create new user without password hashing
        const newUser = new User({
            username,
            email,
            password // Store plain text password
        });
        logger.info(`New user registered: ${email}`);

        // Save user to DB
        await newUser.save();
        res.status(201).json({ message: 'User registered successfully' });
    } catch (error) {
        logger.error(`Error during registration: ${error.message}`);
        res.status(500).json({ message: 'Server error', error });
    }
});

app.post('/api/users/register/admin', authMiddleware, async (req, res) => {
    try {
        const { username, email, password, role } = req.body;
        
        // Only allow admin to create another admin
        if (role === 'admin' && req.user.role !== 'admin') {
            return res.status(403).json({ message: 'Only admin can create another admin' });
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: 'User already exists' });
        }

        const newUser = new User({ username, email, password: password, role });
        await newUser.save();

        res.status(201).json({ message: 'User registered successfully', user: newUser });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

// User Login API
app.post('/api/users/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Check if user exists
        const user = await User.findOne({ email });
        if (!user) {
            logger.warn(`Login attempt failed - User not found: ${email}`);
            return res.status(400).json({ message: 'User not exists' });
        }

        // Compare passwords directly
        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            logger.warn(`Invalid password attempt for user: ${email}`);
            return res.status(400).json({ message: 'Invalid password' });
        }

        // Generate JWT token
        const token = jwt.sign({ id: user._id, role: user.role}, process.env.JWT_SECRET, { expiresIn: '1h' });

        logger.info(`User logged in: ${email}`);
        res.json({ token, user: { id: user._id, username: user.username, email: user.email } });
    } catch (error) {
        logger.error(`Error during login: ${error.message}`);
        res.status(500).json({ message: 'Server error', error });
    }
});

// User Profile API (Protected Route)
app.get('/api/users/profile', authMiddleware, async (req, res) => {
    try {
        const user = await User.findById(req.user.id).select('-password'); // remove password
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.json(user);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

// User Logout API
app.post('/api/users/logout', authMiddleware, logout);

// Product Routes
app.use('/api/products', productRoutes);

// Cart Routes
app.use('/api/cart', cartRoutes);