import { Router } from 'express';
import multer from 'multer';
import { getProfile, updateProfile, uploadProfilePhoto, deletePhoto } from '../controllers/profileController';
import { authenticateToken } from '../middleware/auth';

const router = Router();
const upload = multer({ 
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files allowed'));
    }
  }
});

router.use(authenticateToken);

router.get('/', getProfile);
router.put('/', updateProfile);
router.post('/photos', upload.single('photo'), uploadProfilePhoto);
router.delete('/photos/:photoId', deletePhoto);

export default router;