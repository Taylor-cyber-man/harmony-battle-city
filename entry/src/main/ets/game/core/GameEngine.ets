import { GameStateManager, getStateManager } from './GameState'
import { TileType } from '../utils/Constants'

let tileSize: number = 80
let canvasPixelSize: number = 1040

interface GameState {
  terrain: number[][]
  brickMasks: number[][]
  tanks: TankData[]
  bullets: BulletData[]
  enemiesRemaining: number
  enemiesOnScreen: number
  enemiesSpawned: number
  isEagleDestroyed: boolean
  stageTransitionTimer: number
  stageEnemySequence: number[]
}

interface TankData {
  x: number
  y: number
  direction: number
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
  direction: number
  speed: number
  damage: number
  isArmorPiercing: boolean
  isPlayerBullet: boolean
  isActive: boolean
}

let inputDirectionX: number = 0
let inputDirectionY: number = 0
let inputFireRequested: boolean = false
let paused: boolean = false

let gameState: GameState

function getTileSize(): number {
  return tileSize
}

function setTileSize(size: number): void {
  tileSize = size
  canvasPixelSize = size * 13
}

function getCanvasPixelSize(): number {
  return canvasPixelSize
}

function setInputDirection(dx: number, dy: number): void {
  inputDirectionX = dx
  inputDirectionY = dy
}

function requestFire(): void {
  inputFireRequested = true
}

function initGameState(stageIndex: number, terrainData: number[][], enemySequence: number[]): void {
  let terrain: number[][] = []
  let brickMasks: number[][] = []
  for (let y = 0; y < 13; y++) {
    terrain[y] = []
    brickMasks[y] = []
    for (let x = 0; x < 13; x++) {
      let tileVal = terrainData[y][x]
      terrain[y][x] = tileVal
      brickMasks[y][x] = (tileVal === TileType.BRICK) ? 0b1111 : 0
    }
  }

  gameState = {
    terrain: terrain,
    brickMasks: brickMasks,
    tanks: [],
    bullets: [],
    enemiesRemaining: 20,
    enemiesOnScreen: 0,
    enemiesSpawned: 0,
    isEagleDestroyed: false,
    stageTransitionTimer: 0,
    stageEnemySequence: enemySequence
  }

  inputDirectionX = 0
  inputDirectionY = 0
  inputFireRequested = false
  paused = false
}

function update(dt: number): void {
  let sm = getStateManager()
  sm.processPauseResume()

  if (sm.isPaused()) {
    return
  }

  if (sm.isTransitioning()) {
    gameState.stageTransitionTimer -= dt * 1000
    if (gameState.stageTransitionTimer <= 0) {
      sm.onTransitionComplete()
    }
    return
  }

  if (!sm.canUpdate()) {
    return
  }
}

function setPaused(value: boolean): void {
  paused = value
}

function getGameState(): GameState {
  return gameState
}

function getInputDirectionX(): number {
  return inputDirectionX
}

function getInputDirectionY(): number {
  return inputDirectionY
}

function isFireRequested(): boolean {
  return inputFireRequested
}

function consumeFireRequest(): boolean {
  if (!inputFireRequested) {
    return false
  }
  inputFireRequested = false
  return true
}

export {
  getTileSize,
  setTileSize,
  getCanvasPixelSize,
  setInputDirection,
  requestFire,
  consumeFireRequest,
  initGameState,
  update,
  setPaused,
  getGameState,
  getInputDirectionX,
  getInputDirectionY,
  isFireRequested,
  GameState,
  TankData,
  BulletData
}
