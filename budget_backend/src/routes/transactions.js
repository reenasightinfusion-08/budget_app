const { Router } = require('express');
const transactions = require('../controllers/transactionController');
const requireAuth = require('../middleware/requireAuth');

const router = Router();

router.use(requireAuth);
router.get('/summary', transactions.summary);
router.get('/', transactions.list);
router.post('/', transactions.create);
router.post('/bulk', transactions.bulk);
router.delete('/:id', transactions.remove);

module.exports = router;
