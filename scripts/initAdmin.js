require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User'); // Ensure the path is correct

// Get command-line arguments
const args = process.argv.slice(2);
const email = args[0] || "admin@example.com"; // Default admin email
const password = args[1] || "admin123"; // Default admin password
const username = args[2] || "admin"; // Default admin username

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI, {}).then(async () => {
    console.log('✅ Connected to MongoDB');

    const existingAdmin = await User.findOne({ email });
    if (existingAdmin) {
        console.log('⚠️ Admin already exists:', existingAdmin);
        console.log(`Admin password: ${password}`);
        mongoose.connection.close();
        return;
    }

    const adminUser = new User({
        username: username,
        email: email,
        password: password,
        role: "admin"
    });

    await adminUser.save();
    console.log('✅ Admin user created:', adminUser);
    console.log(`Admin password: ${password}`);

    mongoose.connection.close();
}).catch(err => {
    console.error('❌ MongoDB Connection Failed:', err);
    mongoose.connection.close();
});