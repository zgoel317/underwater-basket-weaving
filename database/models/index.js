const db = require('../config/database');

class BaseModel {
  static async create(tableName, data) {
    const keys = Object.keys(data);
    const values = Object.values(data);
    const placeholders = keys.map((_, i) => `$${i + 1}`).join(', ');
    const columns = keys.join(', ');
    
    const query = `INSERT INTO ${tableName} (${columns}) VALUES (${placeholders}) RETURNING *`;
    const result = await db.query(query, values);
    return result.rows[0];
  }

  static async findById(tableName, id) {
    const query = `SELECT * FROM ${tableName} WHERE id = $1`;
    const result = await db.query(query, [id]);
    return result.rows[0];
  }

  static async update(tableName, id, data) {
    const keys = Object.keys(data);
    const values = Object.values(data);
    const setClause = keys.map((key, i) => `${key} = $${i + 2}`).join(', ');
    
    const query = `UPDATE ${tableName} SET ${setClause}, updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *`;
    const result = await db.query(query, [id, ...values]);
    return result.rows[0];
  }

  static async delete(tableName, id) {
    const query = `DELETE FROM ${tableName} WHERE id = $1 RETURNING *`;
    const result = await db.query(query, [id]);
    return result.rows[0];
  }
}

class User extends BaseModel {
  static async findByEmail(email) {
    const query = 'SELECT * FROM users WHERE email = $1';
    const result = await db.query(query, [email]);
    return result.rows[0];
  }

  static async createWithProfile(userData, profileData) {
    const client = await db.pool.connect();
    try {
      await client.query('BEGIN');
      
      const userResult = await client.query(
        'INSERT INTO users (email, password_hash) VALUES ($1, $2) RETURNING *',
        [userData.email, userData.password_hash]
      );
      const user = userResult.rows[0];
      
      const profileResult = await client.query(
        `INSERT INTO profiles (user_id, display_name, experience_level, age, bio, latitude, longitude) 
         VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
        [user.id, profileData.display_name, profileData.experience_level, 
         profileData.age, profileData.bio, profileData.latitude, profileData.longitude]
      );
      
      await client.query('COMMIT');
      return { user, profile: profileResult.rows[0] };
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }
}

class Match extends BaseModel {
  static async findMatches(userId) {
    const query = `
      SELECT m.*, p1.display_name as user1_name, p2.display_name as user2_name
      FROM matches m
      JOIN profiles p1 ON m.user1_id = p1.user_id
      JOIN profiles p2 ON m.user2_id = p2.user_id
      WHERE (m.user1_id = $1 OR m.user2_id = $1) AND m.status = 'matched'
      ORDER BY m.matched_at DESC
    `;
    const result = await db.query(query, [userId]);
    return result.rows;
  }

  static async createMatch(user1Id, user2Id) {
    const query = `
      INSERT INTO matches (user1_id, user2_id, status, matched_at) 
      VALUES ($1, $2, 'matched', CURRENT_TIMESTAMP) 
      ON CONFLICT (user1_id, user2_id) 
      DO UPDATE SET status = 'matched', matched_at = CURRENT_TIMESTAMP 
      RETURNING *
    `;
    const result = await db.query(query, [user1Id, user2Id]);
    return result.rows[0];
  }
}

class Profile extends BaseModel {
  static async findNearbyProfiles(latitude, longitude, radius = 50, excludeUserId) {
    const query = `
      SELECT p.*, u.email,
        (6371 * acos(cos(radians($1)) * cos(radians(p.latitude)) 
        * cos(radians(p.longitude) - radians($2)) + sin(radians($1)) 
        * sin(radians(p.latitude)))) AS distance
      FROM profiles p
      JOIN users u ON p.user_id = u.id
      WHERE p.latitude IS NOT NULL 
        AND p.longitude IS NOT NULL
        AND p.user_id != $4
        AND u.is_active = true
      HAVING distance < $3
      ORDER BY distance
    `;
    const result = await db.query(query, [latitude, longitude, radius, excludeUserId]);
    return result.rows;
  }
}

module.exports = {
  BaseModel,
  User,
  Match,
  Profile,
  db
};