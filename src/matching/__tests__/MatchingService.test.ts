import { MatchingService } from '../MatchingService';
import { UserProfile } from '../types';

const createMockUser = (overrides: Partial<UserProfile> = {}): UserProfile => ({
  id: 'user1',
  skillLevel: 'Intermediate',
  location: { latitude: 40.7128, longitude: -74.0060, travelRadius: 50 },
  weavingPreferences: {
    reedTypes: ['bamboo', 'willow'],
    patterns: ['spiral', 'lattice'],
    underwaterTechniques: ['breath-hold', 'scuba']
  },
  divingSchedule: {
    availableDays: ['saturday', 'sunday'],
    preferredTimes: ['morning'],
    preferredDepths: { min: 5, max: 20 }
  },
  equipmentInterests: {
    owns: ['mask', 'fins'],
    wantsToShare: ['weights'],
    wantsToUse: ['tank']
  },
  age: 30,
  createdAt: new Date(),
  ...overrides
});

describe('MatchingService', () => {
  let service: MatchingService;

  beforeEach(() => {
    service = new MatchingService();
  });

  it('should find compatible matches', async () => {
    const targetUser = createMockUser({ id: 'target' });
    const compatibleUser = createMockUser({
      id: 'compatible',
      skillLevel: 'Advanced',
      location: { latitude: 40.7500, longitude: -74.0000, travelRadius: 50 }
    });
    const incompatibleUser = createMockUser({
      id: 'incompatible',
      location: { latitude: 50.0, longitude: 50.0, travelRadius: 10 }
    });

    const matches = await service.findMatches(targetUser, [compatibleUser, incompatibleUser]);

    expect(matches.length).toBeGreaterThan(0);
    expect(matches[0].userId).toBe('compatible');
    expect(matches[0].totalScore).toBeGreaterThan(0.3);
  });

  it('should respect minimum score threshold', async () => {
    const targetUser = createMockUser({ id: 'target' });
    const lowScoreUser = createMockUser({
      id: 'lowscore',
      skillLevel: 'Beginner',
      location: { latitude: 50.0, longitude: 50.0, travelRadius: 5 },
      weavingPreferences: {
        reedTypes: ['different'],
        patterns: ['other'],
        underwaterTechniques: ['snorkel']
      }
    });

    const matches = await service.findMatches(targetUser, [lowScoreUser]);
    expect(matches.length).toBe(0);
  });

  it('should limit matches to maxMatches config', async () => {
    service.updateConfig({ maxMatches: 2 });
    const targetUser = createMockUser({ id: 'target' });
    const users = Array.from({ length: 5 }, (_, i) => 
      createMockUser({ id: `user${i}` })
    );

    const matches = await service.findMatches(targetUser, users);
    expect(matches.length).toBeLessThanOrEqual(2);
  });
});

// TODO: Add more comprehensive test cases for edge cases
// TODO: Add integration tests with real data scenarios
// TODO: Add performance tests for large user sets