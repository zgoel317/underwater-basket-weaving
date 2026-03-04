import { body, validationResult } from 'express-validator';
import { Request, Response, NextFunction } from 'express';

export const validateRegistration = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }).matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/),
  body('firstName').trim().isLength({ min: 2, max: 50 }),
  body('lastName').trim().isLength({ min: 2, max: 50 }),
  body('experienceLevel').optional().isIn(['Beginner', 'Intermediate', 'Advanced', 'Master Weaver'])
];

export const validateLogin = [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty()
];

export const validateProfile = [
  body('firstName').optional().trim().isLength({ min: 2, max: 50 }),
  body('lastName').optional().trim().isLength({ min: 2, max: 50 }),
  body('experienceLevel').optional().isIn(['Beginner', 'Intermediate', 'Advanced', 'Master Weaver']),
  body('bio').optional().isLength({ max: 500 }),
  body('travelRadius').optional().isInt({ min: 0, max: 500 }),
  body('preferredDepths.min').optional().isInt({ min: 0, max: 100 }),
  body('preferredDepths.max').optional().isInt({ min: 0, max: 100 })
];

export const handleValidationErrors = (req: Request, res: Response, next: NextFunction) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};