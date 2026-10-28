import { EnemyType, Direction } from '../utils/Constants'

interface GameData {
  stageIndex: number
  score: number
  highScore: number
  lives: number
  stageProgress: number
}

interface StageInfo {
  stageIndex: number
  terrain: number[][]
  enemySequence: number[]
}

interface TankData {
  x: number
  y: number
  direction: Direction
  speed: number
  hp: number
  maxHp: number
  fireCooldown: number
  powerLevel: number
  isPlayer: boolean
  isFlashing: boolean
  isFrozen: boolean
  isShielded: boolean
  shieldTimer: number
  isAlive: boolean
  enemyType: number
  slotIndex: number
}

interface BulletData {
  x: number
  y: number
  direction: Direction
  speed: number
  damage: number
  isArmorPiercing: boolean
  isPlayerBullet: boolean
  isActive: boolean
  ownerSlotIndex: number
}

interface TerrainData {
  tileType: number
  brickMask: number
}

interface PowerUpData {
  x: number
  y: number
  type: number
  isActive: boolean
  spawnTimer: number
}

interface SpawnPoint {
  x: number
  y: number
}

interface ExplosionData {
  x: number
  y: number
  frame: number
  isActive: boolean
}

interface AABB {
  x: number
  y: number
  width: number
  height: number
}

export {
  GameData,
  StageInfo,
  TankData,
  BulletData,
  TerrainData,
  PowerUpData,
  SpawnPoint,
  ExplosionData,
  AABB
}
