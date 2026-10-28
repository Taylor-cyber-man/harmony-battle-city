import { TankData } from '../entities/Tank'
import { BulletData, deactivate as deactivateBullet, moveBulletStep, isOutOfBounds } from '../entities/Bullet'
import { PowerUpData } from '../entities/PowerUp'
import { TileType, EXPLOSION_ANIM_FRAMES, POWERUP_SCORE, EAGLE_POS_X, EAGLE_POS_Y } from '../utils/Constants'
import { checkAABB } from '../utils/MathUtils'

const CORNERS: number[][] = [[0, 0], [0, 0], [0, 0], [0, 0]]

interface ExplosionData {
  x: number
  y: number
  frame: number
  isActive: boolean
}

let explosions: ExplosionData[] = []

function createExplosion(x: number, y: number): ExplosionData {
  return {
    x: x,
    y: y,
    frame: 0,
    isActive: true
  }
}

function updateExplosions(): void {
  for (let i = 0; i < explosions.length; i++) {
    let exp = explosions[i]
    if (!exp.isActive) {
      continue
    }
    exp.frame += 1
    if (exp.frame >= EXPLOSION_ANIM_FRAMES) {
      exp.isActive = false
    }
  }
  let hasInactive = false
  for (let i = 0; i < explosions.length; i++) {
    if (!explosions[i].isActive) {
      hasInactive = true
      break
    }
  }
  if (!hasInactive) {
    return
  }
  let w = 0
  for (let i = 0; i < explosions.length; i++) {
    if (explosions[i].isActive) {
      explosions[w] = explosions[i]
      w++
    }
  }
  explosions.length = w
}

function addExplosion(x: number, y: number): void {
  explosions[explosions.length] = createExplosion(x, y)
}

function getExplosions(): ExplosionData[] {
  return explosions
}

function bulletVsTerrain(
  bullet: BulletData, terrainData: number[][], brickMasks: number[][],
  tileSize: number, isEagleHit: () => boolean
): boolean {
  if (!bullet.isActive) {
    return false
  }
  let gridX = Math.floor(bullet.x / tileSize)
  let gridY = Math.floor(bullet.y / tileSize)
  if (gridX < 0 || gridX >= 16 || gridY < 0 || gridY >= 16) {
    deactivateBullet(bullet)
    return true
  }
  let tileVal = terrainData[gridY][gridX]
  if (tileVal === TileType.STEEL) {
    if (bullet.isArmorPiercing) {
      terrainData[gridY][gridX] = TileType.EMPTY
    }
    deactivateBullet(bullet)
    return true
  }
  if (tileVal === TileType.BRICK) {
    terrainData[gridY][gridX] = TileType.EMPTY
    brickMasks[gridY][gridX] = 0
    deactivateBullet(bullet)
    return true
  }
  if (tileVal === TileType.WATER) {
    deactivateBullet(bullet)
    return true
  }
  let isEagle = isEagleHit()
  if (isEagle) {
    deactivateBullet(bullet)
    return true
  }
  return false
}

function checkSingleTileCollision(
  bullet: BulletData, terrainData: number[][], brickMasks: number[][], tileSize: number
): boolean {
  let gridX = Math.floor(bullet.x / tileSize)
  let gridY = Math.floor(bullet.y / tileSize)
  if (gridX < 0 || gridX >= 16 || gridY < 0 || gridY >= 16) {
    deactivateBullet(bullet)
    return true
  }
  let tileVal = terrainData[gridY][gridX]
  if (tileVal === TileType.STEEL) {
    if (bullet.isArmorPiercing) {
      terrainData[gridY][gridX] = TileType.EMPTY
    }
    deactivateBullet(bullet)
    return true
  }
  if (tileVal === TileType.BRICK) {
    terrainData[gridY][gridX] = TileType.EMPTY
    brickMasks[gridY][gridX] = 0
    deactivateBullet(bullet)
    return true
  }
  if (tileVal === TileType.WATER) {
    deactivateBullet(bullet)
    return true
  }
  return false
}

