import { Router } from 'express';
import { body } from 'express-validator';
import { register, login } from '../controllers/authController';

const router = Router();

router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('firstName').trim().isLength({ min: 1 }),
  body('lastName').trim().isLength({ min: 1 }),
  body('experienceLevel').isIn(['Beginner', 'Intermediate', 'Advanced', 'Master Weaver']),
  body('location.coordinates').isArray({ min: 2, max: 2 }),
  body('location.coordinates.*').isNumeric()
], register);

router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').exists()
], login);

export default router;