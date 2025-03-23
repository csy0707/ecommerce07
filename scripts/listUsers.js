require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const mongoose = require('mongoose');
const User = require('../models/User'); // Ensure the path is correct

mongoose.connect(process.env.MONGO_URI, {}).then(async () => {
    console.log('✅ Connected to MongoDB');

    try {
        // Fetch all users
        const users = await User.find({});
        if (users.length === 0) {
            console.log('No users found.');
        } else {
            console.log('List of users:');
            users.forEach(user => {
                console.log(`- ${user.email} (ID: ${user._id})`);
            });
        }
    } catch (error) {
        console.error('❌ Error fetching users:', error);
    } finally {
        mongoose.connection.close();
    }
}).catch(err => {
    console.error('❌ MongoDB Connection Failed:', err);
    mongoose.connection.close();
});