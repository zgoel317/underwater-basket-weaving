import { UserProfile } from './types';

export class CompatibilityCalculator {
  
  calculateSkillCompatibility(user1: UserProfile, user2: UserProfile): number {
    const skillLevels = ['Beginner', 'Intermediate', 'Advanced', 'Master Weaver'];
    const user1Level = skillLevels.indexOf(user1.skillLevel);
    const user2Level = skillLevels.indexOf(user2.skillLevel);
    
    const difference = Math.abs(user1Level - user2Level);
    return Math.max(0, 1 - (difference / (skillLevels.length - 1)));
  }

  calculateGeographicProximity(user1: UserProfile, user2: UserProfile): number {
    const distance = this.haversineDistance(
      user1.location.latitude,
      user1.location.longitude,
      user2.location.latitude,
      user2.location.longitude
    );
    
    const maxTravelDistance = Math.min(user1.location.travelRadius, user2.location.travelRadius);
    
    if (distance > maxTravelDistance) return 0;
    return Math.max(0, 1 - (distance / maxTravelDistance));
  }

  calculateWeavingAlignment(user1: UserProfile, user2: UserProfile): number {
    const reedScore = this.calculateArrayOverlap(user1.weavingPreferences.reedTypes, user2.weavingPreferences.reedTypes);
    const patternScore = this.calculateArrayOverlap(user1.weavingPreferences.patterns, user2.weavingPreferences.patterns);
    const techniqueScore = this.calculateArrayOverlap(user1.weavingPreferences.underwaterTechniques, user2.weavingPreferences.underwaterTechniques);
    
    return (reedScore + patternScore + techniqueScore) / 3;
  }

  calculateScheduleCompatibility(user1: UserProfile, user2: UserProfile): number {
    const dayScore = this.calculateArrayOverlap(user1.divingSchedule.availableDays, user2.divingSchedule.availableDays);
    const timeScore = this.calculateArrayOverlap(user1.divingSchedule.preferredTimes, user2.divingSchedule.preferredTimes);
    
    const depthOverlap = this.calculateDepthOverlap(
      user1.divingSchedule.preferredDepths,
      user2.divingSchedule.preferredDepths
    );
    
    return (dayScore + timeScore + depthOverlap) / 3;
  }

  calculateEquipmentSynergy(user1: UserProfile, user2: UserProfile): number {
    const user1Shares = user1.equipmentInterests.wantsToShare;
    const user1Wants = user1.equipmentInterests.wantsToUse;
    const user2Shares = user2.equipmentInterests.wantsToShare;
    const user2Wants = user2.equipmentInterests.wantsToUse;
    
    const user1CanHelp = this.calculateArrayOverlap(user1Shares, user2Wants);
    const user2CanHelp = this.calculateArrayOverlap(user2Shares, user1Wants);
    
    return (user1CanHelp + user2CanHelp) / 2;
  }

  private calculateArrayOverlap(array1: string[], array2: string[]): number {
    if (array1.length === 0 && array2.length === 0) return 1;
    if (array1.length === 0 || array2.length === 0) return 0;
    
    const intersection = array1.filter(item => array2.includes(item));
    const union = [...new Set([...array1, ...array2])];
    
    return intersection.length / union.length;
  }

  private calculateDepthOverlap(depths1: {min: number, max: number}, depths2: {min: number, max: number}): number {
    const overlapMin = Math.max(depths1.min, depths2.min);
    const overlapMax = Math.min(depths1.max, depths2.max);
    
    if (overlapMin > overlapMax) return 0;
    
    const overlapRange = overlapMax - overlapMin;
    const totalRange = Math.max(depths1.max, depths2.max) - Math.min(depths1.min, depths2.min);
    
    return overlapRange / totalRange;
  }

  private haversineDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Earth's radius in km
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private toRad(deg: number): number {
    return deg * (Math.PI / 180);
  }
}