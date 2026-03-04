import { UserProfile, MatchScore, MatchingConfig, DEFAULT_CONFIG } from './types';
import { CompatibilityCalculator } from './CompatibilityCalculator';

export class MatchingService {
  private calculator: CompatibilityCalculator;

  constructor(private config: MatchingConfig = DEFAULT_CONFIG) {
    this.calculator = new CompatibilityCalculator();
  }

  async findMatches(targetUser: UserProfile, candidateUsers: UserProfile[]): Promise<MatchScore[]> {
    const scores: MatchScore[] = [];

    for (const candidate of candidateUsers) {
      if (candidate.id === targetUser.id) continue;

      const breakdown = {
        skillCompatibility: this.calculator.calculateSkillCompatibility(targetUser, candidate),
        geographicProximity: this.calculator.calculateGeographicProximity(targetUser, candidate),
        weavingAlignment: this.calculator.calculateWeavingAlignment(targetUser, candidate),
        scheduleCompatibility: this.calculator.calculateScheduleCompatibility(targetUser, candidate),
        equipmentSynergy: this.calculator.calculateEquipmentSynergy(targetUser, candidate)
      };

      const totalScore = Object.entries(breakdown).reduce(
        (sum, [key, value]) => sum + (value * this.config.weights[key as keyof typeof this.config.weights]),
        0
      );

      if (totalScore >= this.config.minScore) {
        scores.push({
          userId: candidate.id,
          totalScore,
          breakdown
        });
      }
    }

    return scores
      .sort((a, b) => b.totalScore - a.totalScore)
      .slice(0, this.config.maxMatches);
  }

  updateConfig(newConfig: Partial<MatchingConfig>): void {
    this.config = { ...this.config, ...newConfig };
  }

  async getTopMatches(targetUserId: string, allUsers: UserProfile[]): Promise<MatchScore[]> {
    const targetUser = allUsers.find(u => u.id === targetUserId);
    if (!targetUser) throw new Error('Target user not found');

    const candidates = allUsers.filter(u => u.id !== targetUserId);
    return this.findMatches(targetUser, candidates);
  }
}