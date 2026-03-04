import mongoose, { Document, Schema } from 'mongoose';

export interface IUser extends Document {
  email: string;
  password: string;
  profile: {
    firstName: string;
    lastName: string;
    experienceLevel: 'Beginner' | 'Intermediate' | 'Advanced' | 'Master Weaver';
    bio?: string;
    age: number;
    location: {
      city: string;
      state: string;
      coordinates: [number, number];
    };
    divingCertifications: {
      level: string;
      certifyingBody: string;
      dateObtained: Date;
    }[];
    preferredDepths: {
      min: number;
      max: number;
    };
    basketWeaving: {
      specialties: string[];
      yearsExperience: number;
      favoritePatterns: string[];
    };
    photos: {
      url: string;
      isUnderwater: boolean;
      isPrimary: boolean;
      uploadedAt: Date;
    }[];
  };
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>({
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true },
  profile: {
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    experienceLevel: { 
      type: String, 
      enum: ['Beginner', 'Intermediate', 'Advanced', 'Master Weaver'],
      required: true 
    },
    bio: String,
    age: { type: Number, required: true, min: 18 },
    location: {
      city: { type: String, required: true },
      state: { type: String, required: true },
      coordinates: {
        type: [Number],
        required: true,
        index: '2dsphere'
      }
    },
    divingCertifications: [{
      level: { type: String, required: true },
      certifyingBody: { type: String, required: true },
      dateObtained: { type: Date, required: true }
    }],
    preferredDepths: {
      min: { type: Number, default: 0 },
      max: { type: Number, default: 30 }
    },
    basketWeaving: {
      specialties: [String],
      yearsExperience: { type: Number, default: 0 },
      favoritePatterns: [String]
    },
    photos: [{
      url: { type: String, required: true },
      isUnderwater: { type: Boolean, default: false },
      isPrimary: { type: Boolean, default: false },
      uploadedAt: { type: Date, default: Date.now }
    }]
  }
}, {
  timestamps: true
});

export const User = mongoose.model<IUser>('User', userSchema);