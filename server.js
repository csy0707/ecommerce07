// Import required packages
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const User = require('./models/User');
const mongoose = require('mongoose'); // Import Mongoose
const connectDB = require('./config/db'); // Import MongoDB connection function
const logger = require('./utils/logger'); // Import centralized logger.js
const morgan = require('morgan');

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
        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });

        logger.info(`User logged in: ${email}`);
        res.json({ token, user: { id: user._id, username: user.username, email: user.email } });
    } catch (error) {
        logger.error(`Error during login: ${error.message}`);
        res.status(500).json({ message: 'Server error', error });
    }
});