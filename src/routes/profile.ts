import express from 'express';
import multer from 'multer';
import { body } from 'express-validator';
import { auth } from '../middleware/auth';
import { getProfile, updateProfile, uploadPhoto, deletePhoto } from '../controllers/profileController';

const router = express.Router();

// TODO: Configure cloud storage (AWS S3, Cloudinary, etc.)
const upload = multer({ dest: 'uploads/' });

router.get('/', auth, getProfile);

router.put('/', auth, [
  body('firstName').optional().trim().isLength({ min: 1 }),
  body('lastName').optional().trim().isLength({ min: 1 }),
  body('experienceLevel').optional().isIn(['Beginner', 'Intermediate', 'Advanced', 'Master Weaver']),
  body('bio').optional().isLength({ max: 500 }),
  body('age').optional().isInt({ min: 18, max: 100 }),
  body('travelRadius').optional().isInt({ min: 1, max: 1000 }),
  body('preferredDepths.min').optional().isInt({ min: 0 }),
  body('preferredDepths.max').optional().isInt({ min: 0 })
], updateProfile);

router.post('/photos', auth, upload.single('photo'), uploadPhoto);

router.delete('/photos', auth, deletePhoto);

export default router;