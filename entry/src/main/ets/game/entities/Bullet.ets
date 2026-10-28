import { Direction, BULLET_SPEED_RATIO } from '../utils/Constants'

interface BulletData {
  x: number
  y: number
  direction: Direction
  speed: number
  isArmorPiercing: boolean
  isPlayerBullet: boolean
  isActive: boolean
  ownerSlotIndex: number
}

function createBullet(
  x: number, y: number, direction: Direction, isPlayer: boolean,
  powerLevel: number, tileSize: number, ownerSlot: number
): BulletData {
  let speed = tileSize * BULLET_SPEED_RATIO
  let armorPiercing = false
  if (powerLevel >= 3) {
    armorPiercing = true
    speed = speed * 1.5
  } else if (powerLevel >= 1) {
    speed = speed * 1.5
  }
  return {
    x: x,
    y: y,
    direction: direction,
    speed: speed,
    isArmorPiercing: armorPiercing,
    isPlayerBullet: isPlayer,
    isActive: true,
    ownerSlotIndex: ownerSlot
  }
}

function moveBulletStep(bullet: BulletData, dx: number, dy: number): void {
  bullet.x += dx
  bullet.y += dy
}

function isOutOfBounds(bullet: BulletData, canvasSize: number): boolean {
  return bullet.x < 0 || bullet.x > canvasSize || bullet.y < 0 || bullet.y > canvasSize
}

function deactivate(bullet: BulletData): void {
  bullet.isActive = false
}

export { BulletData, createBullet, moveBulletStep, isOutOfBounds, deactivate }
