require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const readline = require('readline');
const User = require('../models/User'); // Ensure the path is correct
const Cart = require('../models/Cart'); // Ensure the path is correct
const mongoose = require('mongoose');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.question('⚠️ Are you sure you want to delete all users and their carts? (yes/no): ', async (answer) => {
    if (answer.toLowerCase() !== 'yes') {
        console.log('❌ Operation canceled.');
        rl.close();
        mongoose.connection.close();
        return;
    }

    mongoose.connect(process.env.MONGO_URI, {}).then(async () => {
        console.log('✅ Connected to MongoDB');

        // Delete all carts
        const cartResult = await Cart.deleteMany({});
        console.log(`🗑️ Deleted ${cartResult.deletedCount} carts`);

        // Delete all users
        const userResult = await User.deleteMany({});
        console.log(`🗑️ Deleted ${userResult.deletedCount} users`);

        rl.close();
        mongoose.connection.close();
    }).catch(err => {
        console.error('❌ MongoDB Connection Failed:', err);
        rl.close();
        mongoose.connection.close();
    });
});