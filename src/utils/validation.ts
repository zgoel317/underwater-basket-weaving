import Joi from 'joi';

const profileSchema = Joi.object({
  firstName: Joi.string().min(1).max(50).required(),
  lastName: Joi.string().min(1).max(50).required(),
  experienceLevel: Joi.string().valid('Beginner', 'Intermediate', 'Advanced', 'Master Weaver').required(),
  bio: Joi.string().max(500),
  age: Joi.number().integer().min(18).max(100).required(),
  location: Joi.object({
    city: Joi.string().required(),
    state: Joi.string().required(),
    coordinates: Joi.array().items(Joi.number()).length(2).required()
  }).required(),
  divingCertifications: Joi.array().items(Joi.object({
    level: Joi.string().required(),
    certifyingBody: Joi.string().required(),
    dateObtained: Joi.date().required()
  })),
  preferredDepths: Joi.object({
    min: Joi.number().min(0).default(0),
    max: Joi.number().min(0).default(30)
  }),
  basketWeaving: Joi.object({
    specialties: Joi.array().items(Joi.string()),
    yearsExperience: Joi.number().min(0).default(0),
    favoritePatterns: Joi.array().items(Joi.string())
  })
});

export const validateRegistration = (data: any) => {
  const schema = Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().min(6).required(),
    profile: profileSchema.required()
  });
  return schema.validate(data);
};

export const validateLogin = (data: any) => {
  const schema = Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required()
  });
  return schema.validate(data);
};

export const validateProfileUpdate = (data: any) => {
  return profileSchema.validate(data);
};