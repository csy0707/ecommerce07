require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const readline = require('readline');
const User = require('../models/User'); // Ensure the path is correct
const mongoose = require('mongoose');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.question('⚠️ Are you sure you want to delete all users? (yes/no): ', async (answer) => {
    if (answer.toLowerCase() !== 'yes') {
        console.log('❌ Operation canceled.');
        rl.close();
        mongoose.connection.close();
        return;
    }

    mongoose.connect(process.env.MONGO_URI, {}).then(async () => {
        console.log('✅ Connected to MongoDB');

        // Delete all users
        const result = await User.deleteMany({});
        console.log(`🗑️ Deleted ${result.deletedCount} users`);

        rl.close();
        mongoose.connection.close();
    }).catch(err => {
        console.error('❌ MongoDB Connection Failed:', err);
        rl.close();
        mongoose.connection.close();
    });
});