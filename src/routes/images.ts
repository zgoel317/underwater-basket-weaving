import express from 'express';
import imageController from '../controllers/imageController';

const router = express.Router();

router.post('/profile', imageController.uploadProfilePhoto);
router.post('/basket', imageController.uploadBasketPhoto);
router.post('/underwater', imageController.uploadUnderwaterPhoto);
router.delete('/:type/:imageId', imageController.deleteImage);
router.get('/:userId/:type/:imageId/:size?', imageController.getImageUrl);

export default router;