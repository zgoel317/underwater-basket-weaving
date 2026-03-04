import { Request, Response } from 'express';
import { User } from '../models/User';
import { validationResult } from 'express-validator';
import { AuthRequest } from '../middleware/auth';

export const getProfile = async (req: AuthRequest, res: Response) => {
  try {
    const user = await User.findById(req.userId).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ profile: user.profile });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

export const updateProfile = async (req: AuthRequest, res: Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const profileUpdates = req.body;
    user.profile = { ...user.profile, ...profileUpdates };
    await user.save();

    res.json({
      message: 'Profile updated successfully',
      profile: user.profile
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

export const uploadPhoto = async (req: AuthRequest, res: Response) => {
  try {
    const { photoType } = req.body;
    const photoUrl = req.file?.path;

    if (!photoUrl) {
      return res.status(400).json({ message: 'No photo uploaded' });
    }

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (photoType === 'profile') {
      user.profile.profilePhotos.push(photoUrl);
    } else if (photoType === 'basket') {
      user.profile.basketPhotos.push(photoUrl);
    } else {
      return res.status(400).json({ message: 'Invalid photo type' });
    }

    await user.save();

    res.json({
      message: 'Photo uploaded successfully',
      photoUrl,
      photos: photoType === 'profile' ? user.profile.profilePhotos : user.profile.basketPhotos
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};

export const deletePhoto = async (req: AuthRequest, res: Response) => {
  try {
    const { photoUrl, photoType } = req.body;

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (photoType === 'profile') {
      user.profile.profilePhotos = user.profile.profilePhotos.filter(photo => photo !== photoUrl);
    } else if (photoType === 'basket') {
      user.profile.basketPhotos = user.profile.basketPhotos.filter(photo => photo !== photoUrl);
    } else {
      return res.status(400).json({ message: 'Invalid photo type' });
    }

    await user.save();

    res.json({ message: 'Photo deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
};