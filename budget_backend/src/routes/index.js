const { Router } = require('express');

const router = Router();

router.get('/health', (req, res) => res.json({ success: true, message: 'Server is running', data: null }));
router.use('/auth', require('./auth'));
router.use('/users', require('./users'));
router.use('/categories', require('./categories'));
router.use('/transactions', require('./transactions'));
router.use('/goals', require('./goals'));
router.use('/smart-add', require('./smartAdd'));

module.exports = router;
