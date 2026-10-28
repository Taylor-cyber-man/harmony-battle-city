import {
  Direction, EnemyType, PLAYER_MOVE_SPEED_RATIO,
  FIRE_COOLDOWN_MS, MAX_ENEMIES_ON_SCREEN,
  COLOR_PLAYER_BODY, COLOR_PLAYER_TURRET, COLOR_PLAYER_STRIPE,
  COLOR_PLAYER_TREAD, COLOR_PLAYER_BARREL,
  COLOR_ENEMY_BODY_WHITE, COLOR_ENEMY_TURRET_WHITE,
  COLOR_ENEMY_BODY_DARK, COLOR_ENEMY_TURRET_DARK,
  COLOR_ENEMY_TREAD, COLOR_HEAVY_HP4, COLOR_HEAVY_HP3,
  COLOR_HEAVY_HP2, COLOR_HEAVY_HP1, HELMET_DURATION_FRAMES,
  SHOVEL_DURATION_FRAMES, CLOCK_DURATION_FRAMES
} from '../utils/Constants'

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
  enemyType: EnemyType
  slotIndex: number
  spawnTimer: number
  isSpawning: boolean
  directionTimer: number
}

function createPlayerTank(slotIndex: number, startX: number, startY: number, tileSize: number): TankData {
  return {
    x: startX,
    y: startY,
    direction: Direction.UP,
    speed: tileSize * PLAYER_MOVE_SPEED_RATIO,
    hp: 1,
    maxHp: 1,
    fireCooldown: 0,
    powerLevel: 0,
    isPlayer: true,
    isFlashing: false,
    isFrozen: false,
    isShielded: false,
    shieldTimer: 0,
    isAlive: true,
    enemyType: EnemyType.LIGHT,
    slotIndex: slotIndex,
    spawnTimer: 0,
    isSpawning: false,
    directionTimer: 0
  }
}

function createEnemyTank(slotIndex: number, enemyType: EnemyType, spawnX: number, spawnY: number, tileSize: number): TankData {
  let speed = 1.2
  if (enemyType === EnemyType.ARMORED_CAR) {
    speed = 1.7
  }
  let maxHp = 1
  if (enemyType === EnemyType.HEAVY) {
    maxHp = 4
  }
  return {
    x: spawnX,
    y: spawnY,
    direction: Direction.DOWN,
    speed: speed,
    hp: maxHp,
    maxHp: maxHp,
    fireCooldown: 0,
    powerLevel: 0,
    isPlayer: false,
    isFlashing: false,
    isFrozen: false,
    isShielded: false,
    shieldTimer: 0,
    isAlive: true,
    enemyType: enemyType,
    slotIndex: slotIndex,
    spawnTimer: 60,
    isSpawning: true,
    directionTimer: 0
  }
}

function moveTank(tank: TankData, dx: number, dy: number, dt: number): void {
  if (!tank.isAlive || tank.isFrozen || tank.isSpawning) {
    return
  }
  let speed = tank.speed
  if (dx !== 0 && dy !== 0) {
    speed = speed * 0.707
  }
  tank.x += dx * speed
  tank.y += dy * speed
}

function updateDirection(tank: TankData, dx: number, dy: number): void {
  if (dy < 0 && dx === 0) {
    tank.direction = Direction.UP
  } else if (dy > 0 && dx === 0) {
    tank.direction = Direction.DOWN
  } else if (dx < 0 && dy === 0) {
    tank.direction = Direction.LEFT
  } else if (dx > 0 && dy === 0) {
    tank.direction = Direction.RIGHT
  } else if (dy < 0 && dx < 0) {
    tank.direction = Direction.UP
  } else if (dy < 0 && dx > 0) {
    tank.direction = Direction.UP
  } else if (dy > 0 && dx < 0) {
    tank.direction = Direction.DOWN
  } else if (dy > 0 && dx > 0) {
    tank.direction = Direction.DOWN
  }
}

// 对坦克造成伤害，返回是否被摧毁；护盾/生成中免疫
function damageTank(tank: TankData, damage: number): boolean {
  if (!tank.isAlive || tank.isShielded || tank.isSpawning) {
    return false
  }
  tank.hp -= damage
  if (tank.hp <= 0) {
    tank.isAlive = false
    return true
  }
  return false
}

function addPowerLevel(tank: TankData): void {
  if (tank.powerLevel < 3) {
    tank.powerLevel += 1
  }
}

function resetPowerLevel(tank: TankData): void {
  tank.powerLevel = 0
}

function activateShield(tank: TankData): void {
  tank.isShielded = true
  tank.shieldTimer = HELMET_DURATION_FRAMES
}

function activateFlashing(tank: TankData): void {
  tank.isFlashing = true
}

function deactivateFlashing(tank: TankData): void {
  tank.isFlashing = false
}

function setFrozen(tank: TankData, frozen: boolean): void {
  tank.isFrozen = frozen
}

function updateTimers(tank: TankData): void {
  if (tank.fireCooldown > 0) {
    tank.fireCooldown -= 1
  }
  if (tank.isShielded && tank.shieldTimer > 0) {
    tank.shieldTimer -= 1
    if (tank.shieldTimer <= 0) {
      tank.isShielded = false
    }
  }
  if (tank.isSpawning && tank.spawnTimer > 0) {
    tank.spawnTimer -= 1
    if (tank.spawnTimer <= 0) {
      tank.isSpawning = false
    }
  }
}

function resetFireCooldown(tank: TankData): void {
  tank.fireCooldown = FIRE_COOLDOWN_MS
}

function canFire(tank: TankData): boolean {
  return tank.fireCooldown <= 0 && !tank.isSpawning && !tank.isFrozen
}

function getTankColor(tank: TankData): string {
  if (tank.isPlayer) {
    return COLOR_PLAYER_TURRET
  }
  if (tank.enemyType === EnemyType.HEAVY) {
    if (tank.hp >= 4) {
      return COLOR_HEAVY_HP4
    } else if (tank.hp >= 3) {
      return COLOR_HEAVY_HP3
    } else if (tank.hp >= 2) {
      return COLOR_HEAVY_HP2
    }
    return COLOR_HEAVY_HP1
  }
  if (tank.enemyType === EnemyType.FAST_SHOT) {
    return COLOR_ENEMY_TURRET_DARK
  }
  return COLOR_ENEMY_TURRET_WHITE
}

function getTankSpeed(tank: TankData): number {
  if (tank.enemyType === EnemyType.ARMORED_CAR) {
    return 1.7
  }
  return 1.2
}

function getEnemyFireInterval(tank: TankData): number {
  if (tank.enemyType === EnemyType.FAST_SHOT) {
    return 500
  }
  return 1000
}

function isPowerUpTank(tank: TankData): boolean {
  return tank.isFlashing
}

function getScore(tank: TankData): number {
  return 100
}

export {
  TankData,
  createPlayerTank,
  createEnemyTank,
  moveTank,
  updateDirection,
  damageTank,
  addPowerLevel,
  resetPowerLevel,
  activateShield,
  activateFlashing,
  deactivateFlashing,
  setFrozen,
  updateTimers,
  resetFireCooldown,
  canFire,
  getTankColor,
  getTankSpeed,
  getEnemyFireInterval,
  isPowerUpTank,
  getScore
}
