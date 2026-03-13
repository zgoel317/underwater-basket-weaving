import { Request, Response } from 'express';
import multer from 'multer';
import imageService from '../services/imageService';
import { authenticateToken } from '../middleware/auth';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG, PNG, and WebP allowed.'));
    }
  }
});

class ImageController {
  uploadProfilePhoto = [authenticateToken, upload.single('image'), async (req: Request, res: Response) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: 'No image file provided' });
      }

      const userId = req.user.id;
      const result = await imageService.uploadAndProcess(req.file.buffer, userId, 'profile');
      
      res.json({
        success: true,
        image: result
      });
    } catch (error) {
      res.status(500).json({ error: 'Failed to upload image' });
    }
  }];

  uploadBasketPhoto = [authenticateToken, upload.single('image'), async (req: Request, res: Response) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: 'No image file provided' });
      }

      const userId = req.user.id;
      const result = await imageService.uploadAndProcess(req.file.buffer, userId, 'basket');
      
      res.json({
        success: true,
        image: result
      });
    } catch (error) {
      res.status(500).json({ error: 'Failed to upload basket image' });
    }
  }];

  uploadUnderwaterPhoto = [authenticateToken, upload.single('image'), async (req: Request, res: Response) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: 'No image file provided' });
      }

      const userId = req.user.id;
      const depth = req.body.depth ? parseInt(req.body.depth) : undefined;
      
      const result = await imageService.uploadUnderwaterPhoto(req.file.buffer, userId, depth);
      
      res.json({
        success: true,
        image: result
      });
    } catch (error) {
      res.status(500).json({ error: 'Failed to upload underwater image' });
    }
  }];

  deleteImage = [authenticateToken, async (req: Request, res: Response) => {
    try {
      const { imageId, type } = req.params;
      const userId = req.user.id;
      
      if (!['profile', 'basket', 'dive'].includes(type)) {
        return res.status(400).json({ error: 'Invalid image type' });
      }
      
      await imageService.deleteImage(imageId, userId, type as 'profile' | 'basket' | 'dive');
      
      res.json({ success: true });
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete image' });
    }
  }];

  getImageUrl = async (req: Request, res: Response) => {
    try {
      const { userId, imageId, type, size } = req.params;
      
      if (!['profile', 'basket', 'dive'].includes(type)) {
        return res.status(400).json({ error: 'Invalid image type' });
      }
      
      const url = imageService.getImageUrl(
        imageId, 
        userId, 
        type as 'profile' | 'basket' | 'dive',
        size as 'thumb' | 'medium' | 'large' | 'original'
      );
      
      res.json({ url });
    } catch (error) {
      res.status(500).json({ error: 'Failed to get image URL' });
    }
  };
}

export default new ImageController();