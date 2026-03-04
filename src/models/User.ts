import mongoose, { Document, Schema } from 'mongoose';

export interface IUser extends Document {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  experienceLevel: 'Beginner' | 'Intermediate' | 'Advanced' | 'Master Weaver';
  bio?: string;
  location: {
    type: 'Point';
    coordinates: [number, number];
  };
  travelRadius: number;
  divingCertifications: string[];
  preferredDepths: {
    min: number;
    max: number;
  };
  weavingSpecialties: string[];
  photos: string[];
  profilePhoto?: string;
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  experienceLevel: { 
    type: String, 
    enum: ['Beginner', 'Intermediate', 'Advanced', 'Master Weaver'],
    required: true 
  },
  bio: String,
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      required: true
    }
  },
  travelRadius: { type: Number, default: 50 },
  divingCertifications: [String],
  preferredDepths: {
    min: { type: Number, default: 0 },
    max: { type: Number, default: 30 }
  },
  weavingSpecialties: [String],
  photos: [String],
  profilePhoto: String
}, {
  timestamps: true
});

userSchema.index({ location: '2dsphere' });

export const User = mongoose.model<IUser>('User', userSchema);