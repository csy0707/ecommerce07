const mongoose = require('mongoose');
const bcrypt = require('bcryptjs'); // Added bcrypt
const logger = require('../utils/logger'); // Import logger

// Define User Schema
const UserSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true, trim: true }, // Modified username field
    email: { 
        type: String, 
        required: true, 
        unique: true, 
        trim: true,
        match: [/^\S+@\S+\.\S+$/, 'Invalid email format'] // Modified email field
    },
    password: { 
        type: String, 
        required: true, 
        minlength: [8, 'Password must be at least 8 characters long'], // Minimum password length requirement
    },
    role: { type: String, enum: ['user', 'admin'], default: 'user' } // Added role field
}, { timestamps: true }); // Automatically adds createdAt & updatedAt fields

// Hash password before saving
UserSchema.pre('save', async function(next) { // Added pre middleware
    if (!this.isModified('password')) return next();
    try {
        logger.debug(`Hashing password for: ${this.email}`);
        this.password = await bcrypt.hash(this.password, 10);
        next();
    } catch (err) {
        next(err);  // Pass error to the next middleware
    }
});

// Compare passwords
UserSchema.methods.comparePassword = async function(enteredPassword) {
    try {
        const isMatch = await bcrypt.compare(enteredPassword, this.password);
        logger.debug(`Password comparison result for ${this.email}: ${isMatch}`);
        return isMatch;
    } catch (err) {
        logger.error(`Error during password comparison for ${this.email}: ${err.message}`);
        return false;
    }
};

// Static method to delete all users
UserSchema.statics.deleteAllUsers = async function() {
    try {
        const result = await this.deleteMany({});
        logger.info(`All users deleted. Count: ${result.deletedCount}`);
        return result;
    } catch (err) {
        logger.error(`Error deleting all users: ${err.message}`);
        throw err;
    }
};

// Create User Model
const User = mongoose.model('User', UserSchema);

module.exports = User;