const { Router } = require('express');
const goals = require('../controllers/goalController');
const requireAuth = require('../middleware/requireAuth');

const router = Router();

router.use(requireAuth);
router.get('/', goals.list);
router.post('/', goals.create);
router.post('/:id/contributions', goals.addContribution);
router.delete('/:id', goals.remove);

module.exports = router;
