const { Router } = require('express');
const auth = require('../controllers/authController');
const requireAuth = require('../middleware/requireAuth');

const router = Router();

router.post('/signup', auth.signup);
router.post('/verify-email', auth.verifyEmail);
router.post('/resend-code', auth.resendCode);
router.post('/login', auth.login);
router.post('/forgot-password', auth.forgotPassword);
router.post('/verify-reset-code', auth.verifyResetCode);
router.post('/reset-password', auth.resetPassword);
router.post('/change-password', requireAuth, auth.changePassword);

module.exports = router;
