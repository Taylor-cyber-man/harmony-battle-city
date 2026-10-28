import {
  TankData, createEnemyTank,
  setFrozen, isPowerUpTank, getScore,
  damageTank
} from '../entities/Tank'
import {
  Direction, EnemyType, MAX_ENEMIES_PER_STAGE, MAX_ENEMIES_ON_SCREEN,
  AI_DIR_CHANGE_PROB, AI_DIR_CHANGE_INTERVAL,
  AI_TARGET_SEEK_PROB, AI_FIRE_PROB, SPAWN_ANIM_FRAMES
} from '../utils/Constants'
import { getEnemySpawnPoints } from '../levels/LevelData'
import { randomInt } from '../utils/MathUtils'
import { tankVsTerrain } from '../systems/CollisionSystem'

const AI_DIRS: Direction[] = [Direction.UP, Direction.DOWN, Direction.LEFT, Direction.RIGHT]
const AI_ALT_DIRS: number[][] = [[0, -1], [0, 1], [-1, 0], [1, 0]]

let spawnDelay: number = 0
let enemiesSpawned: number = 0
let enemiesRemaining: number = 0

function initAI(enemySequence: number[], stageIndex: number): void {
  enemiesSpawned = 0
  enemiesRemaining = MAX_ENEMIES_PER_STAGE
  spawnDelay = Math.max(50, 186 - stageIndex * 4)
}

function getEnemiesRemaining(): number {
  return enemiesRemaining
}

function getEnemiesSpawned(): number {
  return enemiesSpawned
}

function countActiveEnemies(enemyTanks: TankData[]): number {
  let count = 0
  for (let i = 0; i < enemyTanks.length; i++) {
    if (enemyTanks[i].isAlive) {
      count++
    }
  }
  return count
}

function spawnEnemy(
  enemyTanks: TankData[], enemySequence: number[], stageIndex: number, tileSize: number
): TankData | null {
  if (enemiesSpawned >= MAX_ENEMIES_PER_STAGE) {
    return null
  }
  let activeCount = countActiveEnemies(enemyTanks)
  if (activeCount >= MAX_ENEMIES_ON_SCREEN) {
    return null
  }
  spawnDelay -= 1
  if (spawnDelay > 0) {
    return null
  }
  spawnDelay = Math.max(50, 186 - stageIndex * 4)
  let enemyType = enemySequence[enemiesSpawned]
  let spawnPoints = getEnemySpawnPoints(stageIndex)
  let spawnPointIdx = randomInt(3)
  let spawnX = spawnPoints[spawnPointIdx][0] * tileSize + tileSize / 2
  let spawnY = spawnPoints[spawnPointIdx][1] * tileSize + tileSize / 2
  let newTank = createEnemyTank(2 + activeCount, enemyType as EnemyType, spawnX, spawnY, tileSize)
  if (enemiesSpawned === 3 || enemiesSpawned === 10 || enemiesSpawned === 17) {
    newTank.isFlashing = true
  }
  enemiesSpawned += 1
  return newTank
}

function updateEnemyAI(enemyTanks: TankData[], playerX: number, playerY: number, terrain: number[][], tileSize: number): void {
  for (let i = 0; i < enemyTanks.length; i++) {
    let enemy = enemyTanks[i]
    if (!enemy.isAlive || enemy.isFrozen || enemy.isSpawning) {
      continue
    }

    enemy.directionTimer = (enemy.directionTimer || 0) - 1
    if (enemy.directionTimer <= 0) {
      if (Math.random() < 0.35) {
        let dxToPlayer = playerX - enemy.x
        let dyToPlayer = playerY - enemy.y
        if (Math.abs(dyToPlayer) > Math.abs(dxToPlayer)) {
          enemy.direction = dyToPlayer < 0 ? Direction.UP : Direction.DOWN
        } else {
          enemy.direction = dxToPlayer < 0 ? Direction.LEFT : Direction.RIGHT
        }
      } else {
        let dirs: Direction[] = AI_DIRS
        enemy.direction = dirs[randomInt(4)]
      }
      enemy.directionTimer = randomInt(32) + 24
    }

    let speed = enemy.speed
    let dx = 0
    let dy = 0
    if (enemy.direction === Direction.UP) {
      dy = -1
    } else if (enemy.direction === Direction.DOWN) {
      dy = 1
    } else if (enemy.direction === Direction.LEFT) {
      dx = -1
    } else {
      dx = 1
    }

    let origX = enemy.x
    let origY = enemy.y
    enemy.x += dx * speed
    enemy.y += dy * speed

    if (tankVsTerrain(enemy, terrain, tileSize)) {
      enemy.x = origX
      enemy.y = origY
      let altDirs: number[][] = AI_ALT_DIRS
      let altIdx = randomInt(4)
      let adx = altDirs[altIdx][0]
      let ady = altDirs[altIdx][1]
      if (adx !== dx || ady !== dy) {
        enemy.x += adx * speed
        enemy.y += ady * speed
        if (tankVsTerrain(enemy, terrain, tileSize)) {
          enemy.x = origX
          enemy.y = origY
        } else {
          enemy.direction = adx < 0 ? Direction.LEFT : adx > 0 ? Direction.RIGHT : ady < 0 ? Direction.UP : Direction.DOWN
          enemy.directionTimer = randomInt(24) + 16
        }
      }
    }
  }
}

function shouldEnemyFire(enemy: TankData, playerX: number, playerY: number): boolean {
  if (enemy.fireCooldown > 0 || !enemy.isAlive || enemy.isFrozen || enemy.isSpawning) {
    return false
  }
  let dx = playerX - enemy.x
  let dy = playerY - enemy.y
  let aligned = false
  if (enemy.direction === Direction.UP && dy < 0 && Math.abs(dx) < 40) {
    aligned = true
  } else if (enemy.direction === Direction.DOWN && dy > 0 && Math.abs(dx) < 40) {
    aligned = true
  } else if (enemy.direction === Direction.LEFT && dx < 0 && Math.abs(dy) < 40) {
    aligned = true
  } else if (enemy.direction === Direction.RIGHT && dx > 0 && Math.abs(dy) < 40) {
    aligned = true
  }
  if (!aligned) {
    return false
  }
  return Math.random() < 0.02
}

function onEnemyDestroyed(enemy: TankData): void {
  enemiesRemaining -= 1
}

export {
  initAI,
  getEnemiesRemaining,
  getEnemiesSpawned,
  countActiveEnemies,
  spawnEnemy,
  updateEnemyAI,
  shouldEnemyFire,
  onEnemyDestroyed
}
