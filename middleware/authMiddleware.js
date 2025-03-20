const jwt = require('jsonwebtoken');

const tokenBlacklist = new Set(); // Store invalid tokens

const authMiddleware = (req, res, next) => {
    const token = req.header('Authorization');
    if (!token) {
        return res.status(401).json({ message: 'No token, authorization denied' });
    }

    const tokenWithoutBearer = token.replace('Bearer ', '');
    
    // Check if the token is in the blacklist
    if (tokenBlacklist.has(tokenWithoutBearer)) {
        return res.status(401).json({ message: 'Token has been revoked' });
    }

    try {
        const decoded = jwt.verify(tokenWithoutBearer, process.env.JWT_SECRET);
        req.user = decoded; 
        next();
    } catch (error) {
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

module.exports = { authMiddleware, logout };