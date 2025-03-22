const express = require('express');
const router = express.Router();
const Cart = require('../models/Cart');
const Product = require('../models/Product');
const { authMiddleware } = require('../middleware/authMiddleware');

// ✅ 1. Add product to cart
router.post('/', authMiddleware, async (req, res) => {
    try {
        const { productId, quantity } = req.body;
        const userId = req.user.id;

        let cart = await Cart.findOne({ user: userId });
        if (!cart) {
            cart = new Cart({ user: userId, items: [] });
        }

        const productExists = cart.items.find(item => item.product.toString() === productId);
        if (productExists) {
            productExists.quantity += quantity;
        } else {
            cart.items.push({ product: productId, quantity });
        }

        await cart.save();
        res.json({ message: 'Product added to cart', cart });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 2. View cart contents
router.get('/', authMiddleware, async (req, res) => {
    try {
        const cart = await Cart.findOne({ user: req.user.id }).populate('items.product');
        if (!cart) {
            return res.json({ message: 'Cart is empty', items: [] });
        }
        res.json(cart);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 3. Update product quantity in cart
router.put('/:productId', authMiddleware, async (req, res) => {
    try {
        const { quantity } = req.body;
        const userId = req.user.id;
        const { productId } = req.params;

        const cart = await Cart.findOne({ user: userId });
        if (!cart) {
            return res.status(404).json({ message: 'Cart not found' });
        }

        const item = cart.items.find(item => item.product.toString() === productId);
        if (!item) {
            return res.status(404).json({ message: 'Product not in cart' });
        }

        item.quantity = quantity;
        await cart.save();
        res.json({ message: 'Cart updated', cart });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

// ✅ 4. Remove product from cart
router.delete('/:productId', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.id;
        const { productId } = req.params;

        let cart = await Cart.findOne({ user: userId });
        if (!cart) {
            return res.status(404).json({ message: 'Cart not found' });
        }

        cart.items = cart.items.filter(item => item.product.toString() !== productId);
        await cart.save();
        res.json({ message: 'Product removed from cart', cart });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
});

module.exports = router;