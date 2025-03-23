const express = require('express');
const router = express.Router();
const Category = require('../models/Category');
const { authMiddleware, isAdminMiddleware } = require('../middleware/authMiddleware');

// ✅ 1. Add a new category (only admin can perform this operation)
router.post('/', authMiddleware, isAdminMiddleware, async (req, res) => {
    try {
        const { name } = req.body;
        const existingCategory = await Category.findOne({ name });

        if (existingCategory) {
            return res.status(400).json({ message: 'Category already exists' });
        }

        const newCategory = new Category({ name });
        await newCategory.save();

        res.status(201).json({ message: 'Category created successfully', category: newCategory });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 2. Get all categories
router.get('/', async (req, res) => {
    try {
        const categories = await Category.find();
        res.json(categories);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 3. Delete a category (only admin can perform this operation)
router.delete('/:id', authMiddleware, isAdminMiddleware, async (req, res) => {
    try {
        const category = await Category.findById(req.params.id);
        if (!category) {
            return res.status(404).json({ message: 'Category not found' });
        }

        await category.deleteOne();
        res.json({ message: 'Category deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

module.exports = router;