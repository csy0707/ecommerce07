const mongoose = require('mongoose');
const logger = require('../utils/logger'); // Import logger

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI, {});
        logger.info('✅ MongoDB Connected Successfully');
    } catch (error) {
        logger.error('❌ MongoDB Connection Failed:', error);
        process.exit(1); 
    }
};

module.exports = connectDB;