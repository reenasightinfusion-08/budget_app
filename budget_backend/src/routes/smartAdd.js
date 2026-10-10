const { Router } = require('express');
const multer = require('multer');
const smartAdd = require('../controllers/smartAddController');
const requireAuth = require('../middleware/requireAuth');

// A photo or PDF can be attached as a normal `file` form field. Vercel rejects bodies over 4.5 MB.
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 4 * 1024 * 1024, files: 1 } });

const router = Router();

router.use(requireAuth);
router.post('/', upload.single('file'), smartAdd.smartAdd);

module.exports = router;
