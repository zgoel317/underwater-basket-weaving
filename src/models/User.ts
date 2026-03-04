import mongoose, { Document, Schema } from 'mongoose';

export interface IUser extends Document {
  email: string;
  password: string;
  profile: {
    firstName: string;
    lastName: string;
    experienceLevel: 'Beginner' | 'Intermediate' | 'Advanced' | 'Master Weaver';
    location: {
      latitude: number;
      longitude: number;
      city: string;
      state: string;
    };
    photos: string[];
    divingCertifications: {
      level: string;
      organization: string;
      certificationDate: Date;
    }[];
    preferredDepths: {
      min: number;
      max: number;
    };
    weavingSpecialties: string[];
    bio: string;
    age: number;
  };
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  profile: {
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    experienceLevel: { 
      type: String, 
      enum: ['Beginner', 'Intermediate', 'Advanced', 'Master Weaver'],
      required: true 
    },
    location: {
      latitude: { type: Number, required: true },
      longitude: { type: Number, required: true },
      city: { type: String, required: true },
      state: { type: String, required: true }
    },
    photos: [{ type: String }],
    divingCertifications: [{
      level: { type: String, required: true },
      organization: { type: String, required: true },
      certificationDate: { type: Date, required: true }
    }],
    preferredDepths: {
      min: { type: Number, default: 0 },
      max: { type: Number, default: 30 }
    },
    weavingSpecialties: [{ type: String }],
    bio: { type: String, maxlength: 500 },
    age: { type: Number, required: true, min: 18 }
  }
}, {
  timestamps: true
});

export const User = mongoose.model<IUser>('User', userSchema);