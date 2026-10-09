const { Router } = require('express');
const users = require('../controllers/userController');
const requireAuth = require('../middleware/requireAuth');

const router = Router();

router.use(requireAuth);
router.get('/me', users.getMe);
router.patch('/me', users.updateMe);
router.delete('/me', users.deleteMe);

module.exports = router;
