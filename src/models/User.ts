import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  experienceLevel: { 
    type: String, 
    enum: ['Beginner', 'Intermediate', 'Advanced', 'Master Weaver'],
    default: 'Beginner'
  },
  photos: [{ type: String }],
  divingCertifications: [{
    name: String,
    level: String,
    certifyingOrganization: String,
    dateObtained: Date,
    expirationDate: Date
  }],
  preferredDepths: {
    min: { type: Number, default: 0 },
    max: { type: Number, default: 30 }
  },
  location: {
    city: String,
    state: String,
    country: String,
    coordinates: {
      lat: Number,
      lng: Number
    }
  },
  travelRadius: { type: Number, default: 50 },
  weavingSpecialties: [{
    reedType: String,
    patterns: [String],
    techniques: [String]
  }],
  bio: String,
  isActive: { type: Boolean, default: true }
}, {
  timestamps: true
});

export const User = mongoose.model('User', userSchema);