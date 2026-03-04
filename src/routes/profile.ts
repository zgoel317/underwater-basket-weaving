import { Router } from 'express';
import { body } from 'express-validator';
import multer from 'multer';
import { auth } from '../middleware/auth';
import { getProfile, updateProfile, uploadProfilePhoto, uploadPhotos } from '../controllers/profileController';

// TODO: Configure proper file storage (AWS S3, Cloudinary, etc.)
const storage = multer.diskStorage({
  destination: 'uploads/',
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});

const upload = multer({ 
  storage,
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files allowed'));
    }
  },
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

const router = Router();

router.get('/me', auth, getProfile);

router.put('/me', auth, [
  body('firstName').optional().trim().isLength({ min: 1 }),
  body('lastName').optional().trim().isLength({ min: 1 }),
  body('experienceLevel').optional().isIn(['Beginner', 'Intermediate', 'Advanced', 'Master Weaver']),
  body('bio').optional().isLength({ max: 500 }),
  body('travelRadius').optional().isNumeric({ min: 1, max: 1000 }),
  body('location.coordinates').optional().isArray({ min: 2, max: 2 }),
  body('location.coordinates.*').optional().isNumeric(),
  body('divingCertifications').optional().isArray(),
  body('preferredDepths.min').optional().isNumeric({ min: 0 }),
  body('preferredDepths.max').optional().isNumeric({ min: 1 }),
  body('weavingSpecialties').optional().isArray()
], updateProfile);

router.post('/me/photo', auth, upload.single('photo'), uploadProfilePhoto);

router.post('/me/photos', auth, upload.array('photos', 10), uploadPhotos);

export default router;