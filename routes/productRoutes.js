const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Product = require('../models/Product');
const Category = require('../models/Category');
const { authMiddleware, isAdminMiddleware } = require('../middleware/authMiddleware'); // Ensure user authentication

// ✅ 1. Create a new product (Admin only)
router.post('/', authMiddleware, isAdminMiddleware, async (req, res) => {
    try {
        let { name, description, price, stock, category, image } = req.body;

        // If category is a name, convert it to ID
        if (!mongoose.Types.ObjectId.isValid(category)) {
            const categoryDoc = await Category.findOne({ name: new RegExp(`^${category}$`, 'i') });
            if (!categoryDoc) {
                return res.status(400).json({ message: 'Invalid category name' });
            }
            category = categoryDoc._id; // Convert to ObjectId
        }

        const newProduct = new Product({ name, description, price, stock, category, image });
        await newProduct.save();

        res.status(201).json({ message: 'Product created successfully', product: newProduct });
    } catch (error) {
        console.error('Error creating product:', error); // Log the error
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 2. Get all products
router.get('/', async (req, res) => {
    try {
        const products = await Product.find();
        res.json(products);
    } catch (error) {
        console.error('Error fetching products:', error); // Log the error
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 3. Get products by category filter
router.get('/filter', async (req, res) => {
    try {
        const { category } = req.query;
        let filter = {};
        
        if (category) {
            const categories = category.split(',').map(c => new RegExp(`^${c.trim()}$`, 'i'));
            const categoryDocs = await Category.find({ name: { $in: categories } });

            if (categoryDocs.length === 0) {
                return res.status(404).json({ message: 'Category not found' });
            }

            filter.category = { $in: categoryDocs.map(cat => cat._id) };
        }

        const products = await Product.find(filter).populate('category');
        res.json(products);
    } catch (error) {
        console.error('Error fetching products by category:', error); // Log the error
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 4. Get a single product by ID
router.get('/:id', async (req, res) => {
    try {
        const product = await Product.findById(req.params.id);
        if (!product) {
            return res.status(404).json({ message: 'Product not found' });
        }
        res.json(product);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 5. Update a product (Admin only)
router.put('/:id', authMiddleware, isAdminMiddleware, async (req, res) => {
    try {
        const updatedProduct = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedProduct) {
            return res.status(404).json({ message: 'Product not found' });
        }
        res.json({ message: 'Product updated successfully', product: updatedProduct });
    } catch (error) {
        console.error('Error updating product:', error); // Log the error
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 6. Delete a product (Admin only)
router.delete('/:id', authMiddleware, isAdminMiddleware, async (req, res) => {
    try {
        const deletedProduct = await Product.findByIdAndDelete(req.params.id);
        if (!deletedProduct) {
            return res.status(404).json({ message: 'Product not found' });
        }
        res.json({ message: 'Product deleted successfully' });
    } catch (error) {
        console.error('Error deleting product:', error); // Log the error
        res.status(500).json({ message: 'Server error', error });
    }
});

module.exports = router;