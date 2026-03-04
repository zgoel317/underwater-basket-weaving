import { Router } from 'express';
import { register, login } from '../controllers/authController';
import { getProfile, updateProfile, uploadPhoto, deletePhoto } from '../controllers/profileController';
import { authenticateToken } from '../middleware/auth';
import multer from 'multer';

const router = Router();
const upload = multer({ storage: multer.memoryStorage() });

router.post('/register', register);
router.post('/login', login);

router.get('/profile', authenticateToken, getProfile);
router.put('/profile', authenticateToken, updateProfile);
router.post('/profile/photos', authenticateToken, upload.single('photo'), uploadPhoto);
router.delete('/profile/photos/:photoUrl', authenticateToken, deletePhoto);

export default router;