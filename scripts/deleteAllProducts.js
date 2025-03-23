require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const mongoose = require('mongoose');
const readline = require('readline');
const Product = require('../models/Product'); // Ensure the path is correct

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.question('Are you sure you want to delete all products? (yes/no): ', (answer) => {
    if (answer.toLowerCase() === 'yes') {
        mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
            .then(async () => {
                console.log('✅ Connected to MongoDB');

                try {
                    // Delete all products
                    const result = await Product.deleteMany({});
                    console.log(`✅ Deleted ${result.deletedCount} products`);
                } catch (error) {
                    console.error('❌ Error deleting products:', error);
                } finally {
                    mongoose.connection.close();
                    rl.close();
                }
            })
            .catch(err => {
                console.error('❌ MongoDB Connection Failed:', err);
                mongoose.connection.close();
                rl.close();
            });
    } else {
        console.log('❌ Deletion aborted');
        rl.close();
    }
});