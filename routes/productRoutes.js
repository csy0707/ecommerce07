const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const { authMiddleware, isAdminMiddleware } = require('../middleware/authMiddleware'); // Ensure user authentication

// ✅ 1. Create a new product (Admin only)
router.post('/', authMiddleware, isAdminMiddleware, async (req, res) => {
    try {
        const { name, description, price, stock, category, image } = req.body;

        const newProduct = new Product({ name, description, price, stock, category, image });
        await newProduct.save();

        res.status(201).json({ message: 'Product created successfully', product: newProduct });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 2. Get all products
router.get('/', async (req, res) => {
    try {
        const products = await Product.find();
        res.json(products);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 3. Get a single product by ID
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

// ✅ 4. Update a product (Admin only)
router.put('/:id', authMiddleware, isAdminMiddleware, async (req, res) => {
    try {
        const updatedProduct = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedProduct) {
            return res.status(404).json({ message: 'Product not found' });
        }
        res.json({ message: 'Product updated successfully', product: updatedProduct });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 5. Delete a product (Admin only)
router.delete('/:id', authMiddleware, isAdminMiddleware, async (req, res) => {
    try {
        const deletedProduct = await Product.findByIdAndDelete(req.params.id);
        if (!deletedProduct) {
            return res.status(404).json({ message: 'Product not found' });
        }
        res.json({ message: 'Product deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

module.exports = router;