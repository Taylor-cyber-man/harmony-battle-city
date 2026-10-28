import { PowerUpType, POWERUP_TANK_INDICES } from '../utils/Constants'

interface PowerUpData {
  x: number
  y: number
  type: PowerUpType
  isActive: boolean
}

function createPowerUp(x: number, y: number, powerType: PowerUpType): PowerUpData {
  return {
    x: x,
    y: y,
    type: powerType,
    isActive: true
  }
}

function randomPowerUpType(): PowerUpType {
  return (Math.floor(Math.random() * 5) + 1) as PowerUpType
}

function isPowerUpEnemyIndex(enemyIndex: number): boolean {
  for (let i = 0; i < POWERUP_TANK_INDICES.length; i++) {
    if (enemyIndex === POWERUP_TANK_INDICES[i]) {
      return true
    }
  }
  return false
}

function deactivate(p: PowerUpData): void {
  p.isActive = false
}

export { PowerUpData, createPowerUp, randomPowerUpType, isPowerUpEnemyIndex, deactivate }
