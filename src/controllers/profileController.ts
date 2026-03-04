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
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

export const updateProfile = async (req: AuthRequest, res: Response) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      firstName,
      lastName,
      experienceLevel,
      bio,
      location,
      travelRadius,
      divingCertifications,
      preferredDepths,
      weavingSpecialties
    } = req.body;

    const updateData: any = {
      firstName,
      lastName,
      experienceLevel,
      bio,
      travelRadius,
      divingCertifications,
      preferredDepths,
      weavingSpecialties
    };

    if (location && location.coordinates) {
      updateData.location = {
        type: 'Point',
        coordinates: location.coordinates
      };
    }

    const user = await User.findByIdAndUpdate(
      req.userId,
      updateData,
      { new: true, runValidators: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

export const uploadProfilePhoto = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const user = await User.findByIdAndUpdate(
      req.userId,
      { profilePhoto: req.file.path },
      { new: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ profilePhoto: user.profilePhoto });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

export const uploadPhotos = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.files || !Array.isArray(req.files) || req.files.length === 0) {
      return res.status(400).json({ message: 'No files uploaded' });
    }

    const photoPaths = req.files.map(file => file.path);

    const user = await User.findByIdAndUpdate(
      req.userId,
      { $push: { photos: { $each: photoPaths } } },
      { new: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ photos: user.photos });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};