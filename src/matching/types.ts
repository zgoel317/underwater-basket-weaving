export interface UserProfile {
  id: string;
  skillLevel: 'Beginner' | 'Intermediate' | 'Advanced' | 'Master Weaver';
  location: {
    latitude: number;
    longitude: number;
    travelRadius: number; // km
  };
  weavingPreferences: {
    reedTypes: string[];
    patterns: string[];
    underwaterTechniques: string[];
  };
  divingSchedule: {
    availableDays: string[]; // ['monday', 'tuesday', ...]
    preferredTimes: string[]; // ['morning', 'afternoon', 'evening']
    preferredDepths: {
      min: number;
      max: number;
    };
  };
  equipmentInterests: {
    owns: string[];
    wantsToShare: string[];
    wantsToUse: string[];
  };
  age: number;
  createdAt: Date;
}

export interface MatchScore {
  userId: string;
  totalScore: number;
  breakdown: {
    skillCompatibility: number;
    geographicProximity: number;
    weavingAlignment: number;
    scheduleCompatibility: number;
    equipmentSynergy: number;
  };
}

export interface MatchingConfig {
  weights: {
    skillCompatibility: number;
    geographicProximity: number;
    weavingAlignment: number;
    scheduleCompatibility: number;
    equipmentSynergy: number;
  };
  maxMatches: number;
  minScore: number;
}

export const DEFAULT_CONFIG: MatchingConfig = {
  weights: {
    skillCompatibility: 0.25,
    geographicProximity: 0.20,
    weavingAlignment: 0.25,
    scheduleCompatibility: 0.20,
    equipmentSynergy: 0.10
  },
  maxMatches: 50,
  minScore: 0.3
};