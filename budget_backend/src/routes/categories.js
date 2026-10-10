const { Router } = require('express');
const categories = require('../controllers/categoryController');
const requireAuth = require('../middleware/requireAuth');

const router = Router();

router.use(requireAuth);
router.get('/', categories.list);

module.exports = router;
