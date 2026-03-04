import { Request, Response } from 'express';
import { User } from '../models/User';
import { validateProfileUpdate } from '../utils/validation';
import { uploadPhoto } from '../services/photoService';

export const getProfile = async (req: Request, res: Response) => {
  try {
    const user = await User.findById(req.user.userId).select('-password');
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json({ user });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
};

export const updateProfile = async (req: Request, res: Response) => {
  try {
    const { error } = validateProfileUpdate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const user = await User.findByIdAndUpdate(
      req.user.userId,
      { $set: { profile: req.body } },
      { new: true, runValidators: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ 
      message: 'Profile updated successfully',
      user 
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
};

export const uploadProfilePhoto = async (req: Request, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No photo uploaded' });
    }

    const { isUnderwater = false, isPrimary = false } = req.body;
    const photoUrl = await uploadPhoto(req.file);

    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (isPrimary) {
      user.profile.photos.forEach(photo => {
        photo.isPrimary = false;
      });
    }

    user.profile.photos.push({
      url: photoUrl,
      isUnderwater: Boolean(isUnderwater),
      isPrimary: Boolean(isPrimary),
      uploadedAt: new Date()
    });

    await user.save();

    res.json({ 
      message: 'Photo uploaded successfully',
      photo: user.profile.photos[user.profile.photos.length - 1]
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
};

export const deletePhoto = async (req: Request, res: Response) => {
  try {
    const { photoId } = req.params;
    
    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    user.profile.photos = user.profile.photos.filter(
      photo => photo._id?.toString() !== photoId
    );

    await user.save();

    res.json({ message: 'Photo deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
};