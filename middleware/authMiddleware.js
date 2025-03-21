const jwt = require('jsonwebtoken');
const User = require('../models/User');
const logger = require('../utils/logger'); // Assuming you have a logger utility

const tokenBlacklist = new Set(); // Store invalid tokens

// Middleware to authenticate the user
const authMiddleware = async (req, res, next) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    if (!token) {
        return res.status(401).json({ message: 'No token provided' });
    }

    if (tokenBlacklist.has(token)) {
        return res.status(401).json({ message: 'Token is blacklisted' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.id);
        if (!user) {
            return res.status(401).json({ message: 'User not found' });
        }

        req.user = user;
        logger.debug(`Authenticated user: ${user.email}`);
        next();
    } catch (error) {
        logger.error(`Authentication error: ${error.message}`);
        res.status(401).json({ message: 'Invalid token' });
    }
};

// Logout API: Add token to blacklist
const logout = (req, res) => {
    const token = req.header('Authorization');
    if (!token) {
        return res.status(400).json({ message: 'No token provided' });
    }

    const tokenWithoutBearer = token.replace('Bearer ', '');
    tokenBlacklist.add(tokenWithoutBearer);
    
    res.json({ message: 'Logged out successfully' });
};

// Middleware to check if the user is an admin
const isAdminMiddleware = (req, res, next) => {
    if (req.user && req.user.role === 'admin') {
        logger.debug(`Admin access granted for user: ${req.user.email}`);
        next();
    } else {
        logger.warn(`Admin access denied for user: ${req.user ? req.user.email : 'unknown'}`);
        res.status(403).json({ message: 'Access denied: Admins only' });
    }
};

module.exports = { authMiddleware, logout, isAdminMiddleware };