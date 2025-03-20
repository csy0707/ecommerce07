const winston = require('winston');

const logger = winston.createLogger({
    level: process.env.LOG_LEVEL || 'debug', // Log level can be set through environment variable
    format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.printf(({ timestamp, level, message }) => {
            return `[${timestamp}] ${level.toUpperCase()}: ${message}`;
        })
    ),
    transports: [
        new winston.transports.Console(), // Display in console
        new winston.transports.File({ filename: 'server.log' }) // Save to file
    ]
});

module.exports = logger;