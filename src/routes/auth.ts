import express from 'express';
import multer from 'multer';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';
import { register, login, getProfile, updateProfile } from '../controllers/authController';
import { authenticateToken } from '../middleware/auth';
import { validateRegistration, validateLogin, validateProfile, handleValidationErrors } from '../middleware/validation';
import { User } from '../models/User';

const router = express.Router();

const storage = multer.diskStorage({
  destination: 'uploads/photos/',
  filename: (req, file, cb) => {
    const uniqueName = `${uuidv4()}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    }
    cb(new Error('Only image files are allowed'));
  }
});

router.post('/register', validateRegistration, handleValidationErrors, register);
router.post('/login', validateLogin, handleValidationErrors, login);
router.get('/profile', authenticateToken, getProfile);
router.put('/profile', authenticateToken, validateProfile, handleValidationErrors, updateProfile);

router.post('/profile/photos', authenticateToken, upload.array('photos', 10), async (req: any, res) => {
  try {
    const files = req.files as Express.Multer.File[];
    if (!files || files.length === 0) {
      return res.status(400).json({ error: 'No photos uploaded' });
    }

    const photoUrls = files.map(file => `/uploads/photos/${file.filename}`);
    
    const user = await User.findByIdAndUpdate(
      req.userId,
      { $push: { photos: { $each: photoUrls } } },
      { new: true }
    ).select('-password');

    res.json({ photos: photoUrls, user });
  } catch (error) {
    res.status(500).json({ error: 'Failed to upload photos' });
  }
});

router.delete('/profile/photos/:photoIndex', authenticateToken, async (req: any, res) => {
  try {
    const photoIndex = parseInt(req.params.photoIndex);
    const user = await User.findById(req.userId);
    
    if (!user || photoIndex < 0 || photoIndex >= user.photos.length) {
      return res.status(400).json({ error: 'Invalid photo index' });
    }

    user.photos.splice(photoIndex, 1);
    await user.save();
    
    res.json({ message: 'Photo deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete photo' });
  }
});

export default router;