function moveAndCheckBullet(
  bullet: BulletData, terrainData: number[][], brickMasks: number[][],
  tileSize: number, canvasSize: number, isEagleHit: () => boolean
): void {
  if (!bullet.isActive) {
    return
  }
  let totalSpeed = bullet.speed
  let stepSize = tileSize * 0.15
  let steps = Math.max(1, Math.floor(totalSpeed / stepSize))
  let sx = 0
  let sy = 0
  if (bullet.direction === 0) { sy = -1 }
  else if (bullet.direction === 1) { sy = 1 }
  else if (bullet.direction === 2) { sx = -1 }
  else { sx = 1 }
  let stepX = (sx * totalSpeed) / steps
  let stepY = (sy * totalSpeed) / steps

  for (let s = 0; s < steps; s++) {
    moveBulletStep(bullet, stepX, stepY)
    if (isOutOfBounds(bullet, canvasSize)) {
      deactivateBullet(bullet)
      return
    }
    if (checkSingleTileCollision(bullet, terrainData, brickMasks, tileSize)) {
      return
    }
  }
}

function bulletVsTank(
  bullet: BulletData, tanks: TankData[], tileSize: number
): TankData | null {
  if (!bullet.isActive) {
    return null
  }
  let half = tileSize * 0.35
  for (let i = 0; i < tanks.length; i++) {
    let tank = tanks[i]
    if (!tank.isAlive || tank.isSpawning || tank.isShielded) {
      continue
    }
    if (bullet.isPlayerBullet && tank.isPlayer) {
      continue
    }
    if (!bullet.isPlayerBullet && !tank.isPlayer) {
      continue
    }
    let dx = Math.abs(bullet.x - tank.x)
    let dy = Math.abs(bullet.y - tank.y)
    if (dx < half && dy < half) {
      deactivateBullet(bullet)
      return tank
    }
  }
  return null
}

// 子弹互抵：玩家子弹与敌方子弹相遇时双方消除
function bulletVsBullet(bullets: BulletData[]): void {
  for (let i = 0; i < bullets.length; i++) {
    let a = bullets[i]
    if (!a.isActive) {
      continue
    }
    for (let j = i + 1; j < bullets.length; j++) {
      let b = bullets[j]
      if (!b.isActive) {
        continue
      }
      if (a.isPlayerBullet === b.isPlayerBullet) {
        continue
      }
      let dx = Math.abs(a.x - b.x)
      let dy = Math.abs(a.y - b.y)
      if (dx < 8 && dy < 8) {
        deactivateBullet(a)
        deactivateBullet(b)
      }
    }
  }
}

function isEagleRegion(x: number, y: number, tileSize: number): boolean {
  let eagleCX = EAGLE_POS_X * tileSize
  let eagleCY = EAGLE_POS_Y * tileSize
  return x >= eagleCX && x <= eagleCX + tileSize * 2 && y >= eagleCY && y <= eagleCY + tileSize * 2
}

// 坦克与地形碰撞检测：检查四个角点是否进入砖墙/钢墙/水域
function tankVsTerrain(
  tank: TankData, terrainData: number[][], tileSize: number
): boolean {
  let half = tileSize * 0.4
  CORNERS[0][0] = tank.x - half; CORNERS[0][1] = tank.y - half
  CORNERS[1][0] = tank.x + half; CORNERS[1][1] = tank.y - half
  CORNERS[2][0] = tank.x - half; CORNERS[2][1] = tank.y + half
  CORNERS[3][0] = tank.x + half; CORNERS[3][1] = tank.y + half
  for (let c = 0; c < 4; c++) {
    let gx = Math.floor(CORNERS[c][0] / tileSize)
    let gy = Math.floor(CORNERS[c][1] / tileSize)
    if (gx < 0 || gx >= 16 || gy < 0 || gy >= 16) {
      return true
    }
    let tileVal = terrainData[gy][gx]
    if (tileVal === TileType.BRICK || tileVal === TileType.STEEL || tileVal === TileType.WATER) {
      return true
    }
  }
  return false
}

function tankVsBoundary(tank: TankData, canvasSize: number, tileSize: number): boolean {
  let half = tileSize * 0.4
  return tank.x - half < 0 || tank.x + half > canvasSize ||
    tank.y - half < 0 || tank.y + half > canvasSize
}

function collectPowerUp(
  tank: TankData, powerUp: PowerUpData, tileSize: number
): boolean {
  if (!powerUp.isActive) {
    return false
  }
  let dx = Math.abs(tank.x - powerUp.x * tileSize)
  let dy = Math.abs(tank.y - powerUp.y * tileSize)
  return dx < tileSize * 0.7 && dy < tileSize * 0.7
}

export {
  ExplosionData,
  addExplosion,
  updateExplosions,
  getExplosions,
  bulletVsTerrain,
  bulletVsTank,
  bulletVsBullet,
  isEagleRegion,
  tankVsTerrain,
  tankVsBoundary,
  collectPowerUp,
  moveAndCheckBullet
}
