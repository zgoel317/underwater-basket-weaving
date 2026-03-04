import express from 'express';
import { body } from 'express-validator';
import { register, login } from '../controllers/authController';

const router = express.Router();

router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }),
  body('profile.firstName').trim().isLength({ min: 1 }),
  body('profile.lastName').trim().isLength({ min: 1 }),
  body('profile.experienceLevel').isIn(['Beginner', 'Intermediate', 'Advanced', 'Master Weaver']),
  body('profile.age').isInt({ min: 18, max: 100 }),
  body('profile.location.city').trim().isLength({ min: 1 }),
  body('profile.location.state').trim().isLength({ min: 1 }),
  body('profile.location.coordinates').isArray({ min: 2, max: 2 })
], register);

router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').exists()
], login);

export default router;