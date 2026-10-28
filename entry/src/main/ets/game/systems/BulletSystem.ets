import { TankData } from '../entities/Tank'
import { BulletData, createBullet } from '../entities/Bullet'
import { Direction } from '../utils/Constants'

let bulletPool: BulletData[] = []
let nextBulletSlot: number = 0

function initBulletPool(): void {
  bulletPool = []
  for (let i = 0; i < 10; i++) {
    bulletPool[i] = {
      x: 0,
      y: 0,
      direction: Direction.UP,
      speed: 0,
      isArmorPiercing: false,
      isPlayerBullet: false,
      isActive: false,
      ownerSlotIndex: -1
    }
  }
  nextBulletSlot = 0
}

function getBulletPool(): BulletData[] {
  return bulletPool
}

function fireBulletFromTank(
  tank: TankData, isPlayer: boolean, tileSize: number
): BulletData | null {
  if (tank.fireCooldown > 0) {
    return null
  }
  let bx = tank.x
  let by = tank.y
  let half = tileSize * 0.35
  if (tank.direction === Direction.UP) {
    by = tank.y - half - 4
  } else if (tank.direction === Direction.DOWN) {
    by = tank.y + half + 4
  } else if (tank.direction === Direction.LEFT) {
    bx = tank.x - half - 4
  } else {
    bx = tank.x + half + 4
  }
  for (let i = 0; i < bulletPool.length; i++) {
    let slot = (nextBulletSlot + i) % bulletPool.length
    if (!bulletPool[slot].isActive) {
      let bullet = createBullet(bx, by, tank.direction, isPlayer, tank.powerLevel, tileSize, tank.slotIndex)
      bulletPool[slot] = bullet
      nextBulletSlot = (slot + 1) % bulletPool.length
      return bullet
    }
  }
  return null
}

function fireBulletDouble(tank: TankData, isPlayer: boolean, tileSize: number): void {
  let b1 = fireBulletFromTank(tank, isPlayer, tileSize)
  if (b1 !== null && b1.isActive) {
    let offsetX = 0
    let offsetY = 0
    if (tank.direction === Direction.UP || tank.direction === Direction.DOWN) {
      offsetX = tileSize * 0.15
    } else {
      offsetY = tileSize * 0.15
    }
    let saveX = tank.x
    let saveY = tank.y
    tank.x += offsetX
    tank.y += offsetY
    fireBulletFromTank(tank, isPlayer, tileSize)
    tank.x = saveX
    tank.y = saveY
  }
}

export {
  BulletData,
  initBulletPool,
  getBulletPool,
  fireBulletFromTank,
  fireBulletDouble
}
