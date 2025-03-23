require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const mongoose = require('mongoose');
const Category = require('../models/Category'); // Ensure the path is correct

mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(async () => {
        console.log('✅ Connected to MongoDB');

        try {
            // Check if the category "None" already exists
            const existingCategory = await Category.findOne({ name: 'None' });
            if (existingCategory) {
                console.log('✅ Category "None" already exists');
            } else {
                // Create the category "None"
                const newCategory = new Category({ name: 'None' });
                await newCategory.save();
                console.log('✅ Category "None" created successfully');
            }
        } catch (error) {
            console.error('❌ Error initializing category:', error);
        } finally {
            mongoose.connection.close();
        }
    })
    .catch(err => {
        console.error('❌ MongoDB Connection Failed:', err);
        mongoose.connection.close();
    });