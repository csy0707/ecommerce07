require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const readline = require('readline');
const User = require('../models/User'); // Ensure the path is correct
const Cart = require('../models/Cart'); // Ensure the path is correct
const mongoose = require('mongoose');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.question('Enter the email of the user you want to delete: ', async (email) => {
    if (!email) {
        console.log('❌ No email provided. Operation canceled.');
        rl.close();
        mongoose.connection.close();
        return;
    }

    mongoose.connect(process.env.MONGO_URI, {}).then(async () => {
        console.log('✅ Connected to MongoDB');

        // Find the user by email
        const user = await User.findOne({ email });
        if (!user) {
            console.log('❌ User not found.');
            rl.close();
            mongoose.connection.close();
            return;
        }

        // Delete the user's cart
        const cartResult = await Cart.deleteOne({ user: user._id });
        console.log(`🗑️ Deleted ${cartResult.deletedCount} cart(s) for user ${email}`);

        // Delete the user
        const userResult = await User.deleteOne({ _id: user._id });
        console.log(`🗑️ Deleted ${userResult.deletedCount} user(s) with email ${email}`);

        rl.close();
        mongoose.connection.close();
    }).catch(err => {
        console.error('❌ MongoDB Connection Failed:', err);
        rl.close();
        mongoose.connection.close();
    });
});