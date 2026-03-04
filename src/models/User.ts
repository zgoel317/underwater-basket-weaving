import { Schema, model, Document } from 'mongoose';

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
      organization: string;
      certificationDate: Date;
      maxDepth: number;
    }[];
    basketSpecialties: string[];
    profilePhotos: string[];
    basketPhotos: string[];
    travelRadius: number;
    preferredDepths: {
      min: number;
      max: number;
    };
  };
  createdAt: Date;
  updatedAt: Date;
}

const UserSchema = new Schema<IUser>({
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true, minlength: 8 },
  profile: {
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    experienceLevel: { 
      type: String, 
      required: true,
      enum: ['Beginner', 'Intermediate', 'Advanced', 'Master Weaver']
    },
    bio: { type: String, maxlength: 500 },
    age: { type: Number, required: true, min: 18, max: 100 },
    location: {
      city: { type: String, required: true },
      state: { type: String, required: true },
      coordinates: { type: [Number], required: true }
    },
    divingCertifications: [{
      level: { type: String, required: true },
      organization: { type: String, required: true },
      certificationDate: { type: Date, required: true },
      maxDepth: { type: Number, required: true }
    }],
    basketSpecialties: [{ type: String }],
    profilePhotos: [{ type: String }],
    basketPhotos: [{ type: String }],
    travelRadius: { type: Number, default: 50 },
    preferredDepths: {
      min: { type: Number, default: 0 },
      max: { type: Number, default: 30 }
    }
  }
}, {
  timestamps: true
});

UserSchema.index({ 'profile.location.coordinates': '2dsphere' });
UserSchema.index({ email: 1 });

export const User = model<IUser>('User', UserSchema);